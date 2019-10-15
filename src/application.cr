require "discordcr"
require "hydra"
require "logger"
require "notify"
require "./elements/*"

module Crcophony
  # Class that manages the display and all stuff related to it
  #
  # This class also provides helper methods for cleanly updating parts of the display
  class Application
    @app : Hydra::Application
    @channel : Crcophony::Channel
    @channel_list : Crcophony::ChannelList
    @channel_name : Hydra::Text
    @channel_prompt : Crcophony::Searcher
    @client : Discord::Client
    @messages : Hydra::Logbox
    @parser : Crcophony::MessageParser
    @prompt : Crcophony::MessagePrompt
    @screen : Hydra::TerminalScreen
    # user_id => guild_id => color role
    @user_color_cache : Hash(UInt64, Hash(UInt64, Discord::Role)) = Hash(UInt64, Hash(UInt64, Discord::Role)).new
    # {user_id, guild_id}
    @user_nil_role_cache : Set(Tuple(UInt64, UInt64)) = Set(Tuple(UInt64, UInt64)).new

    def initialize(@client : Discord::Client)
      @screen = Hydra::TerminalScreen.new
      @app = Hydra::Application.setup screen: @screen, logger: Logger.new(nil)

      # Create a parser instance
      @parser = Crcophony::MessageParser.new @client.client_id.to_u64, @client.cache.not_nil!, @screen.width

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
      channel_x = (@screen.height.to_f / 2 - 13.to_f / 2).floor.to_i
      channel_y = (@screen.width.to_f / 2 - (@screen.width / 4 * 3).to_f / 2).floor.to_i
      @channel_list = Crcophony::ChannelList.new(@client, "channels", {
        :position => "#{channel_x}:#{channel_y}",
        :width    => "#{@screen.width // 4 * 3}",
        :height   => "13", # "#{@screen.height / 4 * 3}",
        :z_index  => "1",
        :visible  => "false",
      })

      # Set the current channel to be the first channel in the list
      # Set up the channel list to open the dev channel first by default
      @channel = @channel_list.get_channel

      # Set up necessary bindings before creating the prompt as we want our keybinds to made before the prompt's default ones
      setup_bindings

      # Message Prompt
      @prompt = Crcophony::MessagePrompt.new(@messages, "prompt", {
        :position => "#{@screen.height - 3}:0",
        :width    => @screen.width.to_s,
        :height   => "2",
      })

      # Channel Searching Prompt
      @channel_prompt = Crcophony::Searcher.new(@channel_list, "channel_prompt", {
        :position => "#{channel_x - 2}:#{channel_y}",
        :width    => "#{@screen.width // 4 * 3}",
        :height   => "2",
        :z_index  => "1",
        :visible  => "false",
        :label    => "Search for Channels",
      })

      # Add the elements to the application, ensuring to add messages last so the scrollbar is visible
      @app.add_element @channel_list
      @app.add_element @channel_prompt
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
      @channel_list.reset_current_notifications channel
      if @channel.id != channel.id
        @channel_list.prev_channel = @channel
      end
      @channel = channel
      @channel_name.value = generate_label channel
      @messages.clear

      # Retrieve a message history
      @client.get_channel_messages(@channel.id).reverse.each do |message|
        # Add a guild id to the message
        message.guild_id = @channel.guild_id
        handle_message message, false
      end
      # Scroll to the bottom
      while @messages.can_scroll_down?
        @messages.scroll -1
      end
      # Update manually here
      @app.trigger "update"
    end

    # Handler for receiving a message via the Discord client
    # Update the screen if update is true (this flag is used to not update until all messages are loaded in case of changing channel)
    def handle_message(message : Discord::Message, update : Bool = true)
      # Basic Notification
      if message.channel_id == @channel.id
        # First do the various parsing and escaping we need to do
        # Then add the message to the logbox
        # Get the role for the username colours
        role = get_role_for_message message
        @parser.parse(message, role).each do |line|
          @messages.add_message line
        end
      else
        @channel_list.add_unread message.channel_id
        # Update the label with the current number of unreads
        @channel_name.value = generate_label @channel
      end
      # Trigger an update manually
      if update
        @app.trigger "update"
      end
    end

    # Given a message, look up the user and the guild to get a list of roles and return the highest one (the one that provides the color)
    private def get_role_for_message(message : Discord::Message) : Discord::Role?
      if message.guild_id.nil?
        return nil
      end

      # Get the necessary information from the message
      user_id = message.author.id.to_u64
      guild_id = message.guild_id.not_nil!.to_u64
      nil_cache_key = {user_id, guild_id}

      # Check if the nil cache exist
      if @user_nil_role_cache.includes? nil_cache_key
        return nil
      end

      # Check the user color cache
      if @user_color_cache[user_id]? && @user_color_cache[user_id][guild_id]?
        return @user_color_cache[user_id][guild_id]
      end

      # Not in cache, so attempt to fetch if
      cache = @client.cache.not_nil!
      guild_member : Discord::GuildMember

      # Wrap in a begin to ensure 404 errors are handled properly
      begin
        guild_member = cache.resolve_member message.guild_id.not_nil!, message.author.id
      rescue
        # Add the nil cache
        @user_nil_role_cache.add nil_cache_key
        return nil
      end

      # Check if the user has a role in the server
      if guild_member.roles.size == 0
        # Add the nil cache
        @user_nil_role_cache.add nil_cache_key
        return nil
      end

      # Map the role ids to their object forms and get the one with the highest position
      roles = guild_member.roles.map { |a| cache.resolve_role(a) }
      roles.sort! { |a, b| b.position <=> a.position }
      role = roles[0]

      # Cache the role
      if !@user_color_cache[user_id]?
        @user_color_cache[user_id] = {} of UInt64 => Discord::Role
      end
      @user_color_cache[user_id][guild_id] = role
      return role
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

      # Insert newline into prompt with ctrl + n
      @app.bind("prompt", "keypress.ctrl-n") do |event_hub|
        event_hub.trigger "prompt", "append", {:char => "\n"}
        false
      end

      # Scroll up to scroll box
      @app.bind("prompt", "keypress.ctrl-w") do |event_hub|
        event_hub.trigger "messages", "scroll_up"
        false
      end
      @app.bind("prompt", "keypress.up") do |event_hub|
        event_hub.trigger "messages", "scroll_up"
        false
      end
      # Scroll down the scrollbox
      @app.bind("prompt", "keypress.ctrl-s") do |event_hub|
        event_hub.trigger "messages", "scroll_down"
        false
      end
      @app.bind("prompt", "keypress.down") do |event_hub|
        event_hub.trigger "messages", "scroll_down"
        false
      end

      # Show the Channel Switcher
      @app.bind("prompt", "keypress.ctrl-k") do |event_hub|
        event_hub.trigger "channels", "show"
        event_hub.trigger "channel_prompt", "show"
        event_hub.focus "channel_prompt"
        false
      end

      # Move channel selection up one
      @app.bind("channel_prompt", "keypress.ctrl-w") do |event_hub|
        event_hub.trigger "channels", "select_up"
        false
      end
      @app.bind("channel_prompt", "keypress.up") do |event_hub|
        event_hub.trigger "channels", "select_up"
        false
      end
      # Move channel selection down one
      @app.bind("channel_prompt", "keypress.ctrl-s") do |event_hub|
        event_hub.trigger "channels", "select_down"
        false
      end
      @app.bind("channel_prompt", "keypress.down") do |event_hub|
        event_hub.trigger "channels", "select_down"
        false
      end

      # Make Channel Selection
      @app.bind("channel_prompt", "keypress.enter") do |event_hub|
        channel : Crcophony::Channel = @channel_list.not_nil!.get_channel
        # Move selection back to 0 since the filtered list could change
        @channel_list.not_nil!.reset_selection
        set_channel channel
        event_hub.trigger "channels", "hide"
        event_hub.trigger "channel_prompt", "hide"
        event_hub.focus "prompt"
        false
      end

      # Hide the Channel Switcher
      @app.bind("channel_prompt", "keypress.ctrl-k") do |event_hub|
        event_hub.trigger "channels", "hide"
        event_hub.trigger "channel_prompt", "hide"
        event_hub.focus "prompt"
        false
      end
      @app.bind("channel_prompt", "keypress.escape") do |event_hub|
        event_hub.trigger "channels", "hide"
        event_hub.trigger "channel_prompt", "hide"
        event_hub.focus "prompt"
        false
      end
    end

    # Generate a centered channel name given a server and a channel
    private def generate_label(channel : Crcophony::Channel) : String
      label = channel.to_s
      left_padding = (@screen.width - label.size) // 2
      right_string = ""
      if @channel_list.unread_messages > 0
        # Add on a notifications display at the top right
        notif_string = "[#{@channel_list.unread_messages}]"
        right_padding = (@screen.width - label.size - notif_string.size - 8) // 2
        right_string = "#{" " * right_padding}#{notif_string}"
      end
      return "#{" " * left_padding}#{label}#{right_string}"
    end
  end
end
