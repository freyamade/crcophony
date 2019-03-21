require "discordcr"
require "hydra"

module Crcophony
  # Class that contains a collection of static methods used to parse retrieved messages into a good output format
  class MessageParser
    # Applies all the various required filters to a discord message and returns the output-ready string form
    def self.parse(message : Discord::Message, user_id : UInt64, width : Int32, role : Discord::Role?) : Array(String)
      content = message.content
      content = escape_special_chars content
      content = parse_user_mentions content, message.mentions, user_id
      content = parse_attachments content, message.attachments
      content = parse_embeds content, message.embeds
      return generate_output message, content, width, role
    end

    # Generate the output string that will be added to the message box
    private def self.generate_output(payload : Discord::Message, message : String, width : Int32, role : Discord::Role?) : Array(String)
      username = get_color_for_username payload.author.username, role
      lines = ["#{payload.timestamp.to_s "%H:%M:%S"} #{username}"]
      wrap_text! message, width, lines
      return lines
    end

    # Calculate the color for the username to be rendered in
    private def self.get_color_for_username(username : String, role : Discord::Role?) : String
      if role.nil?
        return username
      end
      # Look up the color of the role, find the closest to it and add it to the string
      role = role.not_nil!
      color_name = Hydra::Color.new(role.color).name
      return "<#{color_name}-fg>#{username}</#{color_name}-fg>"
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
      # Provide some padding
      width -= 8
      message_lines = message.split "\n"
      message_lines.each do |line|
        # Add initial indentation
        line = (" " * 4) + line
        # Now handle lines
        if message.size < width
          lines << line
        else
          while line.size > width
            # Strip the first `width` characters from the line
            lines << line[0..width]
            line = (" " * 4) + line[width..line.size]
          end
          # Add the remaining part of the line to lines
          lines << line
        end
      end
      return lines
    end

    # Add attachment URLs to the message
    private def self.parse_attachments(message : String, attachments : Array(Discord::Attachment)) : String
      return message if attachments.size == 0
      urls = [] of String
      attachments.each do |attachment|
        urls << attachment.proxy_url
      end
      return message + "\nAttachments:\n    #{urls.join "\n    "}"
    end

    # Add embeds to the message
    private def self.parse_embeds(message : String, embeds : Array(Discord::Embed)) : String
      return message if embeds.size == 0
      embed_strings = [] of String
      embeds.each do |embed|
        text : String
        if embed.title.nil?
          text = "Embed"
        else
          text = embed.title.not_nil!
        end
        if !embed.colour.nil?
          colour = Hydra::Color.new(embed.colour.not_nil!).name
          text = "<#{colour}-fg>#{text}</#{colour}-fg>"
        end
        if !embed.description.nil?
          text += "\n    #{embed.description.not_nil!.split("\n").join("\n    ")}"
        end
        if !embed.url.nil?
          text += "\n    #{embed.url.not_nil!}"
        end
        embed_strings << text
      end
      return message + "\n#{embed_strings.join "\n"}"
    end
  end
end
