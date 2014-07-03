bcast
========

Broadcast Collection Support Software Repository


###mech
======
Home to automation experiments.

####ytvore.rb:
Connects to MySQL database to assemble list of search terms, uses capybara to headlessly navigate to YouTube and searches for videos, enters list of results as basic annotations into database, downloads videos, converts to standardized format if necessary.

####demo_poltertube.rb:
Demo of YouTube page scraping using capybara+selenium.

####phocomp.rb:
Testing out image scraping...started with Yahoo image search.

####mechanized_commenter.rb:
Final version of this script will log into Google Accounts, navigate to a YouTube video based on search term (i.e. 'jiu-jitsu'), make a comment based on search term (i.e. 'your jiu-jitsu is terrible'), notate in database when and where comment was made, wait a period of time, then return to page later and scrape replies to comment. 

###streaming
======
Scripts to capture streaming online radio.

####streamcap.rb:
Reads in list of streaming radio sources from xml file, uses mplayer/rtmpdump/ffmpeg to download approximately 30 minutes of each source flagged for download to a timestamped output file. 

###scola_scrape
======

####scola_scrape.rb:

Web scraper for SCOLA.org broadcast schedule. Currently runs with 'ruby scola_scrape.rb' and writes to test database db/test.db which can be cleared with db/schema.rb (which contains the table definition) Could be set up to run with MySQL by modifying config.yaml and then run as a cron job (see config tips below)

###ytdl
======
Contains youtube downloader scripts.

####youtube-dl:
http://rg3.github.io/youtube-dl/
option to download all user uploads: youtube-dl -citw ytuser:[USERNAME]
