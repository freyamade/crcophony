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
