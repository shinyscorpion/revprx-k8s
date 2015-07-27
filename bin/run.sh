#!/bin/sh

./bin/vhost-gen.rb &
nginx -g "daemon off;"
