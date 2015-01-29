#!/usr/bin/env ruby
# script that reads xml file, generates two sets of .trn.txt files.
# One set has tweet id and is LDC-internal, other set is for outsourcing.
# Ignores any retweets and tweets that are short and have a url string.

require 'nokogiri'
abort "Enter xml source file!" unless ARGV[0]
infile = ARGV[0]
f = File.open(infile)
filestem = infile.sub(/.*\//,"").sub(/\.xml/,"")
doc = Nokogiri::XML.parse(f)
f.close
tweet_ctr = 1
file_number = 1
#initial fileopen
ofil = filestem + "_#{sprintf("%06d",file_number)}"
File.open("#{ofil}.xml",'w') { |file| file.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<doc id = \"#{ofil}\">\n")}
doc.xpath("//tweet").each do |n|
  if tweet_ctr == 31
    File.open("#{ofil}.xml", 'a') { |file| file.write("</doc>") }
    file_number += 1
    tweet_ctr = 1
    ofil = filestem + "_#{sprintf("%06d",file_number)}"
    File.open("#{ofil}.xml",'w') { |file| file.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<doc id = \"#{ofil}\">\n")}
  end
  ofil = filestem + "_#{sprintf("%06d",file_number)}"
  puts "printing tweets to #{ofil}\n"
  tweet_id = n['id']
  tweet_text = n.text.gsub("\n","")
  unless (tweet_text.length < 50 and tweet_text =~ /http/) or tweet_text =~ /RT/
    File.open("#{ofil}.xml", 'a') { |file| file.write("#{n}\n") }
    #puts n
    tweet_ctr += 1
  end
end
