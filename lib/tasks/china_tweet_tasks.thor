class ChinaTweetTasks < Thor
  require File.expand_path('../../', File::dirname(__FILE__)) + '/config/environment'

	desc "test_tweet", "Send test tweet: subdomain, client, message"
	def test_tweet(subdomain, client, message)
      tweet_client = ChinaTweet.new(client, subdomain)
      result = tweet_client.new_tweet(message)
      puts "Result: #{result}"
	end
end
