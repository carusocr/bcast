#!/usr/bin/env/ruby
=begin
ebola.rb
Date Created: 14 August 2014
morbid script that creates a Twitter client and filters for Ebola tweets from Nigeria.

list of elements returned in status
https://dev.twitter.com/docs/platform-objects/tweets

Notes about geolocation:

Uses JSON coords, so long/lat instead of lat/long.

Also - if the tweet doesn't have geolocation info BUT the location listed in the 'place' field is 
within bounding box, it will show up. Be careful with this, since if you draw a boundary box with
a little bit over a border of another country, it will also get all tweets with a 'place' value of
that country. For example, if I highlight a small section of Ukraine and a portion of the box
touches Russia, it will grab all tweets with 'Russia' listed as place as well as tweets from Ukraine.

Also, if tweets originate from outside the box but inside of Ukraine and have no coordinate data, those
would logically be caught by the client, too. Need to test this more.
=end

require 'yaml'
require 'tweetstream'
require 'json'
cfgfile = 'auth.cfg'
datadir = '.'
#loc1 = '-74,40'
#loc2 = '-73,41'
#loc = '3.098810,6.413815,3.448999,6.758964'
loc1 = '3.098810,6.413815'
loc2 = '3.448999,6.758964'

cnf = YAML::load(File.open(cfgfile))

TweetStream.configure do |config|
  config.consumer_key       = cnf['ebola']['con_key']
  config.consumer_secret    = cnf['ebola']['con_sec']
  config.oauth_token        = cnf['ebola']['o_tok']
  config.oauth_token_secret = cnf['ebola']['o_tok_sec']
  config.auth_method        = cnf['ebola']['a_meth']
end

ofil = `date +%Y%m%d_%k%M`.chop + '.txt'
keywords = 'ebola, die, dying'
countries = ['Guinea','Liberia','Nigeria','Sierra Leone']

#tweetfile = File.open("#{datadir}/#{ofil}",'a')

TweetStream::Client.new.track(keywords) do |status|
  if countries.include?(status.place.name)
    puts status.user.screen_name
    puts status.text
    puts status.place.name + "\n"
# uncomment to write to file instead of idly watching it
#  tweet = JSON.generate(status.attrs)
#  tweetfile.puts tweet
  end
end

#tweetfile.close

# 23rd and Walnut, 2nd and Race
#loc1 = '39.951050, -75.178552'
#loc2 = '39.953748, -75.142932'
# Tashkent Uzbekistan
#loc1 = '41.182720, 69.114261'
#loc2 = '41.41857, 69.421191'
# 41.209070, 69.109454
# 41.377771, 69.503589
