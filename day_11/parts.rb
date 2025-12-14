require_relative "../setup"

class Part1
  def initialize(puzzle)
    @devices_w_connections = puzzle
      .lines
      .map { |l| l.split(": ") }
      .to_h { |input, raw_outputs| [input.to_sym, raw_outputs.split.map(&:to_sym)] }
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
        paths_from(output).map { |p| [output, *p] }
      end
    end
  end
end

class Part2
  def initialize(puzzle)
    @devices_w_connections = puzzle
      .lines
      .map { |l| l.split(": ") }
      .to_h { |input, raw_outputs| [input.to_sym, raw_outputs.split.map(&:to_sym)] }
    @paths_from_cache = {}
  end

  def solve
    paths_from(:svr, to_device: :out).dac_and_fft_path_count
  end

  private

  def paths_from(device, to_device:, depth: 0)
    return @paths_from_cache[device] if @paths_from_cache.key?(device)

    path_result = PathResult.new(device)

    return path_result.tap(&:register_other) if device == :out

    @devices_w_connections[device].map do |output|
      path_result << paths_from(output, to_device:, depth: depth + 1)
    end

    @paths_from_cache[device] = path_result

    path_result
  end

  class PathResult
    attr_reader :dac_and_fft_path_count, :dac_path_count, :fft_path_count, :other_path_count

    def self.[](*)
      new(*)
    end

    def initialize(device)
      @device = device

      @dac_and_fft_path_count = 0
      @dac_path_count = 0
      @fft_path_count = 0
      @other_path_count = 0
    end

    def dac? = @device == :dac
    def fft? = @device == :fft

    def register_other
      @other_path_count += 1
    end

    def <<(other)
      @dac_and_fft_path_count += other.dac_and_fft_path_count

      if dac? && fft?
        @dac_and_fft_path_count += other.fft_path_count
        @dac_and_fft_path_count += other.dac_path_count
        @dac_and_fft_path_count += other.other_path_count
      elsif dac?
        @dac_and_fft_path_count += other.fft_path_count

        @dac_path_count += other.dac_path_count
        @dac_path_count += other.other_path_count

        @fft_path_count += other.fft_path_count
      elsif fft?
        @dac_and_fft_path_count += other.dac_path_count

        @fft_path_count += other.fft_path_count
        @fft_path_count += other.other_path_count

        @dac_path_count += other.dac_path_count
      else
        @dac_path_count += other.dac_path_count
        @fft_path_count += other.fft_path_count
        @other_path_count += other.other_path_count
      end
    end
  end
end

puzzle = Puzzle.new(file: __FILE__, test: ARGV.include?("test"))

puts(Benchmark.ms { puts Part1.new(puzzle).solve }) # warmup
puts(Benchmark.ms { puts Part1.new(puzzle).solve })
puts(Benchmark.ms { puts Part2.new(puzzle).solve })
