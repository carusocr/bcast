#!/usr/bin/env/ruby
=begin
Date Created: 28 Aug 2014
script creates a Twitter client and collects random twitters using REST API.

list of elements returned in status
https://dev.twitter.com/docs/platform-objects/tweets

=end

require 'yaml'
require 'twitter'
cfgfile = 'auth.cfg'

cnf = YAML::load(File.open(cfgfile))
collection = ARGV[0]
abort "Enter collection type!" unless ARGV[0]
tweet_id = ARGV[1]
datadir = cnf[collection]['datadir']

client = Twitter::REST::Client.new do |config|
  config.consumer_key       = cnf[collection]['con_key']
  config.consumer_secret    = cnf[collection]['con_sec']
  config.access_token        = cnf[collection]['o_tok']
  config.access_token_secret = cnf[collection]['o_tok_sec']
end

status = client.status(tweet_id)
if status.text?
  puts status.id, status.text
end
