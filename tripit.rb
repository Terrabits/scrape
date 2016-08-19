#!/usr/bin/env ruby

require 'HTTParty'
require 'Nokogiri'
require 'Pry'

class HtmlParserIncluded < HTTParty::Parser
  def html
    Nokogiri::HTML(body)
  end
end

class TripIt
  include HTTParty
  base_uri 'https://www.tripit.com'
  follow_redirects false
  parser HtmlParserIncluded # Nokogiri response mixin

  attr_accessor :email

  def initialize(email, password, debug_output=false)
    @email = email
    @cookies = {}
    self.debug_output if debug_output

    login(password)
  end

  def debug_output(on=true)
    if on
      self.class.debug_output
    else
      self.class.debug_output nil
    end
  end

  def login(password)
    body = login_inputs
    body[:login_email_address] = @email
    body[:login_password     ] = password
    post('/account/login', body)
  end

  def logout
    @cookies = Hash.new
  end

  def logged_in?
    account_settings.body.include? "You're logged in as #{@email}"
  end

  def trips
    response = get('/trips')
    # trips_html = Nokogiri::HTML(response.body)
    trips_html = response.css('.container .trip-display .display-name').map(&:text)
  end

  def get(url)
    response = self.class.get(url, headers: headers)
    update_cookies(response)
    response
  end

  def post(url, body)
    response = self.class.post(url, body: body, headers: headers)
    update_cookies(response)
    response
  end

  private

  def account_settings
    get('/account/edit')
  end

  def update_cookies(response)
    fields = response.headers.get_fields('Set-Cookie')
    return if !fields
    fields.each do |f|
      text  = /\w+=[^;]+;/.match(f).to_s[0..-2]
      eq    = text.index('=')
      name  = text[0..eq-1].to_sym
      value = text[eq+1..-1]
      @cookies[name] = value
    end
  end

  def cookie_string
    c_hash = CookieHash.new
    @cookies.each do |name, value|
      c_hash.add_cookies("#{name.to_s}=#{value}")
    end
    c_hash.to_cookie_string
  end

  def headers
    if !@cookies.empty?
      {'Cookie' => cookie_string}
    else
      {}
    end
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

# tripit = TripIt.new('email','password', debug=false)
Pry.start(binding)
