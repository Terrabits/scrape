# Scraper

*This gem was made as an exercise in ruby. I recommend Mechanize if you are looking for a well made web scraping library*

Scraper provides a base class with http methods that automatically manage cookies. This is convenient for scraping webpages that you have to login to access.

Scraper uses HTTParty for HTTP requests. Nokogiri is used to scrape responses.

## Installation

To install Scraper via gem install:  
```bash
git clone git@github.com:Terrabits/scraper.git
cd scraper
gem build scraper.gemspec
gem install scraper-0.1.0.gem
```


To add Scraper to a Gemfile from github source:
`gem 'scrape', :git => 'git://github.com/Terrabits/scraper.git'`

## Usage

To use scrape, create a subclass of `Scrape::Base`. This subclass will automatically update and submit your cookies, which makes logging in as simple as submitting the login form.

See `examples/tripit.rb` for a simple example:

```ruby
class TripIt < Scraper::Base
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
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
