module Hydra
  class Application
    private def handle_keypress(keypress : Keypress | Nil)
      if keypress.nil?
        # Even if no button is pressed, we should still update the screen
        update_screen
        return
      else
        event = Event.new(keypress)
        @event_hub.broadcast(event, @state, @elements)
        update_screen
      end
    end
  end
end
