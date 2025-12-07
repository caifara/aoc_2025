require_relative "../setup"
require "colorize"

class Part1
  def initialize(puzzle)
    @puzzle = puzzle.lines
    @vis = P1Visualizer.new(@puzzle)
  end

  def solve
    beam_frame = Set[@puzzle.shift.index("S")]
    beam_frames = [beam_frame]

    @puzzle.sum do |line|
      beam_frame, split_count = calc_beam_frame(line, beam_frame)
      beam_frames << beam_frame

      # @vis.render(beam_frames, split_count, line)

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

class Part2
  def initialize(puzzle)
    @puzzle = puzzle.lines
  end

  def solve
    beam_frame = { @puzzle.shift.index("S") => 1 }

    @puzzle.each do |line|
      beam_frame = calc_beam_frame(line, beam_frame)
    end

    beam_frame.values.sum
  end

  private

  def calc_beam_frame(puzzle_line, beam_frame)
    new_beam_frame = Hash.new { |h, k| h[k] = 0 }

    beam_frame.each do |index, beam_count|
      if puzzle_line[index] == "^"
        new_beam_frame[index + 1] += beam_count
        new_beam_frame[index - 1] += beam_count
      else
        new_beam_frame[index] += beam_count
      end
    end

    new_beam_frame
  end
end

class P1Visualizer
  def initialize(puzzle)
    @puzzle = puzzle
  end

  def render(beam_frames, split_count, current_line)
    @split_counts ||= []
    @split_counts << split_count unless split_count.zero?

    print "\e[2J\e[H"
    puts
    puts
    puts
    puts
    @puzzle.each_with_index do |line, line_index|
      print "      "
      beam_frame = beam_frames[line_index + 1]

      line.chars.each_with_index do |char, char_index|
        char = case char
          when "S" then "S".green
          when "^" then "^".red
          when "." then " "
          end

        print beam_frame&.include?(char_index) ? "|".yellow : char
      end
      puts
    end
    puts
    puts @split_counts.join(" + ")
    puts "som: #{@split_counts.sum}"
    puts
    sleep 0.3
  end
end

puzzle = Puzzle.new(file: __FILE__, test: ARGV.include?("test"))

puts(Benchmark.ms { puts Part1.new(puzzle).solve })
puts(Benchmark.ms { puts Part2.new(puzzle).solve })
