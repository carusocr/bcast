#!/usr/bin/env ruby
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

require 'rubygems'
require 'yaml'
require 'tweetstream'
cfgfile = 'auth.yml'

cnf = YAML::load(File.open(cfgfile))
abort "Enter 2-digit language code to track, or 'sample'!" unless ARGV[0]
abort "Enter collection type!" unless ARGV[1]
lang_to_track = ARGV[0]
collection = ARGV[1]
maxtweets = ARGV[2] ? ARGV[2] : 1000000
datadir = cnf[collection]['datadir']
tweetcount = 0

def kill_sample(lang_to_track)
	targets = (`ps -ef | grep -v grep | grep 'ruby ' | grep 'sample.rb' | grep #{lang_to_track} | grep -v #{$$} | awk '{print $2}'`).split
	targets.each do |t|
		puts "Killing process #{t}, existing sample process...\n"
		Process.kill("KILL",t.to_i)
	end
end

if ARGV[3] && ARGV[3] == 'kill'
	kill_sample(lang_to_track)
	exit
end

TweetStream.configure do |config|
  config.consumer_key       = cnf[collection]['con_key']
  config.consumer_secret    = cnf[collection]['con_sec']
  config.oauth_token        = cnf[collection]['o_tok']
  config.oauth_token_secret = cnf[collection]['o_tok_sec']
  config.auth_method        = cnf[collection]['a_meth']
end

ofil = `date +%Y%m%d_%H%M`.chop + "_#{lang_to_track}"
id_dir = "/lorelei_rl/collection/id_lists"

tweetfile = File.open("#{datadir}/#{ofil}.json",'a')
idfile = File.open("#{id_dir}/#{ofil}_ids.txt",'a')

puts "Tracking #{lang_to_track}..."
TweetStream::Client.new.sample do |status|
	if lang_to_track == 'sample' #if sample, grab everything
		puts status.text
		tweet = JSON.generate(status.attrs)
		tweetfile.puts tweet
		idfile.puts status.id
		tweetcount += 1
	end
	if status.lang == lang_to_track
		puts status.text
		puts status.id
		tweet = JSON.generate(status.attrs)
		tweetfile.puts tweet
		idfile.puts status.id
		tweetcount += 1
	end
end

tweetfile.close
idfile.close
