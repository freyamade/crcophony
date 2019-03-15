require "discordcr"

module Crcophony
  # A wrapper class around Discord's channel class that makes things a little easier in this project
  class Channel
    @channel : Discord::Channel
    @server : Discord::Guild?
    @unread_messages : UInt64 = 0_u64
    # Remember the last search string that we calculated
    @prev_search_string : String = ""
    # And the score that was calculated
    @prev_score : Int32 = 0

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

    # Given a search string, calculate a score based on the following table.
    #
    # - Score starts at 0
    # - Matched letter: +0 points
    # - Unmatched letter: -1 point
    # - Consecutive match bonus: +5 points
    def match_score(search_string : String) : Int32
      if search_string == @prev_search_string
        return @prev_score
      end
      # Calculate a score for this channel name
      score = 0
      name = self.to_s
      # Index into this channel's name
      name_index = 0
      # Index into the search_string
      search_index = 0
      # Keep track of the position of the previous find
      prev_find_index = 0
      while name_index < name.size && search_index < search_string.size
        if name[name_index] == search_string[search_index]
          # Check the previous found index
          if prev_find_index + 1 == search_index
            score += 5
            prev_find_index = search_index
          end
          search_index += 1
        else
          # We didn't find one, subtract one from the score
          score -= 1
        end
        name_index += 1
      end
      # Cache stuff
      @prev_search_string = search_string
      @prev_score = score
      # Just return the score
      return score
    end

    # The number of unread messages in the channel (used only in the switcher)
    property unread_messages
  end
end
