# Kubernetes Reverse Proxy
If you've started using kubernetes without a cloud provider then you'll notice
that it's more difficult than it should be to expose a service externally. This
project solves this problem.

## Configuring the master
You'll probably want to run this proxy on the master of your Kubernetes cluster.
For this to work you'll also have to run `kube-proxy` on the master as well.
This will allow it to connect to the load balanced overlay network IPs.

## Configuring DNS wildcard
You'll also want to have a domain or subdomain which you can use to refer to
your services. You'll need to define an A record for * and point it to your
Kubernetes master. For example: `A  *.example.com.  1.1.1.1`.

## Running the proxy
The proxy generates virtualhosts nginx. It polls the kubernetes API every
`INTERVAL` seconds to regenerate it's vhosts, and makes nginx reload it's
configuration. It uses the service name to generate a subdomain
(`<service_name>.<DOMAIN>`); e.g. microbot-v1.example.com. It then maps this
subdomain to the load balancer's IP.

```
docker run \
  -e KUBERNETES_MASTER=http://172.17.8.101:8080 \
  -e INTERVAL=10 \
  -e DOMAIN=example.com \
  -p 80:80 \
  malet/revprx-k8s
```
