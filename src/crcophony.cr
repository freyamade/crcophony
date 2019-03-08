require "discordcr"
require "hydra"

module Crcophony
  VERSION = "0.1.0"

  # Set up Discord
  logger = Logger.new File.new("discord.log", "w")
  channel_id = Discord::Snowflake.new 1_u64
  client = Discord::Client.new token: "", client_id: 0_u64, logger: logger

  # Create our own screen and pass it to the setup
  screen = Hydra::TerminalScreen.new
  view = Hydra::View.new height: screen.height, width: screen.width
  view.filters << Hydra::BorderFilter
  # Initialize an instance of an app
  app = Hydra::Application.setup screen: screen, view: view

  # Once the application is running, pressing ctrl-c will stop it.
  app.bind("keypress.ctrl-c", "application", "stop")

  # Set up basic elements

  # Server#channel label
  server_label_text = "Test#test"
  padding = (screen.width - server_label_text.size) / 2
  server_label = Hydra::Text.new("channel_name", {
    :position => "0:0",
    :width    => screen.width.to_s,
    :height   => "1",
    :value    => "#{" " * padding}#{server_label_text}",
  })
  app.add_element server_label

  # LogBox to hold messages
  message_container = Hydra::Logbox.new("history", {
    :position => "2:0",
    :width    => screen.width.to_s,
    :height   => (screen.height - 3).to_s,
  })
  app.add_element message_container

  # Prompt to type messages to send them
  message_prompt = Hydra::Prompt.new("message-prompt", {
    :position => "#{screen.height - 3}:0",
    :width    => screen.width.to_s,
    :height   => "1",
  })
  app.add_element message_prompt

  # Add message handling to the Discord bot
  client.on_message_create do |payload|
    logger.info "Message received: #{payload.to_s}"
    if payload.channel_id == channel_id
      content = payload.content
      # parse the message for mentions
      if payload.mentions.size > 0
        payload.mentions.each do |user|
          content = content.gsub "<@!#{user.id}>", "@#{user.username}"
        end
      end
      # handle escaping certain symbols
      content = content.gsub "<", "\\<"
      content = content.gsub ">", "\\>"
      message_container.add_message "#{payload.timestamp.to_s "%H:%M:%S"} #{payload.author.username}: #{content}"
    end
  end

  # Give focus to the message entry prompt on start up
  app.bind("ready") do |event_hub, _, elements, state|
    event_hub.focus "message-prompt"
    false
  end

  # When a message is sent, add it to the logbox along with the username
  app.bind("message-prompt", "keypress.enter") do |event_hub|
    # send to discord
    next false unless message_prompt.value
    client.create_message channel_id, message_prompt.value
    event_hub.trigger "message-prompt", "clear"
    false
  end

  # start the client in a separate thread
  spawn do
    client.run
  end

  app.run # => Screen is cleared and the application is displayed

  # The application will loop until ctrl-c is pressed

  app.teardown # => Reset the screen
end
