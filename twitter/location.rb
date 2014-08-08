#!/usr/bin/env/ruby
=begin
sample.rb
Date Created: 18 July 2014
script creates a Twitter client and collects random twitters using sample method.

list of elements returned in status
https://dev.twitter.com/docs/platform-objects/tweets

Notes about geolocation:

Uses JSON coords, so long/lat instead of lat/long. SW corner of bounding box first, then NE:
(SWLAT,SWLONG,NELAT,NELONG)

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
  config.consumer_key       = cnf['sample']['con_key']
  config.consumer_secret    = cnf['sample']['con_sec']
  config.oauth_token        = cnf['sample']['o_tok']
  config.oauth_token_secret = cnf['sample']['o_tok_sec']
  config.auth_method        = cnf['sample']['a_meth']
end

ofil = `date +%Y%m%d_%k%M`.chop + '.txt'

#tweetfile = File.open("#{datadir}/#{ofil}",'a')

#TweetStream::Client.new.locations("#{loc}") do |status|
TweetStream::Client.new.locations(loc1,loc2) do |status|
#  puts status.place.full_name
  if status.text =~ /ebola/ || status.text =~ /die/ || status.text =~ /dyin/
    puts status.user.screen_name
    puts status.text
  end
#  tweet = JSON.generate(status.attrs)
#  tweetfile.puts tweet
end

#tweetfile.close

#can also search for keywords or by geo coords
#TweetStream::Client.new.track('philadelphia,rahmat,arzimaydi,kechirasiz,yomon') do |status|
#TweetStream::Client.new.locations('39.953510,-75.198669,39.956923,-75.193980') do |status|
# 23rd and Walnut: 39.951050, -75.178552
# 2nd and Race: 39.953748, -75.142932
# Tashkent Uzbekistan sw: 69.114261, 41.182720
# ne: 69.421191, 41.414857
# 41.209070, 69.109454
# 41.377771, 69.503589
