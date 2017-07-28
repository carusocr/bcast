#!/usr/bin/env ruby
=begin
Script that uses Google YouTube API to collect comments from videos.

Note: list_comments can accept either 'id' or 'snippet' as the type of
  data to be retrieved. Using 'id' returns just the id and 'snippet'
  returns more, but costs 1 unit of quota cost. Default quota amounts for
  a YouTube Data API app is 1 million units per day. Any call also consumes
  1 quota unit, so retrieving a snippet actually costs at least 2. From
  the API docs:

Read and write operations use different amounts of quota depending on the number of resource parts that each request retrieves. Note that insert and update operations write data and also return a resource. So, for example, inserting a playlist has a quota cost of 50 units for the write operation plus the cost of the returned playlist resource.

As discussed in the following section, each API resource is divided into parts. For example, a playlist resource has two parts, snippet and status, while a channel resource has six parts and a video resource has 10. Each part contains a group of related properties, and the groups are designed so that your application only needs to retrieve the types of data that it actually uses.

An API request that returns resource data must specify the resource parts that the request retrieves. Each part then adds approximately 2 units to the request's quota cost. As such, a videos.list request that only retrieves the snippet part for each video might have a cost of 3 units. However, a videos.list request that retrieves all of the parts for each resource might have a cost of around 21 quota units.

https://developers.google.com/youtube/v3/getting-started#quota

Excellent reference of YoutubeV3 methods for Ruby:

http://www.rubydoc.info/github/google/google-api-ruby-client/Google/Apis/YoutubeV3/YouTubeService

- after collecting comment threads, parse them and identify any with replies.
- build collection of comments with parent_ids of top level comments.
- need to be in order? Not really, id of reply comments has id of parent.

=end

require 'google/apis/youtube_v3'

DEV_KEY = File.readlines("ytapi.txt").join.chomp

youtube = Google::Apis::YoutubeV3::YouTubeService.new
youtube.key = DEV_KEY

# using Russia-Ukraine video comment with 46 replies for testing
puts 'list single comment'
c = youtube.list_comments('snippet', id: 'z12rtb2ajonrifa3i23dt5fjymelx510e')
puts c.to_json
puts 'list thread'
c = youtube.list_comment_threads('snippet', id: 'z12rtb2ajonrifa3i23dt5fjymelx510e')
puts c.to_json
coms = youtube.list_comments('id', parent_id: 'z134uheagvrgjr54k04cfjzijmufgzmo10w')
