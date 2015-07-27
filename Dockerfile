FROM alpine
EXPOSE 80

RUN apk update \
  && apk add \
    nginx \
    ruby \
    ruby-json \
  && mkdir -p /usr/src/app

WORKDIR /usr/src/app
CMD ["./bin/run.sh"]
ENV DOMAIN k8s
ENV KUBERNETES_MASTER http://172.17.8.101:8080
ENV INTERVAL 10

COPY nginx.conf /etc/nginx/nginx.conf
COPY . /usr/src/app
RUN ln -sfT /usr/src/app/sites-available /etc/nginx/sites-enabled
