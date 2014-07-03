bcast
========

Broadcast Collection Support Software Repository

###scola_scrape.rb:

Web scraper for SCOLA.org broadcast schedule. Currently runs with 'ruby scola_scrape.rb' and writes to test database db/test.db which can be cleared with db/schema.rb (which contains the table definition) Could be set up to run with MySQL by modifying config.yaml and then run as a cron job (see config tips below)

####Table Schema
The table schema is stored in db/schema.rb but essentially has the following structure:
id|prog_id|iso_ln|iso_cn|start_time|day|duration|first_seen|last_seen|n_lang|n_country|channel

Where:
* __id__ is the integer id assigned by ActiveRecord
* __prog_id__ is a string with the following format $(iso_ln)_$(channel)_$(day)$(hour)$(minute)_$(duration) and is enforced unique across all rows
* __iso_ln__ is the 3 character iso code for the language broadcast, ZXX for languages that do not appear in the iso-table or have not been hard coded in as appropriate
* __iso_cn__ is a 2 character iso code for the country of origin, ZZ for countries that do not appear in the table or have not been hard coded in as appropriate
* __start_time__ is an integer of the form DD(00-06 Sun-Sat):HH(00-24):MM(00-59) of the start of the broadcast for this program
* __day__ is a 3 character representation of the day of the broadcast (Sun-Sat)
* __duration__ is the length of the program in seconds
* __f_seen__ is the date that this program was first scraped
* __l_seen__ is the date that this program was last scraped
* __n_lang__ is the kd-normalized form of the language as scraped
* __n_country__ is the kd-normalized form of the country as scraped
* __channel__ is the integer 1-8 representation of the channel from which this record was scraped

### Config tips
When setting up on a new system be aware of the following issues:
* Make sure you have cron permissions
* Point at the full path of a valid ruby install (1.9.3) with required gems
* Scraper itself does not mail out errors but will print success and failure logs to stdout, you can (and should) pipe those to mailx to make sure that if there are issues that you catch them
* You may have encoding issues in cron, you can make sure you have the right encoding in the folder by checking for en_US.utf8 in the localize -a for the containing folder. You may have to add 'LANG=en_US.utf8' to the crontab folder if the shell is not in the proper environment.

### Maintenance
You can run the scraper outside of cron if you are using ruby 1.9.3 and have bundled to ensure latest versions of nokogiri et. al., it will run simply by invoked 'ruby scola_scrape.rb' from the command line. The same is true for the utility class (normalize.rb) however running it will simply reinitialize the dictionarys it has for language and country ISO data from the files in /lib ...

##ytdl
======

Contains youtube downloader scripts.

option to download all user uploads: youtube-dl -citw ytuser:[USERNAME]

##mech
======

Home to automation experiments.
