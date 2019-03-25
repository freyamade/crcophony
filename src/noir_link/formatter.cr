require "hydra"
require "noir/formatter"
require "noir/theme"

module Crcophony
  class SyntaxFormatter < Noir::Formatter
    def initialize(@theme : Noir::Theme, @out : IO)
    end

    def format(token, value) : Nil
      if token
        style = @theme.style_for token
      else
        style = @theme.base_style
      end

      value.each_line(chomp: false) do |line|
        wrote = false
        color_name = ""
        if c = style.fore
          color_int = "#{c.red.to_s 16}#{c.green.to_s 16}#{c.blue.to_s 16}".to_u32 16
          color_name = Hydra::Color.new(color_int).name
          @out << "<#{color_name}-fg>"
          wrote = true
        end

        # These aren't handled by Hydra yet
        # if style.bold
        #   @out << "\e[" unless wrote
        #   @out << ";" if wrote
        #   @out << "1"
        #   wrote = true
        # end

        # if style.italic
        #   @out << "\e[" unless wrote
        #   @out << ";" if wrote
        #   @out << "3"
        #   wrote = true
        # end

        # if style.underline
        #   @out << "\e[" unless wrote
        #   @out << ";" if wrote
        #   @out << "4"
        #   wrote = true
        # end

        @out << line.chomp
        @out << "</#{color_name}-fg>"
        @out.puts if line.ends_with?("\n")
      end
    end
  end
end
