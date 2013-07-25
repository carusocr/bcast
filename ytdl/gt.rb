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
require 'date'

abort "Enter database password!" unless ARGV[0]
$dbpass = ARGV[0]
#accepts specific date for like statement, or defaults to yesterday.
$daterange = ARGV[1] ? ARGV[1] : Date.today-1

# do I want to connect to database outside of the methods?
$m = Mysql.new "localhost", "vscout_user", "#{$dbpass}", "vscout"
$channel_clips = []
$download_list = Hash.new
$existing_urls = Hash.new
$downloaded_clips = Hash.new

def build_dl_list

	ytq = $m.query("select id, subscribe, url from vscout_url where url like '%yout%' and (media_file is NULL or media_file not like '%HVC%') and date_found like '#{$daterange}%' and parent_url is null")
	ytq.each_hash do |r|
		#puts r['id'], r['subscribe'], r['url']
		#call download_clip first, THEN build existing urls to avoid parent dupe?
		download_clip
		if r['subscribe'] == 'yes'
			puts "Found subscription flag for url #{r['url']}\n"
			$channel_clips << r['url']
		end
	end

end	

def build_channel_clips
	
	# what's the best way to definitely exclude urls where I've already downloaded their channel clips? Maybe set subscribe field to something other than yes/no.

	$channel_clips.each do |cc|
		$download_list ["#{cc}"] = nil
		uploader =  `youtube-dl #{cc} --get-filename -o \"%(uploader_id)s\"`
		puts `youtube-dl --get-filename -f 18 ytuser:#{uploader}`
	end

	# assemble array of existing youtube clips here?
end

def build_existing_urls

	ytq = $m.query("select id, url from vscout_url where url like '%youtu%'")
	ytq.each_hash do |ytc|
		$existing_urls["#{ytc['url'][/watch\?v=(.{11})/,1]}"] = "#{ytc['id']}"
	end

	puts $existing_urls.inspect

# I want to initialize an array of existing youtube videos, then compare the array I make here and download only vids that aren't in the existing array.
# BEWARE of double-collecting parent urls!

end

#load ALL downloaded clips into a single hash, just don't set parent_url value, if value is nil do conventional download, if not nil do channel clip download?

def download_clip
=begin
1. if channel clip, create db row first, then download
2. if no parent id, regular download
3. after download, check file and update row
4. for parent clips, set subscribe to 'dun'
=end
end

def get_uploader_id(channel_clip)
end

def generate_metadata
end

build_dl_list
#build_channel_clips
build_existing_urls
