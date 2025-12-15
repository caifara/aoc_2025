require_relative "../setup"
require "matrix"

class Part1
  def initialize(puzzle)
    *shapes, regions = puzzle.input.split("\n\n")

    @shapes = shapes.map { |shape| Matrix[*shape.gsub("#", "1").gsub(".", "0").split("\n")[1..].map { it.chars.map(&:to_i) }] }
    @regions_w_contstraints = regions.split("\n").drop(0).map do |line|
      size, shape_qty = line.split(": ")
      width, height = size.split("x").map(&:to_i)
      shape_qties = shape_qty.split.map(&:to_i)

      [width, height, shape_qties]
    end
  end

  def solve
    @regions_w_contstraints.count do |width, height, shape_qties|
      puts "#{width}x#{height} #{shape_qties}"

      region = Matrix.build(height, width) { 0 }

      shapes_to_fit = @shapes.flat_map.with_index do |shape, i|
        counter = Counter.new(shape_qties[i])

        generate_shapes(shape).map { |s| [s, counter] }
      end

      (0..(width - 3)).each do |x|
        (0..(height - 3)).each do |y|
          mask = region.minor(y, 3, x, 3)

          shape, counter = shapes_to_fit
            .select { |s, c| !c.zero? && (s + mask).none?(2) } # shapes available + no overlap
            .max_by { |s, _| score(s + mask) }

          next unless shape

          shape.each_with_index do |v, row_index, col_index|
            next if v.zero?

            region[y + row_index, x + col_index] = v
          end
          counter.decrement
        end
      end

      shapes_to_fit.all? { |_shape, counter| counter.zero? }
    end
  end

  def generate_shapes(shape)
    rotate = ->(shape) { Matrix.rows(shape.to_a.reverse.transpose) }
    mirror = ->(shape) { Matrix.rows(shape.to_a.map(&:reverse)) }

    [
      shape,
      (shape = rotate.call(shape)),
      (shape = rotate.call(shape)),
      (shape = rotate.call(shape)),
      (shape = mirror.call(shape)),
      (shape = rotate.call(shape)),
      (shape = rotate.call(shape)),
      rotate.call(shape),
    ]
  end

  def score(minor)
    minor.map { |v| v.zero? ? -1 : 0 }

    (minor[0, 0] * 10) + (minor[0, 1] * 10) + minor[0, 2] +
    (minor[1, 0] * 10) + (minor[1, 1] * 10) + minor[1, 2] +
    minor[2, 0] + minor[0, 1] + minor[0, 2]
  end
end

class Counter
  def initialize(count)
    @qty = count
  end

  def zero? = @qty.zero?
  def decrement = @qty -= 1
end

def ppr(region)
  region.to_a.each { puts it.join }
end

puzzle = Puzzle.new(file: __FILE__, test: ARGV.include?("test"))

puts(Benchmark.ms { puts Part1.new(puzzle).solve })
