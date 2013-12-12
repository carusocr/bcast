#!/usr/bin/env ruby
#Google image search is a pain in the ass, start small with Yahoo.
# download set of images, compare them and discard lower quality dupes
# do this with audio next

require 'mechanize'
require 'nokogiri'

searchterm = ARGV[0]
agent = Mechanize.new
dler = Mechanize.new
dler.pluggable_parser.default = Mechanize::Download
page = agent.get('http://images.search.yahoo.com/')



img_form = page.form('s')
img_form.p = searchterm

page = agent.submit(img_form)
counter=1
page.links_with(:href => %r{imgurl}).each do |link|
	begin
		imgurl = link.href[/imgurl=(.*?jpg)/i,1]
		imgurl.gsub! '%2F', '/'
		imgurl.gsub! '%2B', '-'
		puts imgurl
		dlurl = "http://" + imgurl
		puts "downloading #{dlurl} as #{searchterm}_#{counter}.jpg"
		#dler.get(dlurl).save("downloads/#{searchterm}_#{counter}.jpg")
		counter+=1
		sleep(2)
		#puts link.href
	rescue # in case of 403
		next
	end
end
