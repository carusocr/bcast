# given a single tweet ID, collect associated text
# prints Twitter error message if tweet isn't available

require 'twitter'

abort "Enter numeric Tweet ID." unless ARGV[0] =~ /^[0-9]+$/
tweet_id = ARGV[0]

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "YOUR_CONSUMER_KEY"
  config.consumer_secret     = "YOUR_CONSUMER_SECRET"
  config.access_token        = "YOUR_ACCESS_TOKEN"
  config.access_token_secret = "YOUR_ACCESS_SECRET"
end

def collect_single_tweet(tweet_id,client)
  status = client.status(tweet_id)
  rescue Twitter::Error => e
    puts e.message
  else
    puts status.text.gsub("\t","").gsub("\n","")
end

collect_single_tweet(tweet_id,client)
