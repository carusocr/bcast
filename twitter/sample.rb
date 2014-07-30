#!/usr/bin/env/ruby

# sample.rb
# Date Created: 18 July 2014
# script creates a Twitter client and collects random twitters using sample method.

# list of elements returned in status
# https://dev.twitter.com/docs/platform-objects/tweets

require 'yaml'
require 'tweetstream'
require 'json'
cfgfile = 'auth.cfg'
datadir = '/media/181cf896-8dc3-40f6-8fcc-6b3513d78153/tweets'

cnf = YAML::load(File.open(cfgfile))

TweetStream.configure do |config|
  config.consumer_key       = cnf['sample']['con_key']
  config.consumer_secret    = cnf['sample']['con_sec']
  config.oauth_token        = cnf['sample']['o_tok']
  config.oauth_token_secret = cnf['sample']['o_tok_sec']
  config.auth_method        = cnf['sample']['a_meth']
end

ofil = `date +%Y%m%d_%k%M`.chop + '.txt'

tweetfile = File.open("#{datadir}/#{ofil}",'a')

#looks like sampling by lang doesn't return anything that isn't in sample set...duh
#TweetStream::Client.new.firehose(language='tr') do |status|
TweetStream::Client.new.sample do |status|
#TweetStream::Client.new.track(language: 'tr') do |status|
  tweet = JSON.generate(status.attrs)
  tweetfile.puts tweet
end

tweetfile.close

#can also search for keywords or by geo coords
#TweetStream::Client.new.track('philadelphia,rahmat,arzimaydi,kechirasiz,yomon') do |status|
#TweetStream::Client.new.locations('39.953510,-75.198669,39.956923,-75.193980') do |status|
