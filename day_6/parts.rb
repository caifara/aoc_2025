require_relative "../setup"

class String
  def blank? = self =~ /^\s*$/
end

module Day6
  Problem = Data.define(:operator, :values) do
    def solve = values.reduce(operator)
  end

  class Part < ::Part
    def solve = problems.sum(&:solve)
  end

  class Part1 < Part
    def problems
      columns.map do |line|
        *values, operator = line

        Problem.new(operator.to_sym, values.map(&:to_i))
      end
    end

    private

    def columns
      @input
        .split("\n")
        .map(&:strip)
        .map { |line| line.split(/\s+/) }
        .transpose
    end
  end

  class Part2 < Part
    OPERATORS = %w[+ *].freeze

    def problems
      char_columns.each_with_object([]) do |line, problems|
        if OPERATORS.include?(line.last)
          *line, operator = line

          problems << Problem.new(operator.to_sym, [line_to_value(line)])
        else
          value = line_to_value(line)

          problems.last.values << value if value
        end
      end
    end

    private

    def char_columns
      @input
        .split("\n")
        .map(&:chars)
        .transpose
    end

    def line_to_value(line)
      line.join.then { |v| v.blank? ? nil : v.to_i }
    end
  end
end

# Day6::Part2.download_input
puts Benchmark.ms { puts Day6::Part1.from_input_file.solve }
puts Benchmark.ms { puts Day6::Part2.from_input_file.solve }
