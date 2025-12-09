require_relative "../setup"

class Part1 < Part
  def initialize(puzzle)
    @points = puzzle.lines.map { |v| Point.new(*v.split(",").map(&:to_i)) }
  end

  def solve
    @points.combination(2).map { |a, b| Rectangle.new(a, b) }.max_by(&:size).size
  end
end

class Part2 < Part
  def solve
  end
end

Point = Data.define :x, :y
Rectangle = Data.define :point1, :point2 do
  def size
    ((point2.x - point1.x).abs + 1) * ((point2.y - point1.y).abs + 1)
  end
end

puzzle = Puzzle.new(file: __FILE__, test: ARGV.include?("test"))

puts(Benchmark.ms { puts Part1.new(puzzle).solve })
# puts(Benchmark.ms { puts Part2.new(puzzle).solve })
