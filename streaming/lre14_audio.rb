#!/usr/bin/env ruby

require 'nokogiri'

src_dir="/lre14/bin/streaming"
src_dir="."
config_file = "getstream.xml"
sources = Hash.new
doc = Nokogiri::XML(File.open("#{src_dir}/#{config_file}"))
doc.xpath('//SrcDef/Dialect').each do |node|
	srcinfo = node.xpath('parent::node()').text.split("\n")
	srcinfo.map{|x| x.strip!}
	sources["#{node.xpath('../@id')}"] = (srcinfo.reject{|x| x.length == 0} << node.xpath('../@lang'))
end

Dir.chdir("/cap/current") do
	sources.keys.each do |s|
		src_prog = sources[s][0]
		src_dialect = sources[s][2]
		src_lang = sources[s][4]
		puts "RAILS_ENV=production rake create_audios_from_glob[/lre14-collection/audio/#{src_lang}/*#{src_prog}*.flac,lre14_bn_#{src_dialect}] --trace"
	end
end

#export LANG=en_US.UTF-8
#source /usr/local/rvm/scripts/rvm
#rvm use 2.0.0-p0@luirailsapp

#Dir.chdir("/cap/current") do
#	system "RAILS_ENV=production rake create_audios_from_glob[/lre14-collection/audio/spa/[mMeExX]*.flac,lre14_bn_mca] --trace"
#end
