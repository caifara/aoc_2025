require_relative "../setup"

class Part1
  def initialize(puzzle)
    @devices_w_connections = puzzle
      .lines
      .map { |l| l.split(": ") }
      .to_h { |input, raw_outputs| [input.to_sym, raw_outputs.split(" ").map(&:to_sym)] }
  end

  def solve
    paths_from(:you).count
  end

  private

  def paths_from(device)
    @devices_w_connections[device].flat_map do |output|
      if output == :out
        [output]
      else
        paths_from(output)
      end
    end
  end
end

class Part2
  def initialize(puzzle)
    @puzzle = puzzle.lines
  end

  def solve
  end
end

puzzle = Puzzle.new(file: __FILE__, test: ARGV.include?("test"))

puts(Benchmark.ms { puts Part1.new(puzzle).solve })
puts(Benchmark.ms { puts Part2.new(puzzle).solve })
