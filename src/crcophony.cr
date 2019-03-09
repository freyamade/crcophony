require "colorize"
require "discordcr"
require "hydra"
require "./*"

module Crcophony
  VERSION = "0.1.0"

  #############################################################################
  #                            BEGIN USER VARIABLES                           #
  #############################################################################
  channel_id = 1_u64
  user_id = 0_u64
  token = ""
  #############################################################################
  #                             END USER VARIABLES                            #
  #############################################################################

  # Set up Discord
  channel = Discord::Snowflake.new channel_id
  logger = Logger.new File.new("discord.log", "w")
  client = Discord::Client.new token: token, client_id: user_id, logger: logger
  cache = Discord::Cache.new(client)
  client.cache = cache

  # Create a Crcophony Application instance
  app = Crcophony::Application.new client, channel

  # Add message handling to the Discord bot
  client.on_message_create do |payload|
    app.handle_message payload
  end

  # start the client in a separate thread
  spawn do
    client.run
  end

  app.run # => Screen is cleared and the application is displayed

  # The application will loop until ctrl-c is pressed

  app.teardown # => Reset the screen
end
