require_relative "../setup"

class Part1 < Part
  def initialize(puzzle)
    @points = puzzle.lines.map { |v| Point.new(*v.split(",").map(&:to_i)) }
  end

  def solve
    @points.combination(2).map { |a, b| Rectangle.new(a, b) }.map(&:size).max
  end
end

class Part2 < Part
  def initialize(puzzle)
    @red_tile_shape = Shape.new(puzzle.lines.map { Point.new(*it.split(",").map(&:to_i)) })
  end

  def solve
    $red_tile_shape = @red_tile_shape
    @red_tile_shape
      .points
      .combination(2)
      .map { |a, b| Rectangle.new(a, b) }
      .select { |r| r.inside?(@red_tile_shape) }
      .max_by(&:size)
      .td
  end
end

class Point
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  # def line_segment_up
  #   @line_segment_up ||= LineSegment.new(self, Point.new(x, 0))
  # end
  #
  # def line_segment_down
  #   @line_segment_down ||= LineSegment.new(self, Point.new(x, Float::INFINITY))
  # end
  #
  # def line_segment_right
  #   @line_segment_right ||= LineSegment.new(self, Point.new(Float::INFINITY, y))
  # end
  #
  # def line_segment_left
  #   @line_segment_left ||= LineSegment.new(self, Point.new(0, y))
  # end
end

class Shape
  attr_reader :points

  def initialize(points)
    @points = points
    @internal_lines = {
      horizontal: {},
      vertical: {}
    }
  end

  def edges
    @edges ||= @points.combination(2).map { |a, b| LineSegment.new(a, b) }
  end

  def vertical_edges
    @vertical_edges ||= edges.select { |e| e.point1.x == e.point2.x }
  end

  def horizontal_edges
    @horizontal_edges ||= edges.select { |e| e.point1.y == e.point2.y }
  end

  def includes_line?(line)
    internal_lines(line.direction)
  end

  def internal_lines(line.direction)
    if line.horizontal?
      vertical_edges.collect { |e| e.intersection_point }
    else
      horizontal_edges.collect { |e| e.intersection_point }
    end
  end
end

class Rectangle < Shape
  def initialize(point1, point2)
    super([point1, point2, Point.new(point2.x, point1.y), Point.new(point1.x, point2.y)])
  end

  def size
    point1, point2 = points

    ((point2.x - point1.x).abs + 1) * ((point2.y - point1.y).abs + 1)
  end

  def inside?(shape)
    # return false unless points.all? do |p|
    #   shape.points.include?(p) ||
    #     (shape.horizontal_edges.any? { |se| se.intersect?(p.line_segment_left) } ||
    #      shape.horizontal_edges.any? { |se| se.intersect?(p.line_segment_right) }) ||
    #     (shape.vertical_edges.any? { |se| se.intersect?(p.line_segment_up) } ||
    #      shape.vertical_edges.any? { |se| se.intersect?(p.line_segment_down) })
    # end
    #
    # return false if vertical_edges.any? do |e|
    #   shape.horizontal_edges.any? { |se| se.intersect?(e) }
    # end
    #
    # horizontal_edges.none? do |e|
    #   shape.vertical_edges.any? { |se| se.intersect?(e) }
    # end
    edges.all? { |edge| shape.includes_line?(edge) }
  end
end

class LineSegment
  attr_reader :point1, :point2

  def initialize(point1, point2)
    @point1 = point1
    @point2 = point2
  end

  def intersect?(other)
    (point1.x..point2.x).cover?(other.point1.x) && (point1.y..point2.y).cover?(other.point1.y)
  end
end

puzzle = Puzzle.new(file: __FILE__, test: ARGV.include?("test"))

puts(Benchmark.ms { puts Part1.new(puzzle).solve })
puts(Benchmark.ms { puts Part2.new(puzzle).solve })
