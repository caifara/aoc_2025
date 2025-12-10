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
    @red_tile_shape
      .points
      .combination(2)
      .map { |a, b| Rectangle.new(a, b) }
      .sort_by(&:size)
      .reverse
      .find { |r| r.inside?(@red_tile_shape) }
      .tap { |r| pp r }
      .size
  end
end

class Point
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def ==(other)
    @x == other.x && @y == other.y
  end

  def inside?(shape)
    return true if shape.edges.any? { |e| e.contains?(self) }

    second_point = Point.new(Float::INFINITY, @y)

    ray = LineSegment.new(self, second_point)

    intersection_count = shape.directional_edges(:vertical).count { |e| e.intersect?(ray) }

    intersection_count.odd?
  end
end

class Shape
  attr_reader :points

  def initialize(points)
    @points = points
    @line_segments = {}
  end

  def edges
    @edges ||= (@points + [@points.first]).each_cons(2).map { |a, b| LineSegment.new(a, b) }
  end

  def directional_edges(direction)
    @directional_edges ||= {}
    @directional_edges[direction] ||= edges.select { |e| e.direction == direction }
  end

  def includes_line_segment?(line_segment)
    line_segments(line_segment.straight).any? { |s| s.contains?(line_segment) }
  end

  def line_segments(straight)
    @line_segments[straight] || begin
      @line_segments[straight] = []

      directional_edges(straight.other_direction)
        .collect { |e| e.intersection_point(straight) }
        .compact
        .combination(2)
        .each_with_index { |(a, b), i| (i % 2).zero? && @line_segments[straight].push(LineSegment.new(a, b)) }

      @line_segments[straight]
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
    @points.all? { |p| p.inside?(shape) } && edges.none? { |e| e.without_endpoints.intersect?(shape) }
  end
end

class LineSegment
  attr_reader :point1, :point2

  def initialize(point1, point2)
    @point1 = point1
    @point2 = point2
  end

  def x
    raise unless vertical?

    @point1.x
  end

  def y
    raise unless horizontal?

    @point1.y
  end

  def x_or_y = vertical? ? x : y

  def without_endpoints
    if horizontal?
      x1, x2 = [point1.x, point2.x].sort.then { |x1, x2| [x1 + 1, x2 - 1] }
      LineSegment.new(Point.new(x1, y), Point.new(x2, y))
    else
      y1, y2 = [point1.y, point2.y].sort.then { |y1, y2| [y1 + 1, y2 - 1] }
      LineSegment.new(Point.new(x, y1), Point.new(x, y2))
    end
  end

  # straight, linesegment or shape
  def intersect?(other)
    return other.directional_edges(other_direction).any? { |e| e.intersect?(self) } if other.is_a?(Shape)

    raise if direction == other.direction

    return false unless direction == :horizontal ? full_x_range.cover?(other.x) : full_y_range.cover?(other.y)
    return true if other.is_a?(Straight)

    direction == :horizontal ? other.full_y_range.cover?(y) : other.full_x_range.cover?(x)
  end

  def direction = point1.x == point2.x ? :vertical : :horizontal
  def other_direction = direction == :vertical ? :horizontal : :vertical
  def vertical? = direction == :vertical
  def horizontal? = direction == :horizontal

  def intersection_point(other_or_straight)
    return nil unless intersect?(other_or_straight)

    if direction == :horizontal
      Point.new(other_or_straight.x, y)
    else
      Point.new(x, other_or_straight.y)
    end
  end

  def straight
    @straight ||= Straight.new(direction:, x_or_y:)
  end

  def x_range = @x_range ||= Range.new(*[point1.x, point2.x].sort.then { |x1, x2| [x1 + 1, x2 - 1] })
  def y_range = @y_range ||= Range.new(*[point1.y, point2.y].sort.then { |y1, y2| [y1 + 1, y2 - 1] })
  def full_x_range = @full_x_range ||= Range.new(*[point1.x, point2.x].sort)
  def full_y_range = @full_y_range ||= Range.new(*[point1.y, point2.y].sort)

  def contains?(other)
    case other
    when LineSegment
      full_x_range.cover?(other.full_x_range) && full_y_range.cover?(other.full_y_range)
    when Point
      full_x_range.cover?(other.x) && full_y_range.cover?(other.y)
    else raise
    end
  end
end

class Straight
  attr_reader :direction, :x_or_y

  def initialize(direction:, x_or_y:)
    @direction = direction
    @x_or_y = x_or_y
  end

  def ===(other)
    direction == other.direction && x_or_y == other.x_or_y
  end

  def x
    raise unless direction == :vertical

    x_or_y
  end

  def y
    raise unless direction == :horizontal

    x_or_y
  end

  def other_direction = direction == :vertical ? :horizontal : :vertical
end

puzzle = Puzzle.new(file: __FILE__, test: ARGV.include?("test"))

puts(Benchmark.ms { puts Part1.new(puzzle).solve })
puts(Benchmark.ms { pp Part2.new(puzzle).solve })
