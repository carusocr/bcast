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

<div class="js-tweet-text-container">
  <p class="TweetTextSize  js-tweet-text tweet-text" lang="en" data-aria-label-part="0">Babys first <strong>sushi</strong> <strong>burrito</strong>?!!!???? <a href="https://t.co/C94oypubtz" class="twitter-timeline-link u-hidden" data-pre-embedded="true" dir="ltr" >pic.twitter.com/C94oypubtz</a></p>
</div>

<div>
data-tweet-id seems pretty promising

page.first(:xpath,"//div[@data-tweet-id]").text

this finds all tweet IDs on page but is intolerably slow...although maybe the slowness is actually
useful for dealing with rate limits?

page.all(:xpath,"//div").each do |d|
  puts d['data-tweet-id'] if d['data-tweet-id']  
end  

AHA!

page.first(:xpath,"//div[@data-tweet-id]")['data-tweet-id']

So resize first to get a shitload of tweets?
page.driver.browser.manage.window.resize_to(1000,8000)


=end

require 'capybara'
require 'pry'
require 'capybara/poltergeist'

searchterm = ARGV[0]
startdate = ARGV[1]
untildate = ARGV[2]

searchpage = "https://twitter.com/search?l=&q=#{searchterm}%20since%3A#{startdate}%20until%3A#{untildate}&src=typd&lang=en"

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
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
