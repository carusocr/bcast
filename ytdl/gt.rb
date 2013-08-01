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

=end

require 'mysql'
require 'nokogiri'
require 'date'

DATADIR="./data"
abort "Enter database password!" unless ARGV[0]
$dbpass = ARGV[0]
#accepts specific date for like statement, or defaults to yesterday.
$daterange = ARGV[1] ? ARGV[1] : Date.today-1

# do I want to connect to database outside of the methods?
$m = Mysql.new "localhost", "vscout_user", "#{$dbpass}", "vscout"
$channel_clip_parents = Hash.new
$download_urls = Hash.new
$existing_urls = Hash.new
$downloaded_clips = Hash.new

def build_parent_clips

	ytq = $m.query("select id, subscribe, url from vscout_url where url like '%yout%' and (media_file is NULL or media_file not like '%HVC%') and date_found like '#{$daterange}%' and parent_url is null")
	ytq.each_hash do |r|
		#call download_clip first, THEN build existing urls to avoid parent dupe?
		download_clip
		if r['subscribe'] == 'yes'
			puts "Found subscription flag for url #{r['url']}\n"
			$channel_clip_parents["#{r['url']}"] = r['id']
		end
	end

end	

def build_subscription_clips
	
	# what's the best way to definitely exclude urls where I've already downloaded their channel clips? Maybe set subscribe field to something other than yes/no.

	$channel_clip_parents.sort.each do |cc, id|
		clip_string = cc[/watch\?v=(.{11})/,1]
		puts "Getting userid and channel clips from #{clip_string}\n"
		$download_list["#{clip_string}"] = nil
		uploader = `youtube-dl #{clip_string} --get-filename -o \"%(uploader_id)s\"`
		puts "Uploader is #{uploader}"
		`youtube-dl --get-filename -f 18 ytuser:#{uploader}`.split("\n").each do |c|
			clip_url = c[/(.{11})\.mp4/,1]
			if clip_url != clip_string
				add_child_clip_to_database(clip_url, id)
			end
		end
		$m.query("update vscout_url set subscribe = 'dun' where id = #{id}")
	end

	# assemble array of existing youtube clips here?
end

def build_download_list

	ytq = $m.query("select id, url from vscout_url where url like '%youtu%' and media_file is NULL and date_found like '#{$daterange}%'")
	ytq.each_hash do |ytc|
		$download_urls["#{ytc['url'][/watch\?v=(.{11})/,1]}"] = ytc['id']
	end
	$download_urls.sort_by.each do |k, id|
		puts "#{k} #{id}\n"
	end

end

def download_clip
=begin
1. if channel clip, create db row first, then download
2. if no parent id, regular download
3. after download, check file and update row
4. for parent clips, set subscribe to 'dun'
5. add downloaded clip to downloaded_clips
=end
end

def get_uploader_id(channel_clip)
end

def generate_metadata
end

def add_child_clip_to_database(clip_url, id)
	begin
		$m.query("insert into vscout_url (url,url_md5, parent_url, date_found) values ('http://youtube.com/watch?v=#{clip_url}',md5('#{clip_url}'),#{id},current_timestamp)")
#puts "insert into vscout_url (url, parent_url, date_found) values ('http://youtube.com/watch?v=#{clip_url}',#{id},current_timestamp)\n"
	rescue Mysql::Error
	end
end

build_parent_clips
build_subscription_clips
build_download_list
# each loop down here using array made with build_download_list, calling download_clip and then update database
#need to add some better dupe checks...maybe when building children clips, compare against existing clips to make sure they're not already in there?
