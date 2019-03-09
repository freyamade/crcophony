require "discordcr"

module Crcophony
  # Class that contains a collection of static methods used to parse retrieved messages into a good output format
  class MessageParser
    # Applies all the various required filters to a discord message and returns the output-ready string form
    def self.parse(message : Discord::Message, user_id : UInt64) : String
      content = message.content
      content = escape_special_chars content
      content = parse_user_mentions content, message.mentions, user_id
      return content
    end

    # Escapes special characters to allow them to be drawn on the display
    private def self.escape_special_chars(message : String) : String
      "<".each_char do |char|
        message = message.gsub char, "\\#{char}"
      end
      return message
    end

    # Replaces Discord's mention string with the appropriate User's username
    private def self.parse_user_mentions(message : String, mentions : Array(Discord::User), user_id : UInt64) : String
      return message unless mentions.size > 0
      mentions.each do |user|
        replace_string = "@#{user.username}"
        if user.id.to_u64 == user_id
          replace_string = "<yellow-fg>#{replace_string}</yellow-fg>" # replace_string.colorize(:black).on_yellow.to_s
        end
        message = message.gsub "\\<@#{user.id}>", replace_string
      end
      return message
    end
  end
end
