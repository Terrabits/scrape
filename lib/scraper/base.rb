module Scraper

  require 'HTTParty'
  require 'Nokogiri'

  class HtmlParser < HTTParty::Parser
    def html
      Nokogiri::HTML(body)
    end
  end

  class Base < HTTParty::Parser
    include HTTParty
    follow_redirects false
    parser HtmlParser # Nokogiri response mixin

    attr_accessor :username

    def initialize(username='', debug_output=false)
      @username = username
      @cookies = {}
      self.debug_output if debug_output
    end

    def debug_output(on=true)
      if on
        self.class.debug_output
      else
        self.class.debug_output nil
      end
    end

    def logout
      @cookies = Hash.new
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

end
