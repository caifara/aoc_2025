require_relative "../setup"
require "benchmark"

class Part
  def initialize(input)
    @grid = input
      .strip
      .split("\n")
      .map { |l| l.split("").map { |c| c == "@" } }
  end

  def removable_rolls(remove_when_found: false)
    @grid.each_with_index.sum do |row, y|
      row.each_with_index.count do |roll, x|
        next unless roll

        next if count_adjacent_rolls(x, y) > 3

        @grid[y][x] = false if remove_when_found

        true
      end
    end
  end

  private

  def count_adjacent_rolls(x, y)
    min_y = [y - 1, 0].max
    max_y = y + 1
    min_x = [x - 1, 0].max
    max_x = x + 1

    @grid[min_y..max_y].flat_map { |r| r[min_x..max_x] }.count(true) - 1
  end
end

module Day4
  class Part1 < Part
    def solve
      removable_rolls
    end
  end

  class Part2 < Part
    def solve
      Enumerator
        .produce { removable_rolls(remove_when_found: true) }
        .take_while(&:positive?)
        .sum
    end
  end
end

puts Day4::Part1.from_input_file.solve
puts Benchmark.measure { puts Day4::Part2.from_input_file.solve }.real
