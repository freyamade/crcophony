require "discordcr"
require "hydra"

module Crcophony
  # Class that contains a collection of static methods used to parse retrieved messages into a good output format
  class MessageParser
    # Regex for matching code blocks with an optional language
    @@code_block_regex = /```(?P<language>[a-zA-Z]+\n)?(?!```)(?P<content>[\s\S]*)```/
    # Regex for matching colour tags to avoid them when calculating line lengths
    @@colour_tag_regex = /<\/?[a-z0-9\-]+>/
    # The Client Cache, so the parser can do lookups
    @cache : Discord::Cache
    # Array of special characters that should be escaped
    @to_escape : Array(Char) = ['<']
    # The user currently using crcophony
    @user_id : UInt64
    # The width of the screen (after subtracting 8 cells for padding)
    @width : Int32

    def initialize(@user_id : UInt64, @cache : Discord::Cache, width : Int32)
      # Subtract 8 cells from the width to give 4 cells of padding on each side
      @width = width - 8
    end

    # Parse a received message into a form that looks nice, given the user's highest role in the server
    def parse(message : Discord::Message, role : Discord::Role?) : Array(String)
      content = message.content
      # Escape special characters from the Discord Message so it displays properly
      content = escape_special_chars content
      # Parse code blocks (contained within ``` symbols)
      content = parse_code_blocks content
      # Find mentions of the user by username or nickname and turn it into the name
      content = parse_user_mentions content, message.mentions
      # Parse bodies of embeds and add them to the message
      content = parse_embeds content, message.embeds
      # Add links to attachments to the end of the message body
      content = parse_attachments content, message.attachments
      # Take the now parsed message and format it for output on the screen
      return format_output message, content, role
    end

    # Take the now parsed message and format it for output on the screen
    private def format_output(payload : Discord::Message, message : String, role : Discord::Role?) : Array(String)
      # Get the colour for the username
      username = get_color_for_username payload.author.username, role
      # Put the timestamp on the right hand side in a subtle colour
      timestamp = payload.timestamp.to_s "%H:%M:%S %d/%m/%y"
      spacing = " " * (@width - timestamp.size - payload.author.username.size + 6)
      # Generate the first line
      lines = ["#{username}#{spacing}<grey-fg>#{timestamp}</grey-fg>"]
      # Wrap the rest of the text to fit in the width
      wrap_text! message, lines
      return lines
    end

    # Escape special characters from the Discord Message so it displays properly.
    private def escape_special_chars(content : String) : String
      @to_escape.each do |char|
        content = content.gsub char, "\\#{char}"
      end
      return content
    end

    # Find mentions of the user by username or nickname and turn it into the username.
    # Also colour in mentions of the running user to make them stand out.
    private def parse_user_mentions(content : String, mentions : Array(Discord::User)) : String
      mentions.each do |user|
        replace_string = "@#{user.username}"
        if user.id == @user_id
          replace_string = "<yellow-fg>#{replace_string}</yellow-fg>"
        end
        # <@id> => username, <@!id> => nickname, convert both
        content = content.gsub /\\<@!?#{user.id}>/, replace_string
      end
      return content
    end

    # Parse code blocks (contained within ``` symbols).
    # Will have to be expanded for syntax highlighting at a later date.
    private def parse_code_blocks(content : String) : String
      # Ensure that all code blocks start and finish on a new line
      content = content.gsub /([^\n])```/, "\\1\n```"
      while match = @@code_block_regex.match content
        # We have the potential for a "language" key to syntax highlight later

        # Build the parsed code block by prepending a coloured bar character
        block = match["content"].strip
        parsed_lines = block.split("\n").map { |line| "<navyblue-fg>│ </navyblue-fg>" + line }
        parsed = parsed_lines.join "\n"
        # Replace the block with the parsed lines
        content = content.sub @@code_block_regex, parsed
      end
      return content
    end

    # Parse bodies of embeds and add them to the message.
    private def parse_embeds(content : String, embeds : Array(Discord::Embed)) : String
      return content if embeds.size == 0
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
      return content + "\n#{embed_strings.join "\n"}"
    end

    # Add links to attachments to the end of the message body.
    private def parse_attachments(content : String, attachments : Array(Discord::Attachment)) : String
      return content if attachments.size == 0
      urls = [] of String
      attachments.each do |attachment|
        urls << attachment.proxy_url
      end
      return content + "\nAttachments:\n    #{urls.join "\n    "}"
    end

    # Calculate the color for the username to be rendered in
    private def get_color_for_username(username : String, role : Discord::Role?) : String
      if role.nil?
        return username
      end
      # Look up the color of the role, find the closest to it and add it to the string
      role = role.not_nil!
      color_name = Hydra::Color.new(role.color).name
      return "<#{color_name}-fg>#{username}</#{color_name}-fg>"
    end

    # Handle word wrapping, also adding the indentation for lines
    private def wrap_text!(message : String, lines : Array(String))
      message_lines = message.split "\n"
      # Check for empty message body (for example when uploading an image the text is blank but there is an attachment)
      if message_lines[0] == ""
        message_lines.shift
      end
      message_lines.each do |line|
        # Add initial indentation
        line = (" " * 4) + line
        # Now handle lines
        if message.gsub(@@colour_tag_regex, "").size < @width
          lines << line
        else
          while line.gsub(@@colour_tag_regex, "").size > @width
            # Strip the first `width` characters from the line
            lines << line[0..@width]
            line = (" " * 4) + line[@width..line.size]
          end
          # Add the remaining part of the line to lines
          lines << line
        end
      end
    end
  end
end
