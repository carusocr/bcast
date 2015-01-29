#!/usr/bin/env ruby

# wordlist.rb
# Date Created: 22 Nov 2014
# script creates a Twitter client, assembles array of most common words,
# tracks tweets matching words

# list of elements returned in status
# https://dev.twitter.com/docs/platform-objects/tweets

require 'yaml'
require 'tweetstream'
require 'json'
require 'trollop'

opts = Trollop::options do

  banner <<-EOS

Collect from Twitter's streaming API using a file of keywords as search terms. 
Script expects one word per line andrequires an auth.yml file containing app name and corresponding authentication data output information.

auth.yml format:

test:
  con_key:    'CONSUMER_KEY'
  con_sec:    'CONSUMER_SECRET'
  o_tok:      'OAUTH_TOKEN'
  o_tok_sec:  'OAUTH_TOKEN_SECRET'
  a_meth:     :oauth
  datadir:    <collection directory> 

SCRIPT USAGE:

wordlist.rb -a <appname> -i <word list>

EOS

  opt :app, "Name of Twitter app to use for collection", :short => 'a', :required => true, :type => String
  opt :infile, "File containing input word list", :short => 'i', :required => true,:type => String
  opt :lang, "ISO 639-1 code of tweet language to be collected", :short => 'l', :required => true,:type => String
  opt :checklang, "Only collect tweet if it contains a lang value that matches expected lang", :short => 'c', :default => false
  opt :nowrite, "Do not write tweets to output file", :short => 'n', :default => false
  opt :silent, "Do not print tweets as they are collected", :short => 's', :default => false
  opt :maxtweets, "Maximum number of tweets to collect", :short => 'm', :type => Integer

end

cfgfile = 'auth.yml'
collection = opts[:app]
wordlist = opts[:infile]
lang = opts[:lang]
checklang = opts[:checklang]
nowrite = opts[:nowrite]
silent = opts[:silent]
maxtweets = opts[:maxtweets] ? opts[:maxtweets] : 10000000 #arbitrary
tweetcount = 0

cnf = YAML::load(File.open(cfgfile))
datadir = cnf[collection]['datadir']
ofil = `date +%Y%m%d_%H%M`.chop + "_wordlist_#{wordlist}"

TweetStream.configure do |config|
  config.consumer_key       = cnf[collection]['con_key']
  config.consumer_secret    = cnf[collection]['con_sec']
  config.oauth_token        = cnf[collection]['o_tok']
  config.oauth_token_secret = cnf[collection]['o_tok_sec']
  config.auth_method        = cnf[collection]['a_meth']
end

searchterm = File.readlines("#{wordlist}").join(',').gsub("\n","")

unless nowrite
  tweetfile = File.open("#{datadir}/#{ofil}",'a')
end

puts "Tracking tweets in #{lang}..."
TweetStream::Client.new.filter(lang: "#{lang}",track: "#{searchterm}") do |status|
  break if tweetcount > maxtweets
  if checklang
    if (status.lang == lang)
      tweetcount+=1
      unless nowrite
        tweet = JSON.generate(status.attrs)
        tweetfile.puts tweet
      end
      puts status.text unless silent
    end
  else
    tweetcount+=1
    puts status.text unless silent
    unless nowrite
      tweet = JSON.generate(status.attrs)
      tweetfile.puts tweet
    end
  end
end

unless nowrite
  tweetfile.close
end
