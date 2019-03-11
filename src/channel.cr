require "discordcr"

module Crcophony
  # A wrapper class around Discord's channel class that makes things a little easier in this project
  class Channel
    @channel : Discord::Channel
    @server : Discord::Guild
    @unread_messages : UInt64 = 0_u64

    def initialize(@channel : Discord::Channel, @server : Discord::Server)
    end

    def to_s : String
      builder = String::Builder.new
      builder << "#{@server.name}##{@channel.name}"
      if @unread_messages > 0
        builder << " [#{@unread_messages}]"
      end
      return builder.to_s
    end

    def id
      return @channel.id
    end
  end
end
