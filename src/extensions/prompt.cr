require "hydra"

module Hydra
  class Prompt
    def on_register(event_hub : Hydra::EventHub)
      # Special handling for full stops
      event_hub.bind(id, "keypress..") do |eh|
        eh.trigger id, "append", {:char => "."}
        false
      end
      event_hub.bind(id, "keypress.*") do |eh, event|
        keypress = event.keypress
        if keypress
          if keypress.char != ""
            eh.trigger(id, "append", {:char => keypress.char})
            false
          elsif keypress.name == "backspace"
            eh.trigger(id, "remove_last")
            false
          else
            true
          end
        else
          true
        end
      end
    end
  end
end
