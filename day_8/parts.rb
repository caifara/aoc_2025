require_relative "../setup"

DistanceEntry = Data.define(:points, :distance)

class Circuits
  def initialize
    @circuits = []
  end

  def add(points)
    circuit1, circuit2 = @circuits.select { |c| c.intersect?(points) }

    if circuit2
      circuit1.merge(circuit2)
      @circuits.delete(circuit2)
    elsif circuit1
      circuit1.merge(points)
    else
      @circuits << points
    end
  end

  def list = @circuits
end

class Point
  attr_reader :x, :y, :z

  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
  end

  def distance(other) # sqrt is overrated
    ((@x - other.x) ** 2) + ((@y - other.y) ** 2) + ((@z - other.z) ** 2)
  end
end

class Part
  def initialize(puzzle)
    @points = puzzle
      .lines
      .map { |l| l.split(",") }
      .map { |x, y, z| Point.new(x.to_i, y.to_i, z.to_i) }
  end

  private

  def distances = @points.combination(2).map { |a, b| DistanceEntry.new(Set[a, b], a.distance(b)) }
end

class Part1 < Part
  def initialize(puzzle)
    super

    @connections_to_make = puzzle.test? ? 10 : 1000
  end

  def solve
    circuits = Circuits.new

    distances.sort_by(&:distance).take(@connections_to_make).each { |de| circuits.add(de.points) }

    circuits.list.map(&:size).sort.reverse.take(3).reduce(:*)
  end
end

class Part2 < Part
  def solve
    points_count = @points.count

    circuits = Circuits.new

    trigger_distance_entry = distances.sort_by(&:distance).find do |de|
      circuits.add(de.points)

      circuits.list.size == 1 && circuits.list.first.size == points_count
    end

    trigger_distance_entry.points.map(&:x).reduce(:*)
  end
end

puzzle = Puzzle.new(file: __FILE__, test: ARGV.include?("test"))

puts(Benchmark.ms { puts Part1.new(puzzle).solve })
puts(Benchmark.ms { puts Part2.new(puzzle).solve })
