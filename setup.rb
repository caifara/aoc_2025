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
