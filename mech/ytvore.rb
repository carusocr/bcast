#!/usr/bin/env ruby

=begin
Name: ytvore.rb
Date Created: 10 December 2013
Author: Chris Caruo
Script to crawl YouTube and search for videos matching keywords stored in a local database.
General process:
1. We generate a list of events and associated search terms and use this information to create a database table of keywords, each associated to a particular event in ascout_event.
2. Script automatically checks database table for events+keywords and crawls youtube. Looks for videos that match search terms and checks existing urls in prescouting data table to ensure that they have not already been identified.
3. Adds found urls that match search terms to database.
4. Script crawls to video url and gets license information and duration. If both match our criteria it adds video url, event type, searchwords used (this would let us generate histograms and see which keywords are most effective on a per-event basis), license, and video duration to prescouting table.
5. Human scouts load first-pass tool, which contains a list of YouTube video urls for each event. Human views prescouted videos, makes appropriate judgments. Once this is done, the annotation is copied to the ascout_url table and continues through the pipeline as usual.

Additional notes:

YouTube won't serve more than 1000 search hits. Initial seeding 
will be a lot of videos, but after that maybe search once a day for any videos.
Need to test out application of filters. We will want to use duration, upload date,
maybe license although SYL isn't listed.

How to exclude fullnames? I would bet that video clips with someone's name in the 
thumbnail description also has them using their own name in the clip itself.

Grab additional data from search page - thumbnail, description, uploader.

=end


require 'mechanize'
require 'nokogiri'

searchstring = ARGV[0]
ytpage = "http://www.youtube.com/results?search_query=" + searchstring
agent = Mechanize.new
page = agent.get(ytpage)

pp page

def grab_page_links(page)

	page.parser.xpath('//*[@data-video-ids]').each do |vid|
		puts vid.attr('data-video-ids')
	end

end

#grab_page_links(page)
