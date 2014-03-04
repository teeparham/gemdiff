module Gemdiff
  module Colorize
    COLORS =
      {
        red:     31,
        green:   32,
        yellow:  33,
        blue:    34,
        magenta: 35,
      }

    # works with `git show` and `git diff`
    def colorize_git_output(lines)
      out = []
      lines.split("\n").each do |line|
        out <<
          if line.start_with?("---") || line.start_with?("+++") || line.start_with?("diff") || line.start_with?("index")
            colorize line, :blue
          elsif line.start_with?("@@")
            colorize line, :magenta
          elsif line.start_with?("commit")
            colorize line, :yellow
          elsif line.start_with?("-")
            colorize line, :red
          elsif line.start_with?("+")
            colorize line, :green
          else
            line
          end
      end
      out.join("\n")
    end

    def colorize(string, color)
      "\e[#{to_color_code(color)}m#{string}\e[0m"
    end

  private

    def to_color_code(color)
      COLORS[color] || 30
    end
  end
end
