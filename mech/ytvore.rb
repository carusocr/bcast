#!/usr/bin/env ruby

=begin
1. We generate a list of events and associated search terms and use this information to create a database table of keywords, each associated to a particular event in ascout_event.
2. Script automatically checks database table for events+keywords and crawls youtube. Looks for videos that match search terms and checks existing urls in prescouting data table to ensure that they have not already been identified.
3. Adds found urls that match search terms to database.
4. Script crawls to video url and gets license information and duration. If both match our criteria it adds video url, event type, searchwords used (this would let us generate histograms and see which keywords are most effective on a per-event basis), license, and video duration to prescouting table.
5. Human scouts load first-pass tool, which contains a list of YouTube video urls for each event. Human views prescouted videos, makes appropriate judgments. Once this is done, the annotation is copied to the ascout_url table and continues through the pipeline as usual.
=end


require 'mechanize'
require 'nokogiri'

agent = Mechanize.new

page = agent.get('http://youtube.com/')

page.links_with(:text=>'News').each do |link|
	puts link.text
end

#pp page

#goog_form = page.form('f')
#goog_form.q = 'perl vs ruby mechanize'

#page = agent.submit(goog_form)
#pp page
