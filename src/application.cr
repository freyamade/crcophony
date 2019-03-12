require "discordcr"
require "hydra"

module Crcophony
  # Class that manages the display and all stuff related to it
  #
  # This class also provides helper methods for cleanly updating parts of the display
  class Application
    @app : Hydra::Application
    @channel : Crcophony::Channel
    @channel_list : Crcophony::ChannelList
    @channel_name : Hydra::Text
    @client : Discord::Client
    @messages : Hydra::Logbox
    @prompt : Hydra::Prompt
    @screen : Hydra::TerminalScreen

    def initialize(@client : Discord::Client, channel : Discord::Snowflake)
      @screen = Hydra::TerminalScreen.new
      @app = Hydra::Application.setup screen: @screen
      # Read the channel data from the cache
      channel = @client.cache.not_nil!.resolve_channel(channel).not_nil!
      guild = @client.cache.not_nil!.resolve_guild(channel.guild_id.not_nil!).not_nil!
      @channel = Crcophony::Channel.new channel, guild

      # Set up the elements in the application display
      # Channel name text display
      @channel_name = Hydra::Text.new("channel_name", {
        :position => "0:0",
        :width    => @screen.width.to_s,
        :height   => "1",
        :label    => "Crcophony #{VERSION}",
      })

      # Messages container
      @messages = Hydra::Logbox.new("messages", {
        :position => "2:0",
        :width    => @screen.width.to_s,
        :height   => (@screen.height - 4).to_s,
      })

      # Create a channel list
      @channel_list = Crcophony::ChannelList.new(@client, "channels", {
        :position => "center",
        :width    => "#{@screen.width / 4 * 3}",
        :height   => "#{@screen.height / 4 * 3}",
        :z_index  => "5",
        :visible  => "false",
      })

      # Set up necessary bindings before creating the prompt as we want our keybinds to made before the prompt's default ones
      setup_bindings

      # Message Prompt
      @prompt = Hydra::Prompt.new("prompt", {
        :position => "#{@screen.height - 3}:0",
        :width    => @screen.width.to_s,
        :height   => "2",
      })

      # Add the elements to the application, ensuring to add messages last so the scrollbar is visible
      @app.add_element @channel_list
      @app.add_element @channel_name
      @app.add_element @prompt
      @app.add_element @messages

      # Set the initial server label
      set_channel @channel
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
    # This function updates the top label, clears the old message box and retrieves some (50) messages for context
    def set_channel(channel : Crcophony::Channel)
      # Set the unread messages to 0 now that we have opened the channel
      channel.unread_messages = 0_u64
      @channel = channel
      @channel_name.value = generate_label channel
      @messages.clear

      # Retrieve a message history
      @client.get_channel_messages(@channel.id).reverse.each do |message|
        handle_message message
      end
      # Scroll to the bottom
      while @messages.can_scroll_down?
        @messages.scroll -1
      end
    end

    # Handler for receiving a message via the Discord client
    def handle_message(message : Discord::Message)
      if message.channel_id == @channel.id
        # First do the various parsing and escaping we need to do
        # Then add the message to the logbox
        Crcophony::MessageParser.parse(message, @client.client_id.to_u64, @screen.width).each do |line|
          @messages.add_message line
        end
      else
        @channel_list.add_unread message.channel_id
      end
    end

    # Set up the various bindings used within the system
    #
    # ## Keybinds
    # - <kbd>Ctrl</kbd>+<kbd>C</kbd>: Quit Application
    # - <kbd>Enter</kbd>: Send Message
    # - <kbd>Ctrl</kbd>+<kbd>W</kbd>: Scroll Up
    # - <kbd>Ctrl</kbd>+<kbd>S</kbd>: Scroll Down
    # ## Channel Switching
    # - <kbd>Ctrl</kbd>+<kbd>K</kbd>: Open / Close Channel Selection Menu
    # - <kbd>Enter</kbd>: Select Channel
    # - <kbd>Ctrl</kbd>+<kbd>W</kbd>: Scroll Selection Up
    # - <kbd>Ctrl</kbd>+<kbd>S</kbd>: Scroll Selection Down
    # - <kbd>ESC</kbd>: Alternative Close Button
    private def setup_bindings
      # Set up a ready listener that auto adds focus to the prompt
      # Give focus to the message entry prompt on start up
      @app.bind("ready") do |event_hub, _, _, _|
        event_hub.focus "prompt"
        false
      end
      # Close the application on Ctrl+C
      @app.bind("keypress.ctrl-c", "application", "stop")
      # Send message on Enter
      @app.bind("prompt", "keypress.enter") do |event_hub, _, elements, _|
        # send to discord
        message = elements.by_id("prompt").as(Hydra::Prompt).value.strip
        next false unless message.size > 0
        @client.create_message @channel.id, message
        event_hub.trigger "prompt", "clear"
        false
      end
      # Scroll up to scroll box
      @app.bind("prompt", "keypress.") do |event_hub|
        event_hub.trigger "messages", "scroll_up"
        false
      end
      # Scroll down the scrollbox
      @app.bind("prompt", "keypress.") do |event_hub|
        event_hub.trigger "messages", "scroll_down"
        false
      end

      # Show the Channel Switcher
      @app.bind("prompt", "keypress.") do |event_hub|
        event_hub.trigger "channels", "show"
        event_hub.focus "channels"
        false
      end

      # Move channel selection up one
      @app.bind("channels", "keypress.") do |event_hub|
        event_hub.trigger "channels", "select_up"
        false
      end
      # Move channel selection down one
      @app.bind("channels", "keypress.") do |event_hub|
        event_hub.trigger "channels", "select_down"
        false
      end

      # Make Channel Selection
      @app.bind("channels", "keypress.enter") do |event_hub|
        channel : Crcophony::Channel = @channel_list.not_nil!.get_channel
        set_channel channel
        event_hub.trigger "channels", "hide"
        event_hub.focus "prompt"
        false
      end

      # Hide the Channel Switcher
      @app.bind("channels", "keypress.") do |event_hub|
        event_hub.trigger "channels", "hide"
        event_hub.focus "prompt"
        false
      end
      @app.bind("channels", "keypress.escape") do |event_hub|
        event_hub.trigger "channels", "hide"
        event_hub.focus "prompt"
        false
      end
    end

    # Generate a centered channel name given a server and a channel
    private def generate_label(channel : Crcophony::Channel) : String
      label = channel.to_s
      padding = (@screen.width - label.size) / 2
      return "#{" " * padding}#{label}"
    end
  end
end
