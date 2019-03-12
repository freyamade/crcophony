require "hydra"

module Crcophony
  # Extension of the Hydra::Prompt class that binds to and searches a channel list
  class Searcher < Hydra::Prompt
    @channel_list : Crcophony::ChannelList

    def initialize(@channel_list, id : String, options = Hash(Symbol, String).new)
      super id, options
    end

    # Overwrite some methods
    def append(string : String)
      super string
      # Call the search method on the channel list instance
      @channel_list.search @value
    end

    # When the prompt is cleared, also clear the search value on the list
    def clear
      super
      @channel_list.search ""
    end

    def hide
      super
      # Clear the input
      clear
    end
  end
end
