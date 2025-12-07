require "bundler/setup"
require "debug"
require "benchmark"
require "faraday"

class Part
  def self.day
    name.split("::").first.match(/\d+/)[0]
  end

  def self.dir
    Pathname.new(__dir__).join("day_#{day}")
  end

  def self.from_input_file(test = nil)
    filename = test ? "test_input.txt" : "input.txt"

    new dir.join(filename).read
  end

  def self.from_test_input_file = new dir.join("test_input.txt").read

  def self.from_named_input_file(name) = new dir.join(name).read

  def initialize(input)
    @input = input
  end

  def self.download_input
    session = File.read(".aoc_session").strip
    path = "/2025/day/#{day}/input"

    response = Faraday.new({
      url: "https://adventofcode.com",
      headers: { "Cookie" => "session=#{session}" },
    }).get(path)

    raise unless response.status == 200

    File.write("day_#{day}/input.txt", response.body)

    puts "Saved input.txt"
  end
end

class Object
  def tpp(message = nil)
    tap { |l| puts message if message }
    tap { |l| pp l }
    tap { |l| puts "/#{message}" if message }
  end
end

class Puzzle
  def initialize(file:, test:)
    @day = file.match(/day_(\d+)/)[1].to_i
    @test = test
  end

  def dir = Pathname.new(__dir__).join("day_#{@day}")
  def lines = input.split("\n")
  def test? = @test

  def input
    filename = test? ? "test_input.txt" : "input.txt"
    filepath = dir.join(filename)

    unless File.exist?(filepath)
      download_input(filepath) unless test?
    end

    dir.join(filename).read
  end

  private

  def download_input(filepath)
    session = File.read(".aoc_session").strip
    path = "/2025/day/#{@day}/input"

    response = Faraday.new({
      url: "https://adventofcode.com",
      headers: { "Cookie" => "session=#{session}" },
    }).get(path)

    raise unless response.status == 200

    File.write(filepath, response.body)

    puts "Saved input.txt"
  end
end
