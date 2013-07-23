#!/usr/bin/env ruby

=begin

Script to download youtube videos, including all videos from a user's channel. 

1. Script gets previous day's scouted youtube clips, builds hash of urls and uses db ids as fileroots.
2. Checks if any have the 'get channel' flag set, builds array of UNIQUE usernames.
3. Calls download_youtube for each download url in first array.
3a. Download method should first check data directory to make sure that output file doesn't exist.
3b. Downloads clip.
3c. Checks filetype, updates database with value.
4, For array of userchannel clips, need to make sure that none are already in db.
5. Once this is done, need to create vscout_url entry for each clip to be downloaded, BEFORE downloading.
6. After this is done follow steps 3a-3c.
7. Postprocessing happens later...codec, md5sum, duration. Maybe do it right after downloads?


select id, url from vscout_url where page_url like '%yout%' and (media_file is NULL or media_file not like '%HVC%' and date_found like concat(curdate() - interval 1 day, '%') and parent_url is null order by date_found
=end

require 'mysql'
require 'nokogiri'

$dbpass = ARGV[0]

# do I want to connect to database outside of the methods?

$m = Mysql.new "localhost", "vscout_user", "#{$dbpass}", "vscout"

def build_dl_list

	ytq = $m.query("select id, url from vscout_url where url like '%yout%' and (media_file is NULL or media_file not like '%HVC%') and date_found like '2013-07%' and parent_url is null")
	ytq.each_hash do |r|
		puts r['id']
	end

end	

def build_channel_clips
	
	# what's the best way to definitely exclude urls where I've already downloaded their channel clips?

	ytq = $m.query("select url from vscout_url where url like '%youtu%' and subscribe = 'yes'") 
	ytq.fetch_row.each do |r|
		puts r
	end
#	puts ytq.fetch_row

end

build_dl_list
build_channel_clips
