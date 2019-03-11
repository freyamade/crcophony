require "discordcr"

module Crcophony
  # Class that contains a collection of static methods used to parse retrieved messages into a good output format
  class MessageParser
    # Applies all the various required filters to a discord message and returns the output-ready string form
    def self.parse(message : Discord::Message, user_id : UInt64, width : Int32) : Array(String)
      content = message.content
      content = escape_special_chars content
      content = parse_user_mentions content, message.mentions, user_id
      return generate_output message, content, width
    end

    # Generate the output string that will be added to the message box
    private def self.generate_output(payload : Discord::Message, message : String, width : Int32) : Array(String)
      lines = ["#{payload.author.username} @ #{payload.timestamp.to_s "%H:%M:%S"}"]
      wrap_text! message, width, lines
      return lines
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
          replace_string = "<yellow-fg>#{replace_string}</yellow-fg>"
        end
        message = message.gsub /\\<@!?#{user.id}>/, replace_string
      end
      return message
    end

    # Handle word wrapping, also adding the indentation for lines
    private def self.wrap_text!(message : String, width : Int32, lines : Array(String)) : Array(String)
      # Add initial indentation
      message = (" " * 4) + message
      # Provide some padding
      width -= 8
      # Now handle lines
      if message.size < width
        lines << message
        return lines
      end
      while message.size > width
        # Strip the first `width` characters from the message
        lines << message[0..width]
        message = (" " * 4) + message[width..message.size]
      end
      return lines
    end
  end
end
