#!/usr/bin/env ruby

require 'json'
require 'time'

abort "Enter input JSON file!" unless ARGV[0]
abort "Enter language!" unless ARGV[1]
infile = ARGV[0]
language = ARGV[1]
filetail = infile[/\d{8}_\d{4}_(.+)\./,1]
#DATADIR = "/LRLBOLT/data/#{language}/raw_data_dumps/twitter"
DATADIR="."
old_day = ""
json_array = File.readlines(infile)
json_array.each do |t|
  tweet = JSON.parse(t)
  tweet_time = Time.parse(tweet['created_at']).strftime("%Y%m%d_%H%M%S %z")
  new_day = tweet_time[/\d{8}/]
  if new_day != old_day #switch outfile if tweet is from next day
    old_day = new_day
    file = File.open("#{DATADIR}/#{old_day}_#{filetail}.tdf","a")
    file.write("tweet_id\ttweet_time\ttweet_user\ttweet_text\n")
    puts "Output day switched to #{old_day}"
    file.close
  end
  file = File.open("#{DATADIR}/#{old_day}_#{filetail}.tdf","a")
  tweet_id = tweet['id']
  tweet_user = tweet['user']['id']
  tweet_text = tweet['text'].gsub("\t"," ").gsub("\n"," ")
#  puts "#{tweet_id}\t#{tweet_time}\t#{tweet_user}\t#{tweet_text}"
  file.write("#{tweet_id}\t#{tweet_time}\t#{tweet_user}\t#{tweet_text}\n")
end

