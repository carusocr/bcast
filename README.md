bcastcol
========

Broadcast Collection Support Software Repository

#scola_scrape.rb:

Web scraper for SCOLA.org broadcast schedule. Currently runs with 'ruby scola_scrape.rb' and writes to test database db/test.db which can be cleared with db/schema.rb (which contains the table definition) Could be set up to run with MySQL by modifying config.yaml and then run as a cron job by using 'crontab -e' and adding the line '* * * * * ruby ~/path/to/scola_scrape.rb' where '* * * * *' needs to be set to whatever schedule you're looking for '0 0 1 * *' <- would run at midnight the first of every month