require_relative "../setup"
require "benchmark"

class Range
  def merge(other)
    ([other.first, first].min..[other.last, last].max)
  end
end

class Part
  def initialize(input)
    @ranges, @ids = input
      .split("\n\n")
      .then do |ranges, ids|
      [
        ranges.split("\n").map { |r| Range.new(*r.split("-").map(&:to_i)) },
        ids.split("\n").map(&:to_i),
      ]
    end
  end
end

module Day5
  class Part1 < Part
    def solve = @ids.count { |id| @ranges.any? { |r| r.include?(id) } }
  end

  class Part2 < Part
    def solve
      @ranges.sort_by!(&:begin)

      unique_ranges = @ranges.each_with_object([]) do |r, stack|
        if stack.last&.overlap?(r)
          stack[-1] = stack[-1].merge(r)
        else
          stack << r
        end
      end

      unique_ranges.sum(&:size)
    end
  end
end

puts Benchmark.ms { puts Day5::Part1.from_input_file.solve }
puts Benchmark.ms { puts Day5::Part2.from_input_file.solve }
