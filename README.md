bcastcol
========

Broadcast Collection Support Software Repository

#scola_scrape.rb:

Web scraper for SCOLA.org broadcast schedule. Currently runs with 'ruby scola_scrape.rb' and writes to test database db/test.db which can be cleared with db/schema.rb (which contains the table definition) Could be set up to run with MySQL by modifying config.yaml and then run as a cron job by using 'crontab -e' and adding the line '* * * * * ruby ~/path/to/scola_scrape.rb' where '* * * * *' needs to be set to whatever schedule you're looking for '0 0 1 * *' <- would run at midnight the first of every month

###Table Schema
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
* __first_seen__ is the date that this program was first scraped
* __last_seen__ is the date that this program was last scraped
* __n_lang__ is the kd-normalized form of the language as scraped
* __n_country__ is the kd-normalized form of the country as scraped
* __channel__ is the integer 1-8 representation of the channel from which this record was scraped
