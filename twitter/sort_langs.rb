#!/usr/bin/env ruby
# encoding: utf-8

require  'json'
$ofil_stem = "/twitter_0002/incoming/langs"
newlang_dirstem = "/twitter_0001"
yesterday = `date -d 'yesterday' +%Y%m%d`.chomp
yesterday_ifil = "/twitter_0002/incoming/sample_stream/" + yesterday + "_0130_sample.json"
#run on previous day's sample file before zip cronjob runs, unless specific file is provided
ifil = ARGV[0] ? ARGV[0] : yesterday_ifil
$ofil_datestamp = ifil[/\d{8}_\d{4}/]
$tweet_lang_hash = Hash.new {|h,k| h[k]=[]} #seed hash of arrays
$tweet_id_hash = Hash.new {|h,k| h[k]=[]} #seed hash of arrays
file_counter = 0
def purge_tweet_hashes()
	#get Twitter-supplied lang keys from hash. Loop over each and write tweet arrays to ofil.
	$tweet_lang_hash.keys.each do |k|
		#check for existence of langdir, create one and link if not
		unless File.directory?("#{$ofil_stem}/#{k}")
			puts "Found no dir for Twitter langcode #{k}. Making one!"
			Dir.mkdir("#{newlang_dirstem}/#{k}")
			File.symlink("#{newlang_dirstem}/#{k}", "#{$ofil_stem}/#{k}")
		end
		tweetfile = File.open("#{$ofil_stem}/#{k}/#{$ofil_datestamp}_#{k}.json",'a')
		puts "We got #{$tweet_lang_hash[k].length} tweets in #{k}!"
		tweetfile.puts $tweet_lang_hash[k]
		tweetfile.close
    tweet_id_file = File.open("#{$ofil_stem}/#{k}/#{$ofil_datestamp}_#{k}_id.txt",'a')
    tweet_id_file.puts $tweet_id_hash[k]
    tweet_id_file.close
	end
	$tweet_lang_hash = Hash.new {|h,k| h[k]=[]} #seed hash of arrays
	$tweet_id_hash = Hash.new {|h,k| h[k]=[]} #seed hash of arrays
end
File.open(ifil).each_line do |l|
	tweet = JSON.parse(l)
	#strip off subtags
	#testing nil values
	if tweet['lang']
		lang_tag = tweet['lang'].sub(/-.*/,"")
		#originally excluded english tweets, switched to keep them
		$tweet_lang_hash[lang_tag] << tweet.to_s
		$tweet_id_hash[lang_tag] << tweet['id']
	else
		puts "got nil tag?\n"
		puts tweet
	end
	file_counter += 1
	if file_counter > 100000
		purge_tweet_hashes()
		file_counter = 0
	end
end
#run final purge after file is finished readlining
purge_tweet_hashes()


# To-do list:
# 1. Add file compression
# 2. Auto spreadsheet generation for tweets filtered
