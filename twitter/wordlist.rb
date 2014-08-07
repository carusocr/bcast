#!/usr/bin/env/ruby

# sample.rb
# Date Created: 18 July 2014
# script creates a Twitter client, assembles array of most common words,
# tracks tweets matching words
# NOT unique IDs, need to postprocess

# list of elements returned in status
# https://dev.twitter.com/docs/platform-objects/tweets

require 'yaml'
require 'tweetstream'
require 'json'
cfgfile = 'auth.cfg'
abort "Enter collection type!" unless ARGV[0]
collection = ARGV[0]
wordlist = collection + ".txt"

cnf = YAML::load(File.open(cfgfile))
datadir = cnf[collection]['datadir']
ofil = `date +%Y%m%d_%H%M`.chop + "_#{collection}.txt"

TweetStream.configure do |config|
  config.consumer_key       = cnf[collection]['con_key']
  config.consumer_secret    = cnf[collection]['con_sec']
  config.oauth_token        = cnf[collection]['o_tok']
  config.oauth_token_secret = cnf[collection]['o_tok_sec']
  config.auth_method        = cnf[collection]['a_meth']
end

searchterm = File.readlines("#{wordlist}").join(',').gsub("\n","")
#searchterm = 'RT'

tweetfile = File.open("#{datadir}/#{ofil}",'a')

#looks like sampling by lang doesn't return anything that isn't in sample set...duh
#TweetStream::Client.new.sample(language: 'tr') do |status|
#TweetStream::Client.new.sample do |status|
TweetStream::Client.new.track("#{searchterm}") do |status|
  tweet = JSON.generate(status.attrs)
  tweetfile.puts tweet
end

tweetfile.close

#can also search for keywords or by geo coords
#TweetStream::Client.new.track('philadelphia,rahmat,arzimaydi,kechirasiz,yomon') do |status|
#TweetStream::Client.new.locations('39.953510,-75.198669,39.956923,-75.193980') do |status|
