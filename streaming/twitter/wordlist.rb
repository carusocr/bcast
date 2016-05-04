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
Script expects one word per line and requires an auth.yml file containing app name and corresponding authentication data output information.

auth.yml format:

test:
  con_key:    'CONSUMER_KEY'
  con_sec:    'CONSUMER_SECRET'
  o_tok:      'OAUTH_TOKEN'
  o_tok_sec:  'OAUTH_TOKEN_SECRET'
  a_meth:     :oauth
  datadir:    <collection directory> 

SCRIPT USAGE:

wordlist.rb -a <appname> -i <word list> -l <language code>

EOS

  opt :app, "Name of Twitter app to use for collection", :short => 'a', :required => true, :type => String
  opt :infile, "File containing input word list", :short => 'i', :required => true,:type => String
  opt :lang, "ISO 639-1 code of tweet language to be collected", :short => 'l', :required => true,:type => String
  opt :checklang, "Only collect tweet if it contains a lang value that matches expected lang", :short => 'c', :default => false
  opt :nowrite, "Do not write tweets to output file", :short => 'n', :default => false
  opt :idfile, "Write tweet IDs to separate output file", :default => true
  opt :silent, "Do not print tweets as they are collected", :short => 's', :default => false
  opt :maxtweets, "Maximum number of tweets to collect", :short => 'm', :type => Integer
	opt :exclude_english, "Ignore any tweets tagged as English", :default => false

end

cfgfile = 'auth.yml'
collection = opts[:app]
wordlist = opts[:infile]
lang = opts[:lang]
checklang = opts[:checklang]
nowrite = opts[:nowrite]
idfile = opts[:idfile]
silent = opts[:silent]
maxtweets = opts[:maxtweets] ? opts[:maxtweets] : 10000000 #arbitrary
exclude_english = opts[:exclude_english]
tweetcount = 0

cnf = YAML::load(File.open(cfgfile))
datadir = cnf[collection]['datadir']
ofil_type = (wordlist =~ /hashtag/) ? "hashtag" : "wordlist"
ofil = `date +%Y%m%d_%H%M`.chop + "_#{ofil_type}_#{lang}.json"
id_ofil = `date +%Y%m%d_%H%M`.chop + "_#{ofil_type}_#{lang}_id.txt"

TweetStream.configure do |config|
  config.consumer_key       = cnf[collection]['con_key']
  config.consumer_secret    = cnf[collection]['con_sec']
  config.oauth_token        = cnf[collection]['o_tok']
  config.oauth_token_secret = cnf[collection]['o_tok_sec']
  config.auth_method        = cnf[collection]['a_meth']
end

def kill_sample(doomed_lang,ofil_type)
	# ps command will find any instance of wordlist, ignoring the grep and this ruby process, and kill it in order to start a new process
	type_filter = ofil_type == "hashtag" ? "hashtag" : "-v hashtag" #don't kill hashtags if starting wordlist
  targets = (`ps -ef | grep -v grep | grep 'ruby ' | grep 'wordlist.rb' | grep ' #{doomed_lang} ' | grep -v #{$$} | grep #{type_filter} | awk '{print $2}'`).split
  targets.each do |t|
    puts "Killing process #{t}, existing wordlist process...\n"
    Process.kill("KILL",t.to_i)
  end
end

searchterm = File.readlines("#{wordlist}").join(',').gsub("\n","")

kill_sample(lang,ofil_type)

unless nowrite
  tweetfile = File.open("#{datadir}/#{ofil}",'a')
end
if idfile
	puts 'writing to idfile'
	tweet_id_file = File.open("#{datadir}/#{id_ofil}",'a')
end

puts "Tracking tweets in #{lang}..."
TweetStream::Client.new.filter(lang: "#{lang}",track: "#{searchterm}") do |status|
  break if tweetcount >= maxtweets
  if checklang
    if (status.lang == lang)
      tweetcount+=1
      unless nowrite 
        tweet = JSON.generate(status.attrs)
        tweetfile.puts tweet
      end
			if idfile
				tweet_id_file.puts status.id
			end
      puts status.text unless silent
    end
  else
    tweetcount+=1
    puts status.text unless silent
    unless nowrite || (status.lang == "en" && exclude_english)
      tweet = JSON.generate(status.attrs)
      tweetfile.puts tweet
    end
		if idfile
			tweet_id_file.puts status.id
		end
  end
end

unless nowrite
  tweetfile.close
	tweet_id_file.close
end
