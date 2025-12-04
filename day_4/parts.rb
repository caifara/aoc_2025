require_relative "../setup"

class Part
  def initialize(input)
    @grid = input
      .strip
      .split("\n")
      .map { |l| l.split("").map { |c| c == "@" } }
  end

  def removable_rolls(active_remove: false)
    count = 0

    @grid.each_with_index do |row, y|
      row.each_with_index do |roll, x|
        next unless roll

        small_grid = begin
            min_y = [y - 1, 0].max
            max_y = y + 1
            min_x = [x - 1, 0].max
            max_x = x + 1

            @grid[min_y..max_y].map { |r| r[min_x..max_x] }
          end

        if small_grid.flatten.count(true) < 5
          @grid[y][x] = false if active_remove
          count += 1
        end
      end
    end

    count
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
      total = 0

      loop do
        removed_rolls_count = removable_rolls(active_remove: true)

        break if removed_rolls_count.zero?

        total += removed_rolls_count
      end

      total
    end
  end
end

puts Day4::Part1.from_input_file.solve
puts Day4::Part2.from_input_file.solve
