require "discordcr"

module Crcophony
  # A wrapper class around Discord's channel class that makes things a little easier in this project
  class Channel
    # The Discord equivalent for this channel
    @channel : Discord::Channel
    # A flag stating whether or not the initial load for the channel has been done
    @loaded : Bool = false
    # Keep an array of messages sent in the channel
    @messages : Array(Discord::Message)
    # The Discord Server this channel is attached to, if any
    @server : Discord::Guild?
    # Remember the last search string that we calculated
    @prev_search_string : String = ""
    # And the score that was calculated
    @prev_score : Int32 = 0
    # Maintain a count of how many messages we haven't read (can use this for later)
    @unread_messages : UInt64 = 0_u64

    # Private Channels do not have guild ids
    def initialize(@channel : Discord::Channel)
      @messages = [] of Discord::Message
    end

    def initialize(@channel : Discord::Channel, @server : Discord::Guild)
      @messages = [] of Discord::Message
    end

    def <<(message : Discord::Message)
      @messages << message
    end

    def prev_message : Discord::Message?
      return @messages[@messages.size - 1]?
    end

    def to_s : String
      builder = String::Builder.new
      if !@server.nil?
        builder << "#{@server.not_nil!.name}##{@channel.name}"
      else
        # Generate the name for the DM
        if @channel.name
          builder << @channel.name
        else
          names = [] of String
          @channel.recipients.not_nil!.each do |user|
            names << user.username
          end
          name = names.join ", "
          # Cache the name in the channel
          @channel.name = name
          builder << name
        end
      end
      if @unread_messages > 0
        builder << " [#{@unread_messages}]"
      end
      return builder.to_s
    end

    def id
      return @channel.id
    end

    def guild_id
      if @server.nil?
        return nil
      end
      return @server.not_nil!.id
    end

    # Given a search string, calculate a score based on the following table.
    #
    # - Score starts at 0
    # - Matched letter: +0 points
    # - Unmatched letter: -1 point
    # - Consecutive match bonus: +5 points
    # - Unmatched characters from search string: -3 per character
    def match_score(search_string : String) : Int32
      if search_string == @prev_search_string
        return @prev_score
      end
      # Calculate a score for this channel name
      score = 0
      name : String
      if @server
        name = self.to_s.split("#")[1].downcase
      else
        name = self.to_s.downcase
      end
      # Index into this channel's name
      name_index = 0
      # Index into the search_string
      search_index = 0
      # Keep track of the position of the previous find
      prev_matched = false
      while name_index < name.size && search_index < search_string.size
        if name[name_index] == search_string[search_index]
          # Check the previous found index
          if prev_matched
            score += 5
          end
          prev_matched = true
          search_index += 1
        else
          # We didn't find one, subtract one from the score
          score -= 1
          prev_matched = false
        end
        name_index += 1
      end
      while search_index < search_string.size
        # Subtract 3 from the score for all missed search characters
        score -= 3
        search_index += 1
      end
      # Cache stuff
      @prev_search_string = search_string
      @prev_score = score
      # Just return the score
      return score
    end

    # Keep track of whether or not we have done an inital load of messages for this channel
    property loaded
    # The cached messages
    getter messages
    # The number of unread messages in the channel (used only in the switcher)
    property unread_messages
  end
end
