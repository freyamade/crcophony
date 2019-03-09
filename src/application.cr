require "discordcr"
require "hydra"
require "./extensions/*"

module Crcophony
  # Class that manages the display and all stuff related to it
  #
  # This class also provides helper methods for cleanly updating parts of the display
  class Application
    @app : Hydra::Application
    @channel : Discord::Channel
    @channel_name : Hydra::Text
    @client : Discord::Client
    @messages : Hydra::Logbox
    @prompt : Hydra::Prompt
    @screen : Hydra::TerminalScreen

    def initialize(@client : Discord::Client, channel : Discord::Snowflake)
      @screen = Hydra::TerminalScreen.new
      @app = Hydra::Application.setup screen: @screen

      # Set up a ready listener that auto adds focus to the prompt
      # Give focus to the message entry prompt on start up
      @app.bind("ready") do |event_hub, _, _, _|
        event_hub.focus "prompt"
        false
      end

      # Set up the elements in the application display
      # Channel name text display
      @channel_name = Hydra::Text.new("channel_name", {
        :position => "0:0",
        :width    => @screen.width.to_s,
        :height   => "1",
        :value    => "", # This will be filled in later
      })
      @app.add_element @channel_name

      # Messages container
      @messages = Hydra::Logbox.new("messages", {
        :position => "2:0",
        :width    => @screen.width.to_s,
        :height   => (@screen.height - 3).to_s,
      })
      @app.add_element @messages

      # Message Prompt
      @prompt = Hydra::Prompt.new("prompt", {
        :position => "#{@screen.height - 3}:0",
        :width    => @screen.width.to_s,
        :height   => "1",
      })
      @app.add_element @prompt

      # Read the channel data from the cache
      @channel = @client.cache.not_nil!.resolve_channel(channel).not_nil!
      # Set the initial server label
      set_channel @channel
      # Set up various keybinds

      setup_keybinds
    end

    # Wrapper around @app.run
    def run
      @app.run
    end

    # Wrapper around @app.teardown
    def teardown
      @app.teardown
    end

    # Change the app to display the new channel in the specified server
    #
    # This function updates the top label, clears the old message box and retrieves some history for context (TODO)
    def set_channel(channel : Discord::Channel)
      @channel = channel
      server = @client.cache.not_nil!.resolve_guild(@channel.guild_id.not_nil!)
      @channel_name.value = generate_label server, channel
      @messages.clear
      # Retrieve a message history
      @client.get_channel_messages(@channel.id).reverse.each do |message|
        handle_message message
      end
    end

    # Handler for receiving a message via the Discord client
    def handle_message(message : Discord::Message)
      if message.channel_id == @channel.id
        # First do the various parsing and escaping we need to do
        # Then add the message to the logbox
        content = Crcophony::MessageParser.parse message, @client.client_id.to_u64
        @messages.add_message "#{message.timestamp.to_s "%H:%M:%S"} #{message.author.username}: #{content}"
      end
    end

    # Set up the various keybinds used within the system
    #
    # - <kbd>Ctrl</kbd>+<kbd>C</kbd>: Quit Application
    # - <kbd>Enter</kbd>: Send Message
    private def setup_keybinds
      # Close the application on Ctrl+C
      @app.bind("keypress.ctrl-c", "application", "stop")
      # Send message on Enter
      @app.bind("prompt", "keypress.enter") do |event_hub|
        # send to discord
        message = @prompt.value.strip
        next false unless message.size > 0
        @client.create_message @channel.id, message
        event_hub.trigger "prompt", "clear"
        false
      end
    end

    # Generate a centered channel name given a server and a channel
    private def generate_label(server : Discord::Guild, channel : Discord::Channel) : String
      label = "#{server.name}##{channel.name}"
      padding = (@screen.width - label.size) / 2
      return "#{" " * padding}#{label}"
    end
  end
end
