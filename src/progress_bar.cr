module Crcophony
  # A simple terminal progress bar to render progress bars when loading things
  class ProgressBar
    # The final value
    @max_value : Int32
    # The number of percent completion each `=` is worth
    @percent_per_symbol : Float64 = 5.0
    # The symbol used to render the progress bar
    @symbol = "="
    # The current value
    @value : Int32 = 0
    # The width of the bar, in character (default 40)
    @width : Int32 = 20

    def initialize(@max_value : Int32)
    end

    def initialize(@max_value : Int32, @symbol : String)
    end

    def initialize(@max_value : Int32, @width : Int32)
      @percent_per_symbol = 100.0 / @width
    end

    def initialize(@max_value : Int32, @width : Int32, @symbol : String)
      @percent_per_symbol = 100.0 / @width
    end

    # Increment the current value
    def tick
      @value += 1
    end

    # Render the progress bar, including the \r character that will return to the start of the line
    def to_s
      # First calculate the percentage progress that has been made
      progress = (@value * 100) / @max_value
      # Progress bar will be @width characters long, so determine how symbols to display
      symbols = (progress / @percent_per_symbol).to_i
      # Generate the bar first, left justified to the length of the bar
      bar = (@symbol * symbols).ljust @width
      # Generate the string
      return "\r[#{bar}] [#{@value} / #{@max_value}]"
    end
  end
end
