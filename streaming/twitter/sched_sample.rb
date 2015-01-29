#!/usr/bin/env ruby

require 'yaml'
require 'tweetstream'

cfgfile = 'auth.yml'

cnf = YAML::load(File.open(cfgfile))
lang_to_track = ARGV[0] ? ARGV[0] : 'sample'
collection = ARGV[1]
abort "Enter 2-digit language code to track, or 'sample'!" unless ARGV[0]
abort "Enter collection type!" unless ARGV[1]
datadir = cnf[collection]['datadir']
tweetmax = 1000

TweetStream.configure do |config|
  config.consumer_key       = cnf[collection]['con_key']
  config.consumer_secret    = cnf[collection]['con_sec']
  config.oauth_token        = cnf[collection]['o_tok']
  config.oauth_token_secret = cnf[collection]['o_tok_sec']
  config.auth_method        = cnf[collection]['a_meth']
end

ofil = `date +%Y%m%d_%H%M`.chop + "_#{lang_to_track}.json"

#tweetfile = File.open("#{datadir}/#{ofil}",'a')

def collect_lang_from_sample(lang_to_track,tweetmax)
  tweetcount = 0
  TweetStream::Client.new.sample(language: "#{lang_to_track}") do |status|
    tweetcount+=1
    if tweetcount > tweetmax
      break
    end
    puts status.text
    puts tweetcount
#    tweet = JSON.generate(status.attrs)
#    tweetfile.puts tweet
  end
end

collect_lang_from_sample(lang_to_track,tweetmax)
