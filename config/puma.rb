#!/usr/bin/env puma

# Set the environment in which the rack's app will run. The value must be a string.
#
# The default is "development".
#
environment ENV.fetch("RAILS_ENV") { "production" }

# Configure "min" to be the minimum number of threads to use to answer
# requests and "max" the maximum.
#
# The default is "0, 16".
#
threads 1, 5

# === Cluster mode ===

# How many worker processes to run.
#
# The default is "0".
#
workers 3

# Verifies that all workers have checked in to the master process within
# the given timeout. If not the worker process will be restarted. Default
# value is 60 seconds.
#
worker_timeout 60

preload_app!
