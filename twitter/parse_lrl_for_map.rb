#!/usr/bin/env ruby

require 'json'
require 'time'

abort "Enter JSON input file!" unless ARGV[0]
infile = ARGV[0]
DATADIR = "."
old_day = ""
json_array = File.readlines(infile)
json_array.each do |t|
  tweet = JSON.parse(t)
  #check if tweet has coordinate data, skip if not
  if tweet['coordinates'].nil?
    next
  end
  tweet_time = Time.parse(tweet['created_at']).strftime("%Y%m%d_%H%M%S %z")
  new_day = tweet_time[/\d{8}/]
  if new_day != old_day #switch outfile if tweet is from next day
    old_day = new_day
    file = File.open("#{DATADIR}/#{old_day}.tdf","a")
    puts "Output day switched to #{old_day}"
    file.close
  end
  file = File.open("#{DATADIR}/#{old_day}.tdf","a")
  tweet_id = tweet['id']
  tweet_long = tweet['coordinates']['coordinates'][0]
  tweet_lat = tweet['coordinates']['coordinates'][1]
  tweet_user = tweet['user']['id']
  tweet_text = tweet['text'].gsub("\t"," ").gsub("\n"," ")
#  puts "#{tweet_id}\t#{tweet_time}\t#{tweet_user}\t#{tweet_text}"
  file.write("#{tweet_lat}\t#{tweet_long}\t#{tweet_user}\t#{tweet_text}\n")
end
