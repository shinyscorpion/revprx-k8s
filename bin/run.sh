#!/bin/sh

./vhosts-gen.rb &
nginx -g "daemon off;"
