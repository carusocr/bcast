#!/usr/bin/env ruby

=begin
Name: ytvore.rb
Date Created: 10 December 2013
Author: Chris Caruso
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

*How to exclude fullnames? I would bet that video clips with someone's name in the 
thumbnail description also has them using their own name in the clip itself.

* Grab additional data from search page - thumbnail, description, uploader, license info
* youtube-dl can get autocaps, but those are terrible for filtering anything.
* youtube-dl can also get: 
	thumbnail URL
	title
	ID
	video description
	video length

new table schema

searchterm

+---------+--------------+------+-----+---------+----------------+
| Field   | Type         | Null | Key | Default | Extra          |
+---------+--------------+------+-----+---------+----------------+
| id      | int(11)      | NO   | PRI | NULL    | auto_increment |
| event   | int(11)      | NO   | MUL | NULL    |                |
| name    | varchar(255) | NO   |     | NULL    |                |
| created | datetime     | YES  |     | NULL    |                |
+---------+--------------+------+-----+---------+----------------+

prescout

| ascout_prescout | CREATE TABLE `ascout_prescout` (
  `id` int(11) NOT NULL DEFAULT '0',
  `url` char(11) NOT NULL,
  `uploader` varchar(20) DEFAULT NULL,
  `duration` int(11) DEFAULT NULL,
  `searchterm` int(11) DEFAULT NULL,
  `created` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `url` (`url`),
  KEY `ascout_searchterm_ibfk_2` (`searchterm`),
	CONSTRAINT `ascout_prescout_ibfk1` FOREIGN KEY (`searchterm`) REFERENCES `ascout_searchterm` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 |

+------------+-------------+------+-----+---------+-------+
| Field      | Type        | Null | Key | Default | Extra |
+------------+-------------+------+-----+---------+-------+
| id         | int(11)     | NO   | PRI | 0       |       |
| url        | char(11)    | NO   | UNI | NULL    |       |
| uploader   | varchar(20) | YES  |     | NULL    |       |
| duration   | int(11)     | YES  |     | NULL    |       |
| searchterm | int(11)     | YES  | MUL | NULL    |       |
| created    | datetime    | YES  |     | NULL    |       |
+------------+-------------+------+-----+---------+-------+

| ascout_searchterm | CREATE TABLE `ascout_searchterm` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `created` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `event` (`event`),
	CONSTRAINT `ascout_searchterm_ibfk1` FOREIGN KEY (`event`) REFERENCES `ascout_event` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 |

=end


require 'open-uri'
require 'mechanize'
require 'nokogiri'

#nfpr = don't replace searchterm
search_prefix = "http://www.youtube.com/results?nfpr=1&search_query="
searchstring = ARGV[0]
ytpage = search_prefix + searchstring
wikipage = "http://en.wikipedia.org/wiki/" + searchstring + "_discography"
puts wikipage
agent = Mechanize.new
page = agent.get(ytpage)

#get max number of pages to crawl
max_pages = 50 #youtube won't handle more than 1000 results and there are 20 per page
total_results = page.parser.xpath('//p[starts-with(@class, "num-results")]/strong').text.sub(',','').to_i/20
pagecount = (total_results < max_pages) ? total_results : max_pages

#added to keep results sane during testing
pagecount=2

#test check for searchterm swap
#change search to be insistent, don't even worry about this?
#swap = page.parser.xpath('//a[@class="spell-correction-given-query"]').text.strip!
#unless swap.nil?
#	puts "Bastards nerfed your search!"
#	puts swap
#	exit
#end

def grab_page_links(agent,ytpage)

	page = agent.get(ytpage)
	page.parser.xpath('//li[contains(@class, "context-data-item")]').each do |vid|

		puts vid.attr('data-context-item-title')
		puts vid.attr('data-context-item-user')
		puts vid.attr('data-context-item-time')
		puts vid.attr('data-context-item-id')
		puts "\n"

	end

end

def scrape_wiki_albums(agent,wikipage)

	#this depends on consistent naming conventions and existence of <artist>_discography Wikipage

	doc = Nokogiri::HTML(open(wikipage))
	doc.xpath('//table/caption[contains(text(),"studio album")]/..//th[@scope="row"]//a').each do |t|
		
		puts t.attr('href')
	
	end


end

scrape_wiki_albums(agent,wikipage)

#for i in 1..pagecount
#	ytpage = search_prefix + searchstring + "&page=#{i}"
#	puts ytpage
#	grab_page_links(agent,ytpage)
#end
