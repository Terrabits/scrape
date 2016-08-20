#!/usr/bin/env ruby

require 'bundler/setup'
require 'scraper/../examples/tripit'

tripit = TripIt.new
tripit.username = ARGV[0]
tripit.login(ARGV[1])
puts tripit.trips
