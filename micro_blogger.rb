require 'jumpstart_auth'
require 'bitly'
Bitly.use_api_version_3

class MicroBlogger
  attr_reader :client

  def initialize
    @client = JumpstartAuth.twitter
  end

  def tweet(message)
  	if message.length <= 140
  		@client.update(message)
  	else
  		puts "Message is too long."
  	end
	end

	def dm(target, message)
	  puts "Trying to send #{target} this direct message:"
	  puts message
	  screen_names = followers_list
	  if screen_names.include?(target)
		  message = "d @#{target} #{message}"
		  tweet(message)
		else
			puts "Target of DM is not currently following you, therefore the DM could not be sent."
		end
	end

	def followers_list
		@client.followers.collect { |follower| @client.user(follower).screen_name }
	end

	def spam_my_followers(message)
		followers_list.each do |follower|
			message = "d @#{follower} #{message}"
			tweet(message)
		end
	end

	def everyones_last_tweet
    friends = @client.friends
    friends = friends.map { |friend| @client.user(friend) }
    friends.sort_by { |friend| friend.name.downcase }
    friends.each do |friend|
      message = friend.status.text
      name = friend.name
      timestamp = friend.status.created_at
      puts "#{name} said..."
      puts message
      puts "... on #{timestamp.strftime("%A, %b %d")}"
      puts ""
    end
  end

  def shorten(original_url)
	  # Shortening Code
	  puts "Shortening this URL: #{original_url}"
	  @bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6') if @bitly.nil?
	  @bitly.shorten(original_url).short_url
	end

	def run
    puts "Welcome to the JSL Twitter Client!"
    command = ""
  	while command != "q"
  	  printf "enter command: "
  	  input = gets.chomp
  	  parts = input.split(" ")
  	  command = parts[0]
  	  case command
  	  	when 'dm' then dm(parts[1], parts[2..-1].join(" "))
  	  	when 'elt' then everyones_last_tweet
  	  	when 'spam' then spam_my_followers(parts[1..-1].join(""))
   	 		when 'q' then puts "Goodbye!"
   	 		when 's' then puts "Shortened to #{shorten(parts[1])}"
   	 		when 't' then tweet(parts[1..-1].join(" "))
   	 		when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
    		else
      	puts "Sorry, I don't know how to #{command}"
  		end
 		end
  end
end

blogger = MicroBlogger.new
blogger.run
