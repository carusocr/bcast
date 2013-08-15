#!/usr/bin/env ruby
#Streaming radio capture script
#Author: Chris Caruso
# May 2013

=begin

Script to read in list of streaming radio sources from xml file, 
use mplayer to download approximately 30 minutes of each source
to a uniquely-named output file.

=end

require 'nokogiri'
require 'time'

abort "You must enter an iso639 language code!" unless ARGV[0]
src_dir = "."
lang = ARGV[0]
config_file = "getstream.xml"
MPLAYER = '/usr/bin/mplayer'
RTMPDUMP = '/usr/local/bin/rtmpdump'
RECDIR = '/lre14-collection/audio/incoming'
REC_DURATION = 1700;
sources = Hash.new
doc = Nokogiri::XML(File.open("#{src_dir}/#{config_file}"))

#parse xml, check langcode first and populate hash only with argv'ed lang
doc.xpath("//SrcDef[@lang=\"#{lang}\"]/Download").each do |node|
	if node.text =~ /y/
		srcinfo = node.xpath('parent::node()').text.split("\n")
		srcinfo.map{|x| x.strip!}
		sources["#{node.xpath('../@id')}"] = (srcinfo.reject{|x| x.length==0 || x == lang})
	end
end

def download_stream(downloader,timestring,src_name,src_url,lang)

	if downloader == "mplayer"
		cmd = "#{MPLAYER} #{src_url} -cache 8192 -dumpstream -dumpfile #{RECDIR}/#{timestring}_#{src_name}_#{lang}.mp3\n"
		puts cmd
	elsif downloader == "rtmpdump"
		cmd = "#{RTMPDUMP} -r \"#{src_url}\" -o #{RECDIR}/#{timestring}_#{src_name}_#{lang}.flv -B #{REC_DURATION}\n"
		puts cmd
		`#{cmd}`
	end

end

def killprocs(src_name) # <--- change this to src_url after testing! ***

	targets = (`ps -fC vim | grep '#{src_name}' | awk '{print $2}'`).split
	targets.each do |t|
		# kill procnum
		puts "Killing \##{t}, existing #{src_name} process...\n"	
		# no, really...this is where you kill the processes!
	end

end

# Loop over set of sources, check to make sure that 
# no other download processes for that source are running,
# kick off new process.

sources.keys.each do |s|

	src_name = sources[s][0]
	src_url = sources[s][1]
	downloader = sources[s][4]
	killprocs(src_name) # Kill any existing downloads.
	timestring = Time.now.strftime("%Y%m%d_%H%M%S")
	#fork each source download and record PID in hash
	src_pid = Process.fork {download_stream(downloader,timestring,src_name,src_url,lang)}
	sources[s][5] = src_pid

end
