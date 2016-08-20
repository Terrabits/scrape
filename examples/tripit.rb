#!/usr/bin/env ruby

require 'bundler/setup'
require 'scraper'
require 'Pry'

class TripIt < Scraper::Base
  base_uri 'https://www.tripit.com'

  def login(password)
    body = login_inputs
    body[:login_email_address] = @username
    body[:login_password     ] = password
    post('/account/login', body)
    logged_in?
  end

  def logged_in?
    account_settings.body.include? "You're logged in as #{@username}"
  end

  def trips
    response = get('/trips')
    trips_html = response.css('.container .trip-display .display-name').map(&:text)
  end

  private

  def account_settings
    get('/account/edit')
  end

  def login_inputs
    response     = get('/account/login')
    input_fields = response.css('.container #authenticate input')
    inputs_hash  = Hash.new
    input_fields.each do |i|
      name       = i["name"].to_sym
      value      = i["value"]
      inputs_hash[name] = value
    end
    inputs_hash
  end
end

# tripit = TripIt.new
# tripit.username = 'email@example.com'
# tripit.login('password') => true
# tripit.logged_in?        => true
# tripit.trips             => [..]
# tripit.logout
# tripit.logged_in?        => false
Pry.start(binding)
