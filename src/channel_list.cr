require "discordcr"
require "hydra"

module Crcophony
  # A class for maintaing a list of channels the user has access to
  # Set up to allow for the switching of channels within the application
  class ChannelList < Hydra::List
    @channels : Array(Crcophony::Channel)
    # Keep track of unread messages from all channels here
    @unread_messages : UInt64 = 0

    # TODO - DM Channels
    def initialize(client : Discord::Client, id : String, options = Hash(Symbol, String).new)
      super id, options
      @label = "Select a Channel"
      @channels = get_channels client
      select_first
    end

    # Retrieve a list of channels
    private def get_channels(client : Discord::Client) : Array(Crcophony::Channel)
      channels = [] of Crcophony::Channel

      # First run a method to get all of the servers the user is in
      client.get_current_user_guilds.each do |user_guild|
        # Fetch the proper guild object for the channel
        guild = client.cache.not_nil!.resolve_guild user_guild.id
        # Fetch the channels for the guild
        client.get_guild_channels(guild.id).each do |channel|
          # Ignore non text channels
          next unless channel.type.guild_text?
          channels << Crcophony::Channel.new channel, guild
        end
      end

      return channels
    end

    def get_channel : Crcophony::Channel
      return @channels[@selected]
    end

    def add_unread(channel_id : Discord::Snowflake | UInt64)
      id = channel_id.to_u64
      @unread_messages += 1
      @channels.each do |channel|
        if channel.id.to_u64 == id
          channel.unread_messages += 1
          break
        end
      end
    end

    # Reset the number of unread messages on the current channel to 0, and update the list's total unreads also
    def reset_current_notifications
      channel = get_channel
      unread_messages = channel.unread_messages
      channel.unread_messages = 0_u64
      @unread_messages -= unread_messages
    end

    def content : Hydra::ExtendedString
      lower_bound = @scroll_index * -1
      upper_bound = lower_bound + inner_height - 1
      items = Array(Hydra::ExtendedString).new
      @channels[lower_bound..upper_bound].each_with_index do |item, index|
        if index - @scroll_index == @selected
          items << Hydra::ExtendedString.new "<yellow-fg>#{item.to_s}</yellow-fg>"
        else
          items << Hydra::ExtendedString.new item.to_s
        end
      end
      res = add_box(items)
      Hydra::ExtendedString.new(res)
    end

    def add_item(item : Crcophony::Channel)
      @channels << item
      if @channels.size == 1
        select_first
      end
    end

    def select_first
      @selected = 0
    end

    def change_item(index, item : Crcophony::Channel)
      if @channels[index]?
        @channels[index] = item
      end
    end

    def scroll(value : Int32)
      @scroll_index += value
    end

    def name
      "channel_list"
    end

    def clear
      @channels.clear
    end

    def select_item(index : Int32)
      @selected = index
    end

    def value : String
      return "" if none_selected?
      @channels[@selected].to_s
    end

    def none_selected? : Bool
      @selected == NONE_SELECTED
    end

    def min_scroll_index
      inner_height - @channels.size
    end

    def can_select_up? : Bool
      @selected > 0
    end

    def can_select_down? : Bool
      @selected < @channels.size - 1
    end

    def select_down
      select_item(@selected + 1)
      scroll(-1) if can_scroll_down?
    end

    def select_up
      select_item(@selected - 1)
      scroll(1) if can_scroll_up?
    end

    def can_scroll_up? : Bool
      return false if @channels.size <= inner_height
      @scroll_index < 0
    end

    def can_scroll_down? : Bool
      return false if @channels.size <= inner_height
      @scroll_index > min_scroll_index
    end

    def trigger(behavior : String, payload = Hash(Symbol, String).new)
      case behavior
      when "scroll_up"
        scroll(1) if can_scroll_up?
      when "scroll_down"
        scroll(-1) if can_scroll_down?
      when "select_up"
        select_up if can_select_up?
      when "select_down"
        select_down if can_select_down?
      else
        super
      end
    end
  end
end
