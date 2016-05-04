#!/usr/bin/env/ruby
=begin
Date Created: 28 Aug 2014
script creates a Twitter client and collects tweets.
list of elements returned in status
https://dev.twitter.com/docs/platform-objects/tweets

=end


require 'yaml'
require 'twitter'
require 'trollop'
opts = Trollop::options do

  banner <<-EOS

Collect from Twitter using a file of usernames or tweet IDs as source.
Script expects either a list of numerical tweet IDs or or alphabetical user names.
If any alphabetic characters are detected it will default to user-based collection.
Script requires an auth.yml file containing app name and corresponding authentication data output information.
Writes JSON to stdout, or tweet ID + text if -s flag is set. Either way, pipe to an outfile!

auth.yml format:

test:
  con_key:    'CONSUMER_KEY'
  con_sec:    'CONSUMER_SECRET'
  o_tok:      'OAUTH_TOKEN'
  o_tok_sec:  'OAUTH_TOKEN_SECRET'
  a_meth:     :oauth
  datadir:    <collection directory> 

SCRIPT USAGE:

grab_tweets.rb -a <appname> -i <tweet_id_file|tweet_username_file>

EOS

  opt :app, "Name of Twitter app to use for collection", :short => 'a', :required => true, :type => String
  opt :infile, "File containing input word list", :short => 'i', :required => true,:type => String
	opt :simple, "Output only tweet ID and text", :short => 's', :default => false
	opt :exclude_short, "Exclude any short tweets containing a URL", :default => false
	opt :exclude_english, "Exclude any tweets tagged as English", :default => false
	opt :listfile, "Output a listfile", :short => 'l', :type => String
end

cfgfile = 'auth.yml'
collection = opts[:app]
$infile = opts[:infile]
$simple_output = opts[:simple]
$exclude_english = opts[:exclude_english]
$exclude_short = opts[:exclude_short]
$listfile = opts[:listfile]

cnf = YAML::load(File.open(cfgfile))
collect_users = File.readlines($infile).grep(/[a-z]/i).any?
$tweet_ids=[]

$client = Twitter::REST::Client.new do |config|
  config.consumer_key       = cnf[collection]['con_key']
  config.consumer_secret    = cnf[collection]['con_sec']
  config.access_token        = cnf[collection]['o_tok']
  config.access_token_secret = cnf[collection]['o_tok_sec']
end

def collect_with_max_id(collection=[], max_id=nil, &block)
  response = yield max_id
  collection += response
  response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
end

def grab_tweets
	statuses = $client.statuses($tweet_ids)
	statuses.each do |t|
		if $simple_output
			puts "#{t.id}\t#{t.text.gsub("\n","")}"
		else
			puts JSON.generate(t.attrs)
		end
		if $listfile
			$tweet_id_file.puts t.id
		end
	end
end

def collect_by_userid
	File.readlines($infile).each do |f|
		begin
	  	collect_with_max_id do |max_id|
				options = {:count => 200, :include_rts => true}
				options[:max_id] = max_id unless max_id.nil?
 	  		status = $client.user_timeline(f, options)
 	  		status.each do |t|
					# skip tweet if it's in English and we're excluding en tweets
					if (t.lang == 'en' && $exclude_english) || (t.text.length < 50 && t.text =~ /http/ && $exclude_short)
						next
					end
					if $simple_output
						puts "#{t.id}\t#{t.text}"
					else
						puts JSON.generate(t.attrs)
					end
				end
			end
		rescue Twitter::Error::NotFound
			#user doesn't actually exist
			next
		end
		#got hit with a rate limit after 5 users...sleep 3 mins per? Ugh.
 	  sleep 180
	end
end

def collect_by_tweetid
	if $listfile
		$tweet_id_file = File.open($listfile,'a')
	end
	File.readlines($infile).each do |f|
 	 $tweet_ids << f
 	 if $tweet_ids.length == 100
 	   grab_tweets
 	   $tweet_ids.clear
 	   sleep 16 #tiptoe past API rate limit of 60/15m
 	 end
	end
#collect anything left over
	if $tweet_ids.length > 0
 	 grab_tweets
	end
end

if collect_users
	collect_by_userid
else
	collect_by_tweetid
end
