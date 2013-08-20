#!/usr/bin/env ruby
# Script to check database for any missing metadata and generate it.
# Does not download videos or connect to YouTube.

require 'mysql'

DATADIR = "./data"
abort "Enter database password!" unless ARGV[0]
dbpass = ARGV[0]
$m = Mysql.new "localhost", "vscout_user", "#{dbpass}", "vscout"
$clips_with_incomplete_metadata = Hash.new

def gen_md5(video_clip)
	$md5 =	`md5sum #{DATADIR}/#{video_clip}`.split[0]
	$md5 = "fail" unless $md5.length == 32
end

def gen_duration_and_codec(video_clip)
	info = `mp4info #{DATADIR}/#{video_clip}`.split("\n")
	$codec = info[3][/video(.+), \d+\.\d+ secs,/,1].strip! + "/" + info[4][/audio(.+), \d+\.\d+ secs,/,1].strip!
	$duration = info[4][/, (\d+\.\d+) secs,/,1].to_f.round
end

q = $m.query("select id,codec, md5sum, duration, media_file from vscout_url where media_file like 'VVC%mp4' and (codec is null or md5sum is null or duration is null)")
q.each_hash do |r|
	video_clip = r['media_file']
	gen_md5(video_clip)
	gen_duration_and_codec(video_clip)
	puts $md5, $codec, $duration
end
$m.close

