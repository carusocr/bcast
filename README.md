bcastcol
========

Broadcast Collection Support Software Repository

scola_scrape.rb: scraper for SCOLA.org broadcast schedule. Currently runs with 'ruby scola_scrape.rb' and writes to test database db/test.db which can be cleared with db/schema.rb (which contains the table definition) Could be set up to run with MySQL by modifying config.yaml and then run as a cron job, needs to be tested for integrity of updates to make sure identical programs (unchanged schedules) do not add themselves as new rows OR overwrite the original row when they should simply update the last_seen column.