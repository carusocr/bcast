#!/usr/bin/env ruby 
# Script to download youtube and vimeo videos, including all clips from a user's channel. 
# needed additions: ldcdb password checking, or xml config file for the same
# 24 July 2013
# Author: Chris Caruso
# NOTES: Switch to ActiveRecord!

require 'mysql'
require 'logger'
require 'date'
require 'nokogiri' #change db password to be in xml file instead of argv...or ldcdb?

DATADIR = "/vast/video"
LOGDIR = "/vast"
$log = Logger.new('vast_downloader.log')
abort "Enter database password!" unless ARGV[0]
dbpass = ARGV[0]
#accepts specific date for like statement, or defaults to yesterday.
$daterange = ARGV[1] ? ARGV[1] : Date.today-1

$m = Mysql.new "dbm.ldc.upenn.edu", "vast", "#{dbpass}", "vast"
$channel_clip_parents = Hash.new
$download_urls = Hash.new
$existing_urls = []

def build_parent_clips

	ytq = $m.query("select id, subscribe, url, parent_url from vscout_url where url like '%yout%' and (media_file is NULL or media_file not like '%VVC%') and date_found like '#{$daterange}%'")
	ytq.each_hash do |r|
		if r['subscribe'] == 'yes' && r['parent_url'] == nil
			puts "Found subscription flag for url #{r['url']}\n"
			$channel_clip_parents["#{r['url']}"] = r['id']
		end
		#add clip to array of existing youtube urls to use for comparison with subscription clips
	$existing_urls << r['url'][/watch\?v=(.{11})/,1]	
	end
end

def build_subscription_clips
	
	$channel_clip_parents.sort.each do |cc, id|
		clip_string = cc[/watch\?v=(.{11})/,1]
		puts "Getting userid and channel clips from #{clip_string}\n"
		$log.info "Getting userid and channel clips from #{clip_string}\n"
		$download_urls["#{clip_string}"] = nil
		uploader = `youtube-dl #{clip_string} --get-filename -o \"%(uploader_id)s\"`
		puts "Uploader is #{uploader}"
		$log.info "Uploader is #{uploader}\n"
		`youtube-dl --get-filename -f 18/22 ytuser:#{uploader}`.split("\n").each do |c|
			clip_url = c[/(.{11})\.mp4/,1]
			if (clip_url != clip_string) && $existing_urls.include?(clip_url) == false
				add_child_clip_to_database(clip_url, id)
			end
		end
		# cheesy kluge to mark parent url as having been checked, varchar(3) limitations...
		$m.query("update vscout_url set subscribe = 'dun' where id = #{id}")
	end

end

def gen_randids

# generates rand_id value for each clip that doesn't have one yet. 
# rand_id is what sponsor uses as an identifier for media files
# instead of sequential and thus potentially informational media_file value.

# get existing rands
	@nums_existing = Array.new
	rq = $m.query("select substr(rand_id,4,6) as randstr from vscout_url where rand_id is not null")
		rq.each_hash do |r|
			puts r.inspect
			@nums_existing << r['randstr']
		end	
	rq = $m.query("select count(*) from vscout_url where rand_id is null")
	randcount = rq.fetch_row
	puts randcount
	puts @nums_existing.inspect

end

def build_downloads
	ytq = $m.query("select id, url from vscout_url where (url like '%youtu%' or url like '%vimeo%') and (media_file is NULL or media_file = 'fail') and date_found like '#{$daterange}%'")
	ytq.each_hash do |clip|
		if clip['url'] =~ /youtu/
			$download_urls["#{clip['url'][/watch\?v=(.{11})/,1]}"] = clip['id']
		elsif clip['url'] =~ /vimeo/
			$download_urls["#{clip['url'][/vimeo\.com\/(\d+)/,1]}"] = clip['id']
		end
	end
	$download_urls.sort_by.each do |url, id|
		puts "Downloading #{url} #{id}\n"
		$log.info "Downloading ID #{id}, #{url}..."
		download_clip(url,id)
	end

end

def download_clip(url,id)

	video_clip = "VVC" + format("%06d",id)
	if url =~ /^\d{4,10}$/
		`youtube-dl -w -f 18/22 -o #{DATADIR}/#{video_clip}."%(ext)s" vimeo.com/#{url}`
	elsif url =~ /^.{11}$/
		`youtube-dl -w -f 18/22 -o #{DATADIR}/#{video_clip}."%(ext)s" youtube.com/watch?v=#{url}`
	end
	video_clip = "VVC" + format("%06d",id) + ".mp4"
	if File.exist?("#{DATADIR}/#{video_clip}")
		$log.info "#{url} successfully downloaded as #{video_clip}\n"
		generate_metadata(video_clip,id)
	else 
		$log.info "Download of #{url} failed!\n"
		$m.query("update vscout_url set media_file = 'fail' where id = #{id}")
	end

end

def generate_metadata(video_clip,id)

	begin
		#needed to add check to see if vid or aud is reported first
		info = `mp4info #{DATADIR}/#{video_clip}`.split("\n")
		md5 = `md5sum #{DATADIR}/#{video_clip}`.split[0]
  	if info[3] =~ /video/
   	 codec_video = info[3][/video(.+), \d+\.\d+ secs,/,1].strip!
   	 codec_audio = info[4][/audio(.+), \d+\.\d+ secs,/,1].strip!
   	 duration = info[4][/, (\d+\.\d+) secs,/,1].to_f.round
  	else
   	 codec_video = info[4][/video(.+), \d+\.\d+ secs,/,1].strip!
   	 codec_audio = info[3][/audio(.+), \d+\.\d+ secs,/,1].strip!
   	 duration = info[3][/, (\d+\.\d+) secs,/,1].to_f.round
  	end
		$m.query("update vscout_url set codec = '#{codec_video}/#{codec_audio}', duration = #{duration}, media_file = '#{video_clip}', md5sum = '#{md5}' where id = #{id}")
		$log.info "Metadata: codec = '#{codec_video}/#{codec_audio}', duration = #{duration}, media_file = '#{video_clip}' where id = #{id}\n"
	rescue
		$m.query("update vscout_url set codec = 'fail', duration = 'fail',md5sum = 'fail' where id = #{id}")
		$log.info "Metadata generation FAILED.\n"
	end

end

def add_child_clip_to_database(clip_url, id)

	begin
		$m.query("insert into vscout_url (url,url_md5, parent_url, date_found) values ('http://youtube.com/watch?v=#{clip_url}',md5('#{clip_url}'),#{id},current_timestamp)")
	rescue Mysql::Error
	end

end


build_parent_clips
build_subscription_clips
build_downloads
#gen_randids
$m.close
