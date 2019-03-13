require "discordcr"
require "hydra"
require "./*"

module Crcophony
  VERSION = "0.1.0"

  # Load config from the environment
  config = Crcophony::Config.new

  # Set up Discord
  logger = Logger.new File.new "discord.log", "w"
  client = Discord::Client.new token: config.token, client_id: config.user_id, logger: logger
  cache = Discord::Cache.new(client)
  client.cache = cache

  # Retrieve the list of guilds and channels out here, so we can process them and display progress before opening the application
  puts "Loading Channel Data"
  user_guilds = client.get_current_user_guilds
  user_guilds.each.with_index do |user_guild, index|
    puts "Reading Channels in Server #{index + 1}/#{user_guilds.size}"
    # Fetch the proper guild object for the channel
    guild = cache.resolve_guild user_guild.id
    # Fetch the channels for the guild
    client.get_guild_channels(guild.id).each do |channel|
      # Ignore non text channels
      next unless channel.type.guild_text?
      # Add channels to the cache to pull them out later
      cache.cache channel
    end
  end

  # Create a Crcophony Application instance
  app = Crcophony::Application.new client

  # Add message handling to the Discord bot
  client.on_message_create do |payload|
    app.handle_message payload
  end

  # start the client in a separate thread
  spawn do
    client.run
  end

  begin
    app.run # => Screen is cleared and the application is displayed
    # The application will loop until ctrl-c is pressed or an exception is raised
  ensure
    app.teardown # => Reset the screen
  end
end
