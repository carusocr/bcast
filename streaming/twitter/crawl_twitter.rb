#!/usr/bin/env ruby

=begin

Script that uses capybara to crawl Twitter's advanced search page and return lists of tweet IDs
to pass to grab_tweets.rb. Parameters should be keyword file and end_date.

MH17 OR Donetsk
since 2013-01-01
until 2014-10-07


https://twitter.com/search?l=&q=MH17%20OR%20Donetsk%20since%3A2013-01-01%20until%3A2014-10-07&src=typd&lang=en

https://twitter.com/search?l=&q=%22sushi%20burrito%22&src=typd&lang=en

You can search for multiple phrases by entering:
'sushi burrito' OR 'sushi dinner' into the "All of these words" box, but it can return tweets
where the words in the phrase aren't necessarily in the position specified.

page.first(:xpath,"//div[@data-tweet-id]")['data-tweet-id']

So resize first to get a shitload of tweets?
web.driver.resize_window(1000,8000) #poltergeist version  
page.driver.browser.manage.window.resize_to(1000,8000) #selenium

=end

require 'capybara'
require 'selenium/webdriver'
require 'pry'
#require 'capybara/poltergeist'

=begin
searchterm = ARGV[0]
startdate = ARGV[1]
untildate = ARGV[2]
=end

#searchpage = "https://twitter.com/search?l=&q=#{searchterm}%20since%3A#{startdate}%20until%3A#{untildate}&src=typd&lang=en"

searchpage = 'https://twitter.com/search?l=&q=%22sushi%20burrito%22&src=typd&lang=en'
#Capybara.javascript_driver = :selenium_chrome_headless
#Capybara.default_driver = :selenium_chrome_headless

Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new(
    args: %w[headless disable-gpu]
  )
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.javascript_driver = :chrome
Capybara.default_driver = :chrome

binding.pry

=begin
Capybara.register_driver(:poltergeist) do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false,
    phantomjs_options: ['--ignore-ssl-errors=yes', '--ssl_protocol=any'])
end

web = Capybara.current_session
=end
