require_relative "../setup"

class Part1
  def initialize(puzzle)
    @puzzle = puzzle.lines
  end

  def solve
    beam_frame = Set[@puzzle.shift.index("S")]
    beam_frames = [beam_frame]

    @puzzle.sum do |line|
      beam_frame, split_count = calc_beam_frame(line, beam_frame)
      beam_frames << beam_frame

      split_count
    end
  end

  private

  def calc_beam_frame(puzzle_line, beam_frame)
    split_count = 0
    new_beam_frame = Set[]

    beam_frame.each do |index|
      if puzzle_line[index] == "^"
        split_count += 1
        new_beam_frame << (index + 1)
        new_beam_frame << (index - 1)
      else
        new_beam_frame << index
      end
    end

    [new_beam_frame, split_count]
  end
end

class Part2 < Part
end

puzzle = Puzzle.new(file: __FILE__, test: ARGV.include?("test"))

puts(Benchmark.ms { puts Part1.new(puzzle).solve })
