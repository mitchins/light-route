require "cgi"

input_path = ARGV[0]
output_path = ARGV[1]

abort "usage: ruby scripts/ci/lcov_to_sonar_generic.rb INPUT_LCOV OUTPUT_XML" unless input_path && output_path

repo_root = File.expand_path(Dir.pwd)
files = {}
current_file = nil

File.foreach(input_path, chomp: true) do |line|
  case line
  when /\ASF:(.+)\z/
    current_file = Regexp.last_match(1)
    files[current_file] ||= {}
  when /\ADA:(\d+),(\d+)\z/
    next unless current_file

    line_number = Regexp.last_match(1).to_i
    hit_count = Regexp.last_match(2).to_i
    entry = files[current_file][line_number] ||= {
      covered: false,
      branches_to_cover: 0,
      covered_branches: 0
    }
    entry[:covered] ||= hit_count.positive?
  when /\ABRDA:(\d+),[^,]*,[^,]*,(-|\d+)\z/
    next unless current_file

    line_number = Regexp.last_match(1).to_i
    taken = Regexp.last_match(2)
    entry = files[current_file][line_number] ||= {
      covered: false,
      branches_to_cover: 0,
      covered_branches: 0
    }
    entry[:branches_to_cover] += 1
    entry[:covered_branches] += 1 if taken != "-" && taken.to_i.positive?
  when "end_of_record"
    current_file = nil
  end
end

File.open(output_path, "w") do |file|
  file.puts %(<?xml version="1.0" encoding="UTF-8"?>)
  file.puts %(<coverage version="1">)

  files.keys.sort.each do |absolute_path|
    relative_path = if absolute_path.start_with?(repo_root + "/")
      absolute_path.delete_prefix(repo_root + "/")
    else
      absolute_path
    end

    file.puts %(  <file path="#{CGI.escapeHTML(relative_path)}">)

    files[absolute_path].keys.sort.each do |line_number|
      entry = files[absolute_path][line_number]
      attributes = [
        %(lineNumber="#{line_number}"),
        %(covered="#{entry[:covered]}")
      ]

      if entry[:branches_to_cover].positive?
        attributes << %(branchesToCover="#{entry[:branches_to_cover]}")
        attributes << %(coveredBranches="#{entry[:covered_branches]}")
      end

      file.puts %(    <lineToCover #{attributes.join(" ")}/>)
    end

    file.puts %(  </file>)
  end

  file.puts %(</coverage>)
end