#!/usr/bin/env ruby

require 'bundler/setup'
require 'scraper'
require 'Pry'

class TripIt < Scraper::Base
  def login(password)
    body = login_inputs
    body[:login_email_address] = @email
    body[:login_password     ] = password
    post('/account/login', body)
  end

  def logged_in?
    account_settings.body.include? "You're logged in as #{@email}"
  end

  def trips
    response = get('/trips')
    # trips_html = Nokogiri::HTML(response.body)
    trips_html = response.css('.container .trip-display .display-name').map(&:text)
  end

  private

  def account_settings
    get('/account/edit')
  end

  def login_inputs
    response     = get('/account/login')
    # html         = Nokogiri::HTML(response.body)
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

# tripit = TripIt.new('email', debug=false)
# tripit.login('password')
# tripit.logged_in? => true
# tripit.trips => [..]
# tripit.logout
# tripit.login('password')
# tripit.logged_in? => false
Pry.start(binding)
