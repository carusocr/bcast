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

New tables for ascout:

| ascout_prescout | CREATE TABLE `ascout_prescout` (
  `id` int(11) NOT NULL DEFAULT '0',
  `url` char(11) NOT NULL,
  `uploader` varchar(20) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
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
| title      | varchar(255)| YES  |     | NULL    |       |
| duration   | int(11)     | YES  |     | NULL    |       |
| searchterm | int(11)     | YES  | MUL | NULL    |       |
| created    | datetime    | YES  |     | NULL    |       |
+------------+-------------+------+-----+---------+-------+

| ascout_searchterm | CREATE TABLE `ascout_searchterm` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `created` datetime DEFAULT NULL,
  `last_checked` datetime DEFAULT NULL,
	`active` boolean default 0,
	`aud_only` boolean default 0,
  PRIMARY KEY (`id`),
  KEY `event` (`event`),
	CONSTRAINT `ascout_searchterm_ibfk1` FOREIGN KEY (`event`) REFERENCES `ascout_event` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 |

+---------+--------------+------+-----+---------+----------------+
| Field   | Type         | Null | Key | Default | Extra          |
+---------+--------------+------+-----+---------+----------------+
| id      | int(11)      | NO   | PRI | NULL    | auto_increment |
| event   | int(11)      | NO   | MUL | NULL    |                |
| name    | varchar(255) | NO   |     | NULL    |                |
| created | datetime     | YES  |     | NULL    |                |
| updated | datetime     | YES  |     | NULL    |                |
| active  | tinyint(1)   | YES  |     | 0       |                |
| aud_only| tinyint(1)   | YES  |     | 0       |                |
+---------+--------------+------+-----+---------+----------------+

Method flow:

1. Assemble list of search terms.
2. For each search term, perform youtube page search from 1..pagemax. Push results into hash!
2a. ...or automatically update ascout_prescout with data, but push url+id to download hash?
3. Repeat for all search terms, build one huge hash. Values needed in hash are...? ID. URL.
4. Hash.each call update_prescout.
5. Go back and query prescout to get list of stuff to download.
6. Download clips.
7. Update metadata.


TO-DO LIST:

- FIX TITLE HANDLING
	* done, changed all non-alpha chars to underscores. Ugly but functional...
	* get users handle instead of longer name, too?
- ADD PRESCOUT URL TO DOWNLOADER FOR CLIP NAMING
- ADD HANDLING FOR SEARCH AFTER LAST DATE CHECKED
this works via &filters=(today|week|month)
syntax is &filters=today,+nextfilter,+nextfilter. Comma is %2C
- Add some sort of freeball mode that doesn't depend on database connectivity at all, just searches and downloads - how to avoid uniques, check download directory?
=end


require 'mysql'
require 'open-uri'
require 'mechanize'
require 'nokogiri'
require 'optparse'

OptionParser.new do |o|
	o.on('-s SEARCHTERM','Text search term; concatenate multiple with "+"') {|b| $searchstring = b}
	o.on('-p DBPASS','Password to MySQL scouting db') {|b| $dbpass = b}
  o.on('-d {today|week|month}','Only get videos uploaded during the past day/week/month') {|b| $date_filter= '&filters=' + b}
	o.on('-h','--help','Print this help text') {puts o; exit}
	o.on('--no-db','Don\'t update database with found clips') {|b| $no_db_update = true} 
	o.on('--no-dl','Don\'t download found clips') {|b| $no_download = true} 
	o.on('-w','Search Wikipedia discographies') {|b| $wikisearch = b}
	o.on('-l max-pages','Limit page hits, YouTube returns max 50 pages, 20 videos per page') {|b| $pagecount = b.to_i}
	o.parse!
end

#nfpr = don't replace searchterm
#filters for date queries
if $date_filter
	$search_prefix = "http://www.youtube.com/results?nfpr=1#{$date_filter}&search_query="
else	
	$search_prefix = "http://www.youtube.com/results?nfpr=1&search_query="
end
abort "Enter database password!" unless $dbpass

$datadir = "~/projects/bcast/mech"
$m = Mysql.new "localhost", "root", "#{$dbpass}", "ascout"
#$download_urls = Hash.new
$download_urls = Hash.new{|h,k| h[k] = Hash.new}
$agent = Mechanize.new


# Add 
#https://www.googleapis.com/youtube/v3/search?part=snippet&publishedAfter=2011-01-01T00%3A00%3A00Z&q=coke&type=video&videoDefinition=high&videoDuration=short&key={YOUR_API_KEY}
#

def grab_page_links(ytpage)

	#add in date filters here as well, if specified

	page = $agent.get(ytpage)

	#get max number of pages to crawl
	max_pages = 50 #youtube won't handle more than 1000 results and there are 20 per page
	total_results = page.parser.xpath('//p[starts-with(@class, "num-results")]/strong').text.sub(',','').to_i/20
	unless $pagecount #skip if pagecount has been specified in args
		$pagecount = (total_results < max_pages) ? total_results : max_pages
	end
	page_hits = []
	
	ytpage = ytpage + "&page=1"
	for i in 1..$pagecount

		ytpage.sub!(/page=\d+/,"page=#{i}")
		puts "Page is #{i}"
		page = $agent.get(ytpage)

		page.parser.xpath('//li[contains(@class, "context-data-item")]').each do |vid|

			title =  vid.attr('data-context-item-title')
			uploader = vid.attr('data-context-item-user')
			#get uploader name from youtube-dl? Succinct but slower.
			duration = vid.attr('data-context-item-time')
			url = vid.attr('data-context-item-id')
			unless (url =~ /^PL/) #if not part of playlist
				page_hits.push("#{url}\t#{title}\t#{uploader}\t#{duration}")
			end

		end

	end
	return page_hits

end

def scrape_wiki_albums(wikipage)

	wikipage = "http://en.wikipedia.org/wiki/" + $searchstring
	wikipage += "_discography"

	#this depends on consistent naming conventions and existence of <artist>_discography Wikipage

	doc = Nokogiri::HTML(open(wikipage))
	doc.xpath('//table/caption[contains(text(),"studio album")]/..//th[@scope="row"]//a').each do |t|

		puts t.attr('href')
	
	end


end

def update_prescout(url,uploader,duration,searchterm,title)

	return 0 if $no_db_update == true
	begin

		$m.query("insert into ascout_prescout (url, uploader, duration, searchterm, created,title) values ('#{url}','#{uploader}',time_to_sec('#{duration}'),'#{searchterm}',current_timestamp,'#{title}')")

	rescue Mysql::Error => e
		pp e
	end

end

def update_searchterm(id)

	begin

		$m.query("update ascout_searchterm set updated = current_timestamp where id = '#{id}'")

	rescue Mysql::Error => e

		pp e

	end

end

def build_searchlist()

	if $searchstring
		puts "Search string is #{$searchstring}!"
		ytpage = $search_prefix + $searchstring
    searchterm = 'NULL'
		scrape_youtube(ytpage,searchterm)
		return 0
	end
	ytq = $m.query("select id,name from ascout_searchterm where active = 1")
	ytq.each_hash do |r|
		
		ytpage = $search_prefix + "#{r['name']}"
		searchterm = r['id']
		scrape_youtube(ytpage,searchterm)
		#sleep 3	

	end
	
end

def scrape_youtube(ytpage,searchterm)

	page_hits = grab_page_links(ytpage)
	page_hits.each do |hit|

		url,title,uploader,duration = hit.split("\t")
		#change single quotes to escaped quotes for sql statement, strip trailing _
		title = title.gsub(/\W/,"_").gsub(/_+/,"_").sub(/_$/,"")
		update_prescout(url,uploader,duration,searchterm,title) if !$searchstring
    #populate hash of hashes
    $download_urls["#{url}"]['title'] = title

	end

end

def download_clips()
  $download_urls.sort_by.each do |u|
    #this makes [0] the hash key, i.e. the unique url string
    url = u[1]['url']
    url = u[0]
    title = u[1]['title']
	  puts "DLCMD: youtube-dl -w -f mp4 -o downloads/#{title}.mp4 #{url}\n"
    #	add --dateafter 
		unless $no_download == true
	  	`youtube-dl -w -f mp4 -o #{$datadir}/downloads/#{title}.mp4 #{url}`
		end
  end
end

build_searchlist()
download_clips()
