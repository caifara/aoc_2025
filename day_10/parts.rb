require_relative "../setup"
require "or-tools"

class Part1
  def initialize(puzzle)
    @manuals = puzzle
      .lines
      .map { |l| l.split(" ") }
      .map { |raw_pattern, *raw_buttons, joltage| [(p = pattern(raw_pattern)), raw_buttons.map { button(it, p) }, joltage] }
  end

  def solve
    @manuals.sum do |pattern, buttons, joltage|
      (1..).find do |i|
        buttons.repeated_combination(i).any? do |pressed_buttons|
          press_pattern = [0] * pattern.size

          pressed_buttons.each do |b|
            press_pattern = press(b, press_pattern)
          end

          press_pattern == pattern
        end
      end
    end
  end

  def pattern(raw_pattern)
    raw_pattern.chars.map do |c|
      case c
      when "." then 0
      when "#" then 1
      end
    end.compact
  end

  def button(raw_button, pattern)
    button = [0] * pattern.size

    raw_button.scan(/\d+/).map(&:to_i).each do |i|
      button[i] = 1
    end

    button
  end

  def press(button, pattern)
    pattern.zip(button).map { |a, b| a ^ b }
  end
end

class Part2
  def initialize(puzzle)
    @manuals = puzzle
      .lines
      .map { |l| l.split(" ") }
      .map { |raw_pattern, *raw_buttons, raw_joltage| [(p = pattern(raw_pattern)), raw_buttons.map { button(it, p) }, joltage(raw_joltage)] }
  end

  def solve
    @manuals.sum do |_pattern, buttons, joltage|
      solver = ORTools::Solver.new("IntegerProgramming", :cbc)

      infinity = solver.infinity
      buttons_with_var = buttons.to_h { |b| [b, solver.int_var(0, infinity, "b#{b.join("_")}")] }

      joltage.each_with_index do |j, i|
        j_buttons_with_var = buttons_with_var.select { |b, _| b.include?(i) }
        j_button_vars = j_buttons_with_var.values

        solver.add(j_button_vars.sum == j)
      end

      solver.minimize(buttons_with_var.values.sum)

      status = solver.solve
      raise unless status == :optimal

      solver.objective.value.to_i
    end
  end

  def pattern(raw_pattern)
    raw_pattern.chars.map do |c|
      case c
      when "." then 0
      when "#" then 1
      end
    end.compact
  end

  def joltage(raw_joltage)
    raw_joltage.scan(/\d+/).map(&:to_i)
  end

  def button(raw_button, pattern)
    raw_button.scan(/\d+/).map(&:to_i)
  end
end

puzzle = Puzzle.new(file: __FILE__, test: ARGV.include?("test"))

puts(Benchmark.ms { pp Part1.new(puzzle).solve })
puts(Benchmark.ms { pp Part2.new(puzzle).solve })
