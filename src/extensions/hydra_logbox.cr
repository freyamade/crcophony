require "hydra"

# Add a clear method to the logbox class that empties the messages array
module Hydra
  class Logbox
    def clear
      @messages = [] of Hydra::ExtendedString
    end
  end
end
