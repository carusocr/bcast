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

RESOURCES:

Resizable rectangles with lat/long...use for location search?
https://developers.google.com/maps/documentation/javascript/examples/rectangle-event

Simple markers - use these with each tweet, title calls text of tweet? Maybe hash of coords => text?
https://developers.google.com/maps/documentation/javascript/examples/marker-simple
=end

require 'yaml'
require 'tweetstream'
require 'json'
cfgfile = 'auth.cfg'
datadir = '.'
loc1 = '3.098810,6.413815'
loc2 = '3.448999,6.758964'
points = []

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
countries = ['Guinea','Liberia','Nigeria','Sierra Leone','Ghana','Togo','Benin','Cameroon','Burkina Faso','Ivory Coast']

#tweetfile = File.open("#{datadir}/#{ofil}",'a')

TweetStream::Client.new.track(keywords) do |status|
  if countries.include?(status.place.name)
    pointfile = File.open('tweebolas','a')
    #puts status.user.screen_name
    #puts status.text
    #puts status.place.name + "\n"
    tweet = JSON.generate(status.attrs)
    contents = JSON.parse(tweet)
    pt1 = contents['coordinates']['coordinates'][1]
    pt2 = contents['coordinates']['coordinates'][0]
    user = contents['user']['screen_name']
    tweet = contents['text'].gsub("\t","").gsub("\n","")
    #coord = "#{pt1}\t#{pt2}"
    tweetstring = "#{pt1}\t#{pt2}\t#{user}\t#{tweet}\n"
    puts tweetstring
    pointfile.write tweetstring
    pointfile.close
  end
end

#tweetfile.close
