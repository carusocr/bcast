#!/usr/bin/env/ruby
=begin
Date Created: 28 Aug 2014
script creates a Twitter client and collects random twitters using REST API.

list of elements returned in status
https://dev.twitter.com/docs/platform-objects/tweets

=end

require 'yaml'
require 'twitter'
require 'trollop'
cfgfile = 'auth.cfg'

cnf = YAML::load(File.open(cfgfile))
collection = ARGV[0]
abort "Enter collection type!" unless ARGV[0]
tweet_id = ARGV[1] =~ /[a-z]/ ? ARGV[1] :ARGV[1].to_i #keep as string if username 

=begin
opts = Trollop::options do
  banner <<-EOS

Collect all tweets matching either user IDs or tweet IDs from input file.

Usage: grab_tweets.rb <-u|-t|-n> -i <input file> -o <output file>

Input file must be a list of numerical Twitter user IDs if -u is specified,
a list of usernames if -n is specified, or a list of tweet IDs if -t is specified.
Default list type is user ID.

EOS

  opt :userid, "Collect by user id number", :short => 'u'
  opt :tweetlist, "Collect by tweet id", :short => 't', :default => false
  opt :username, "Collect by username", :short => 'n', :default => false
  opt :infile, "Input list of user ids or names", :short => 'i', :type => String
  opt :collection, "Collection type i.e. 'uzbek'", :short => 'c', :type => String

end
puts opts[:username]
exit
=end

datadir = cnf[collection]['datadir']

client = Twitter::REST::Client.new do |config|
  config.consumer_key       = cnf[collection]['con_key']
  config.consumer_secret    = cnf[collection]['con_sec']
  config.access_token        = cnf[collection]['o_tok']
  config.access_token_secret = cnf[collection]['o_tok_sec']
end

def collect_single_tweet(tweet_id,client)
  status = client.status(tweet_id)
  if status.text?
    tweet_time = status.created_at.strftime("%Y%m%d_%H%M%S %z")
    tweet_id = status.id
    tweet_user = status.user.id
    tweet_text = status.text.gsub("\t","").gsub("\n","")
    puts "#{tweet_id}\t#{tweet_time}\t#{tweet_user}\t#{tweet_text}\n"
  end
end
#status = client.status(tweet_id)
#if status.text?
#  puts status.id, status.text
#end

#testing out paging through user timelines

def collect_with_max_id(collection=[], max_id=nil, &block)
  response = yield max_id
  collection += response
  response.empty? ? collection.flatten : collect_with_max_id(collection, response.last.id - 1, &block)
end

def grab_tweet(status)
  status.each do |t|
    tweet_time = t.created_at.strftime("%Y%m%d_%H%M%S %z")
    tweet_id = t.id
    tweet_user = t.user.id
    tweet_text = t.text.gsub("\t","").gsub("\n","")
    puts "#{tweet_id}\t#{tweet_time}\t#{tweet_user}\t#{tweet_text}\n"
  end
end

def fetch_all_tweets(user,client)
  collect_with_max_id do |max_id|
    options = {:count => 200, :include_rts => true}
    options[:max_id] = max_id unless max_id.nil?
    status = client.user_timeline(user, options)
    grab_tweet(status)
  end
end

#fetch_all_tweets(tweet_id,client)
collect_single_tweet(tweet_id,client)
