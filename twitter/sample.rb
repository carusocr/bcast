#!/usr/bin/env/ruby

# sample.rb
# Date Created: 18 July 2014
# script creates a Twitter client and collects random twitters using sample method.

require 'yaml'
require 'tweetstream'
require 'json'
cfgfile = 'auth.cfg'
cnf = YAML::load(File.open(cfgfile))

TweetStream.configure do |config|
  config.consumer_key       = cnf['con_key']
  config.consumer_secret    = cnf['con_sec']
  config.oauth_token        = cnf['o_tok']
  config.oauth_token_secret = cnf['o_tok_sec']
  config.auth_method        = cnf['a_meth']
end

ofil = `date +%Y%m%d_%k%M`

tweetfile = File.open("#{datadir}/#{ofil}",'a')

TweetStream::Client.new.sample do |status|
  tweet = JSON.generate(status.attrs)
  tweetfile.puts tweet
end

tweetfile.close

#can also search for keywords or by geo coords
#TweetStream::Client.new.track('philadelphia,rahmat,arzimaydi,kechirasiz,yomon') do |status|
#TweetStream::Client.new.locations('39.953510,-75.198669,39.956923,-75.193980') do |status|
