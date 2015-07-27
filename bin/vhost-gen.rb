#!/usr/bin/env ruby

require 'erb'
require 'json'
require 'uri'
require 'net/http'

class Vhost
  def initialize(subdomain, source_url)
    @subdomain  = subdomain
    @source_url = source_url
  end

  def definition
    ERB.new(File.read('templates/vhost.erb')).result(binding)
  end

  def file_name; "sites-available/#{@subdomain}.vhost"; end
end

class VhostCollection
  def write_vhosts_from_services_json(json)
    load_vhosts_from_services_json(json).each do |vhost|
      File.write(vhost.file_name, vhost.definition)
      puts "[#{Time.now.utc}] #{vhost.file_name} written"
    end
  end

  private

  def load_vhosts_from_services_json(json)
    JSON.parse(json)['items']
    .select{ |i| i['spec']['type'] == 'LoadBalancer' }
    .map do |i|
      Vhost.new(
        "#{i['metadata']['name']}.#{ENV['DOMAIN']}",
        "http://#{i['spec']['clusterIP']}"
      )
    end
  end
end

vc = VhostCollection.new

loop do
  # Clear out all definitions so that old vhosts get cleared
  %x(rm sites-available/*.vhost)
  # # Use for *very* basic testing
  # services = File.read('spec/services.json')
  services = Net::HTTP.get(
    URI.parse("#{ENV['KUBERNETES_MASTER']}/api/v1/namespaces/default/services")
  )
  vc.write_vhosts_from_services_json(services)
  # Reload nginx with HUP signal
  puts %x(kill -HUP $(pgrep -f "nginx" -u root))
  sleep ENV['INTERVAL'].to_f
end
