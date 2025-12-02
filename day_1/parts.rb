require_relative "../setup"

class Part
  def initialize(input)
    @movements = input
      .split("\n")
      .map { |v| [v[0], v[1..].to_i] }
  end
end

module Day1
  class Part1 < Part
    def solve
      dial = (0..99).to_a

      position = 50

      @movements.count do |direction, value|
        case direction
        when "L"
          position -= value
        when "R"
          position += value
        end

        dial[position % dial.size].zero?
      end
    end
  end

  class Part2 < Part
    def solve
      dial = (0..99).to_a

      position = 50

      @movements.sum do |direction, value|
        tick = direction == "L" ? -1 : 1

        1.upto(value).count do |i|
          position = (position + tick) % dial.size

          dial[position].zero?
        end
      end
    end
  end
end

puts Day1::Part1.from_input_file.solve
puts Day1::Part2.from_input_file.solve
