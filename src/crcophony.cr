require "hydra"

# TODO: Write documentation for `crcophony`
module Crcophony
  VERSION = "0.1.0"

  # Create our own screen and pass it to the setup
  screen = Hydra::TerminalScreen.new
  # Initialize an instance of an app
  app = Hydra::Application.setup screen: screen

  # Once the application is running, pressing ctrl-c will stop it.
  app.bind("keypress.ctrl-c", "application", "stop")

  # Set up basic elements

  # Server#channel label
  server_label_text = "UCC Netsoc#general"
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

  # Give focus to the message entry prompt on start up
  app.bind("ready") do |event_hub, _, elements, state|
    event_hub.focus "message-prompt"
    false
  end

  # When a message is sent, add it to the logbox along with the username
  app.bind("message-prompt", "keypress.enter") do |event_hub|
    message = message_prompt.value
    message_container.add_message "#{Time.now.to_s "%H:%M:%S"} freyamade: #{message}"
    event_hub.trigger "message-prompt", "clear"
    false
  end

  app.run # => Screen is cleared and the application is displayed

  # The application will loop until ctrl-c is pressed

  app.teardown # => Reset the screen
end
