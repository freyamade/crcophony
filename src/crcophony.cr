require "discordcr"
require "hydra"
require "./*"

module Crcophony
  VERSION = "0.6.0"

  # Load config from the environment
  config = Crcophony::Config.new

  # Set up Discord
  client = Discord::Client.new token: config.token, client_id: config.user_id, logger: logger
  cache = Discord::Cache.new(client)
  client.cache = cache

  # Retrieve the list of guilds and channels out here, so we can process them and display progress before opening the application
  puts "Loading Server Data"
  user_guilds = client.get_current_user_guilds
  progress = ProgressBar.new user_guilds.size, 40
  print progress.to_s
  user_guilds.each.with_index do |user_guild, index|
    # Fetch the proper guild object for the channel
    guild = cache.resolve_guild user_guild.id
    # Fetch the channels for the guild
    client.get_guild_channels(guild.id).each do |channel|
      # Ignore non text channels
      next unless channel.type.guild_text?
      # Add channels to the cache to pull them out later
      cache.cache channel
    end
    # Fetch roles (no way to fetch single roles, so just fetch them all)
    client.get_guild_roles(user_guild.id).each do |role|
      cache.cache role
    end

    # Update the progress
    progress.tick
    print progress.to_s
  end
  # Lading DMs and Group Chats
  puts "\nLoading DMs / Group Chats"
  private_channels = client.get_user_dms
  progress = ProgressBar.new private_channels.size, 40
  print progress.to_s
  private_channels.each.with_index do |dm, index|
    # Resolve the channel
    cache.resolve_channel dm.id

    # Update the progress
    progress.tick
    print progress.to_s
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
