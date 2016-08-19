#!/usr/bin/env ruby

require 'HTTParty'
require 'Nokogiri'
require 'Pry'

page       = HTTParty.get('https://example.com')
parse_page = Nokogiri::HTML(page)

# ...

Pry.start(binding)
