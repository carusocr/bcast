bcastcol
========

Broadcast Collection Support Software Repository

Suite of scripts used to collect broadcast and web audio/video data.

####mech/ytvore.rb

Script to crawl YouTube and search for videos matching keywords stored in a local database.
General process:

1. We generate a list of events and associated search terms and use this information to create a database table of keywords, each associated to a particular event in ascout_event.

2. Script automatically checks database table for events+keywords and crawls youtube. Looks for videos that match search terms and checks existing urls in prescouting data table to ensure that they have not already been identified.

3. Adds found urls that match search terms to database.

4. Script crawls to video url and gets license information and duration. If both match our criteria it adds video url, event type, searchwords used (this would let us generate histograms and see which keywords are most effective on a per-event basis), license, and video duration to prescouting table.

5. Human scouts load first-pass tool, which contains a list of YouTube video urls for each event. Human views prescouted videos

####mech/poltertube.rb

Similar script as ytvore.rb, but uses Capybara to open a browser session instead of using Mechanize. Nice for demo purposes.

####streaming/streamcap.rb

Script to read in list of streaming radio sources from xml file, and use mplayer/rtmpdump/ffmpeg to download approximately 30 minutes of each source to a uniquely-named output file. Runs once per language.

####streaming/twitter/wordlist.rb

Script that reads in a list of common words for a specified language, creates a streaming Twitter client, and monitors stream to collect any tweets with matching words.

####streaming/twitter/grab_tweets.rb

Script that collects all tweets matching either user IDs or tweet IDs from input file (if it detects alpha characters in lines of file, defaults to user-based collection).

