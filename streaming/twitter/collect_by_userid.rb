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
abort "Enter input userid list!" unless ARGV[0]
wordlist = ARGV[0]
collection = 'sample'

cnf = YAML::load(File.open(cfgfile))
datadir = cnf[collection]['datadir']
datadir = "."
ofil = `date +%Y%m%d_%H%M`.chop + "_#{wordlist}"

TweetStream.configure do |config|
  config.consumer_key       = cnf[collection]['con_key']
  config.consumer_secret    = cnf[collection]['con_sec']
  config.oauth_token        = cnf[collection]['o_tok']
  config.oauth_token_secret = cnf[collection]['o_tok_sec']
  config.auth_method        = cnf[collection]['a_meth']
end

userids = File.readlines(wordlist).join(',').gsub("\n","")
puts userids

#tweetfile = File.open("#{datadir}/#{ofil}",'a')

#TweetStream::Client.new.follow(2653928647) do |status|
TweetStream::Client.new.follow(userids) do |status|
  tweet = JSON.generate(status.attrs)
  puts status.text
#  tweetfile.puts tweet
end

#tweetfile.close

#https://api.twitter.com/1.1/users/show.xml?screen_name=crcaruso
