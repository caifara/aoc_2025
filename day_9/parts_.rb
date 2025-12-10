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

    intersection_count = shape.directional_edges(:vertical).count { |e| e.without_endpoints.intersect?(ray) } +
                         shape.directional_edges(:horizontal).count { |e| ray.contains?(e) && shape.edge_is_entry?(e) }

    intersection_count.odd?
  end
end

class Shape
  attr_reader :points

  def initialize(points)
    @points = points
  end

  def edges
    @edges ||= (@points + [@points.first]).each_cons(2).map { |a, b| LineSegment.new(a, b) }
  end

  def directional_edges(direction)
    @directional_edges ||= {}
    @directional_edges[direction] ||= edges.select { |e| e.direction == direction }
  end

  #                                                           |‾
  # edges are entries if they define a staircase like form _|‾
  # if a ray is on that edge, it will enter or exit the shape
  #
  # if the shape is like a tower _|‾|_ the ray moving along the top will just
  # touch the shape (or enter + exit)
  #
  # as only used for horizontal rays, i didn't care about making this work for vertical edges
  def edge_is_entry?(edge)
    raise unless edge.horizontal?
    raise unless edges.include?(edge)

    edge_1 = directional_edges(edge.other_direction).find { |e| e.points.include?(edge.point1) }
    edge_2 = directional_edges(edge.other_direction).find { |e| e.points.include?(edge.point2) }

    edge_1_other_y = (edge_1.points - [edge.point1]).first.y
    edge_2_other_y = (edge_2.points - [edge.point2]).first.y

    ((edge_1_other_y - edge.y) * (edge_2_other_y - edge.y)).negative?
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

  def points = [@point1, @point2]

  def x
    raise unless vertical?

    @point1.x
  end

  def y
    raise unless horizontal?

    @point1.y
  end

  def without_endpoints
    if horizontal?
      x1, x2 = [point1.x, point2.x].sort.then { |x1, x2| [x1 + 1, x2 - 1] }
      LineSegment.new(Point.new(x1, y), Point.new(x2, y))
    else
      y1, y2 = [point1.y, point2.y].sort.then { |y1, y2| [y1 + 1, y2 - 1] }
      LineSegment.new(Point.new(x, y1), Point.new(x, y2))
    end
  end

  def intersect?(other)
    case other
    when Shape
      other.directional_edges(other_direction).any? { |e| e.without_endpoints.intersect?(self) }
    when LineSegment
      raise if direction == other.direction

      return false unless direction == :horizontal ? x_range.cover?(other.x) : y_range.cover?(other.y)

      direction == :horizontal ? other.y_range.cover?(y) : other.x_range.cover?(x)
    else raise
    end
  end

  def direction = point1.x == point2.x ? :vertical : :horizontal
  def other_direction = direction == :vertical ? :horizontal : :vertical
  def vertical? = direction == :vertical
  def horizontal? = direction == :horizontal

  def intersection_point(other)
    return nil unless intersect?(other)

    if direction == :horizontal
      Point.new(other.x, y)
    else
      Point.new(x, other.y)
    end
  end

  def x_range = @x_range ||= Range.new(*[point1.x, point2.x].sort)
  def y_range = @y_range ||= Range.new(*[point1.y, point2.y].sort)

  def contains?(other)
    case other
    when LineSegment
      x_range.cover?(other.x_range) && y_range.cover?(other.y_range)
    when Point
      x_range.cover?(other.x) && y_range.cover?(other.y)
    else raise
    end
  end
end

puzzle = Puzzle.new(file: __FILE__, test: ARGV.include?("test"))

puts(Benchmark.ms { puts Part1.new(puzzle).solve })
puts(Benchmark.ms { pp Part2.new(puzzle).solve })
