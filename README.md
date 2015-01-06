bcastcol
========

Broadcast Collection Support Software Repository

Suite of scripts used to collect broadcast and web audio/video data.

streaming/streamcap.rb

Script to read in list of streaming radio sources from xml file, and use mplayer/rtmpdump/ffmpeg to download approximately 30 minutes of each source to a uniquely-named output file. Runs once per language.

streaming/twitter/wordlist.rb

Script that reads in a list of common words for a specified language, creates a streaming Twitter client, and monitors stream to collect any tweets with matching words.

streaming/twitter/grab_tweets.rb

Script that collects all tweets matching either user IDs or tweet IDs from input file.

