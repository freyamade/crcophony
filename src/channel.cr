require "discordcr"

module Crcophony
  # A wrapper class around Discord's channel class that makes things a little easier in this project
  class Channel
    @channel : Discord::Channel
    @server : Discord::Guild?
    @unread_messages : UInt64 = 0_u64

    # Private Channels do not have guild ids
    def initialize(@channel : Discord::Channel)
    end

    def initialize(@channel : Discord::Channel, @server : Discord::Guild)
    end

    def to_s : String
      builder = String::Builder.new
      if !@server.nil?
        builder << "#{@server.not_nil!.name}##{@channel.name}"
      else
        builder << @channel.name
      end
      if @unread_messages > 0
        builder << " [#{@unread_messages}]"
      end
      return builder.to_s
    end

    def id
      return @channel.id
    end

    # The number of unread messages in the channel (used only in the switcher)
    property unread_messages
  end
end
