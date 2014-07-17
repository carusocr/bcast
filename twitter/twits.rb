require 'tweetstream'

user = ARGV[0]
pwd = ARGV[1]
=begin
basic method
TweetStream::Client.new(:username => 'you', :password => 'pass')

Alternatively, you can configure TweetStream via the configure method:

TweetStream.configure do |config|
  config.consumer_key       = 'cVcIw5zoLFE2a4BdDsmmA'
  config.consumer_secret    = 'yYgVgvTT9uCFAi2IuscbYTCqwJZ1sdQxzISvLhNWUA'
  config.oauth_token        = '4618-H3gU7mjDQ7MtFkAwHhCqD91Cp4RqDTp1AKwGzpHGL3I'
  config.oauth_token_secret = 'xmc9kFgOXpMdQ590Tho2gV7fE71v5OmBrX8qPGh7Y'
  config.auth_method        = :oauth
end

If you are using Basic Auth:

TweetStream.configure do |config|
  config.username     = 'username'
  config.password     = 'password'
  config.auth_method  = :basic
end

From scraping twitter page:

require "tweetstream"
require "mongo"
require "time"

db = Mongo::Connection.new("MY_DB_URL", 27017).db("MY_DB_NAME")
tweets = db.collection("DB_COLLECTION_NAME")

TweetStream::Daemon.new("TWITTER_USER", "TWITTER_PASS", "scrapedaemon").on_error do |message|
  # Log your error message somewhere
end.filter({"locations" => "-12.72216796875, 49.76707407366789, 1.977539, 61.068917"}) do |status|
  # Do things when nothing's wrong
  data = {"created_at" => Time.parse(status.created_at), "text" => status.text, "geo" => status.geo, "coordinates" => status.coordinates, "id" => status.id, "id_str" => status.id_str}
  tweets.insert({"data" => data});
end

LINKS

http://stackoverflow.com/questions/6060178/write-to-database-with-tweetstream-daemon

=end

#TweetStream::Daemon.new(:username => user, :password = pwd)
TweetStream::Client.new(:username => user, :password => pwd).sample do |status|
  puts "[#{status.user.screen_name}] #{status.text}"
end

