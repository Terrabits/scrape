#!/usr/bin/env ruby

require 'HTTParty'
require 'Nokogiri'
require 'Pry'

class TripIt
  include HTTParty
  base_uri 'https://www.tripit.com'
  follow_redirects false
  # debug_output

  def initialize(email, password)
    @email = email
    @cookies = {}

    # Get login
    get_response = self.class.get('/account/login')
    update_cookies(get_response.headers['Set-Cookie'])
    get_html = Nokogiri::HTML(get_response.body)
    auth_inputs   = get_html.css('.container').css('#authenticate').css('input')

    # Post login
    body = {}
    auth_inputs.each do |i|
      name       = i["name"].to_sym
      value      = i["value"]
      body[name] = value
    end
    body[:login_email_address] = email
    body[:login_password     ] = password
    post_response = self.class.post(
      '/account/login',
      body: body,
      headers: {'Cookie' => cookie_string }
    )
    update_cookies(post_response.headers['Set-Cookie'])
  end

  def logged_in?
    account_settings.include? "You're logged in as #{@email}"
  end

  def trips
    response = self.class.get('/trips', headers: {'Cookie' => cookie_string})
    update_cookies(response.headers['Set-Cookie'])
    trips_html = Nokogiri::HTML(response.body)
    trips_html.css('.container .trip-display .display-name').map(&:text)
  end

  private

  def account_settings
    response = self.class.get('/account/edit', headers: {'Cookie' => cookie_string})
    update_cookies(response.headers['Set-Cookie'])
    response
  end

  def update_cookies(resp)
    it_ref_id  = /it_ref_id=\w+;/ .match(resp).to_s[0..-2].split('=')[1]
    it_csrf    = /it_csrf=\w+;/   .match(resp).to_s[0..-2].split('=')[1]
    lbsession  = /lbsession=.+=;/ .match(resp).to_s[0..-2].split('=')[1]
    session_id = /session_id=\w+;/.match(resp).to_s[0..-2].split('=')[1]
    it_session_id = /it_session_id=.+; /.match(resp).to_s[0..-2].split('=')[1]

    if it_ref_id
      @cookies[:it_ref_id] = it_ref_id
    end
    if it_csrf
      @cookies[:it_csrf] = it_csrf
    end
    if lbsession
      lbsession += "="
      @cookies[:lbsession] = lbsession
    end
    if session_id
      @cookies[:session_id] = session_id
    end
    if it_session_id
      @cookies[:it_session_id] = it_session_id
    end
  end

  def cookie_string
    strings = []
    @cookies.each do |key, value|
      strings << "#{key.to_s}=#{value}"
    end
    strings.join("; ")
  end
end

tripit = TripIt.new('nick.lalic@gmail.com','')
Pry.start(binding)
