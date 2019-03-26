# An extension of Hydra::Prompt that handles multi-line input as nicely as possible by expanding the box as lines are added
require "hydra"

module Crcophony
  # Extension of the Hydra::Prompt class that binds to and searches a channel list
  class MessagePrompt < Hydra::Prompt
    @messages : Hydra::Logbox
    @initial_height : Int32 = 0
    @messages_initial_height : Int32 = 0
    @initial_position : String = ""

    def initialize(@messages, id : String, options = Hash(Symbol, String).new)
      super id, options
      @messages_initial_height = @messages.height
    end

    private def box_content(content)
      content = content.insert @cursor_position, '|'
      if content.size > (width - 2)
        content = "…" + content[-(width - 3)..-1]
      end
      top_bar = "─" + @label.ljust(width - 3, '─')
      res = "┌" + top_bar + "┐\n"
      content.split("\n").each do |line|
        res += "│" + Hydra::ExtendedString.escape(line.ljust(width - 2)) + "│\n"
      end
      res += "└" + "─" * (width - 2) + "┘"
      res
    end

    # Method called when the element is registered
    def on_register(event_hub : Hydra::EventHub)
      @initial_height = @height
      @initial_position = @position
      super
    end

    # Define methods for increasing and decreasing the size of the prompt
    def increase_size
      # Increase height by 1, move position up one and decrease the messages height by one
      @messages.height -= 1
      @height += 1
      x, y = @position.split(":").map(&.to_i)
      @position = "#{x - 1}:#{y}"
    end

    def decrease_size
      # Decrease height by 1, move position down one and increase the messages height by one
      @messages.height += 1
      @height -= 1
      x, y = @position.split(":").map(&.to_i)
      @position = "#{x + 1}:#{y}"
    end

    # Override methods that interact with the text to control the height
    def append(string : String)
      super string
      # If we've added a newline, increase the height of the prompt
      if (@value.count('\n') + @initial_height) > @height
        increase_size
      end
    end

    def remove_character_at!(position : Int32)
      super position
      # If we've removed a newline, decrease the height of the prompt
      if (@value.count('\n') + @initial_height) < @height
        decrease_size
      end
    end

    def clear
      super
      # Reset all positions and heights
      @position = @initial_position
      @height = @initial_height
      @messages.height = @messages_initial_height
    end
  end
end
