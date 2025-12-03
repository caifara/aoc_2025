require_relative "../setup"

class Part
  def initialize(input)
    @banks = input
      .strip
      .split("\n")
      .map { |v| v.split("").map(&:to_i) }
  end

  def solve(from_digit_position)
    @banks.sum do |bank|
      solve_bank(bank, from_digit_position)
    end
  end

  def solve_bank(bank, from_digit_position)
    digit = bank[0..-from_digit_position].max

    remaining_bank = bank[(bank.index(digit) + 1)..]
    next_digit_position = from_digit_position - 1

    value = digit * 10 ** (from_digit_position - 1)

    return value if next_digit_position.zero?

    value + solve_bank(remaining_bank, from_digit_position - 1)
  end
end

module Day3
  class Part1 < Part
    def solve = super(2)
  end

  class Part2 < Part
    def solve = super(12)
  end
end

puts Day3::Part1.from_input_file.solve
puts Day3::Part2.from_input_file.solve
