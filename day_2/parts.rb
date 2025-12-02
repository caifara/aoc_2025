require_relative "../setup"

class Part
  def initialize(input)
    @ranges = input
      .strip
      .split(",")
      .map { |v| v.split("-").map(&:to_i) }
  end

  def solve
    invalids = []

    @ranges.each do |start, finish|
      start.upto(finish) do |id|
        invalids << id if repeating?(id)
      end
    end

    invalids.sum
  end
end

module Day2
  class Part1 < Part
    private

    def repeating?(id)
      id_s = id.to_s
      length = id_s.length

      return false if length.odd?

      a, b = id_s.chars.each_slice(length / 2).map(&:join)

      a == b
    end
  end

  class Part2 < Part
    private

    def repeating?(id)
      id_s = id.to_s
      length = id_s.length

      return false if length == 1

      candidate_lengths = [1] + (2..(length / 2)).select { |i| (length % i).zero? }

      candidate_lengths
        .map { |i| id_s.chars.each_slice(i).map(&:join) }
        .detect { |a| a.uniq.size == 1 }
    end
  end
end

puts Day2::Part1.from_input_file.solve
puts Day2::Part2.from_input_file.solve
