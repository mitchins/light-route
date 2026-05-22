#!/usr/bin/env ruby

require "json"
require "open3"

CONFIG = {
  "ios" => {
    simulator_platform: "iOS Simulator",
    runtime_fragment: ".iOS-",
    placeholder_names: ["Any iOS Simulator Device"],
    reusable_device_name_patterns: [/^iPhone /, /^iPad /, /^LightRoute CI /],
    device_type_name_patterns: [/^iPhone /, /^iPad /],
    created_device_name: "LightRoute CI iOS"
  },
  "tvos" => {
    simulator_platform: "tvOS Simulator",
    runtime_fragment: ".tvOS-",
    placeholder_names: ["Any tvOS Simulator Device"],
    reusable_device_name_patterns: [/^Apple TV/, /^LightRoute CI /],
    device_type_name_patterns: [/^Apple TV/],
    created_device_name: "LightRoute CI tvOS"
  },
  "watchos" => {
    simulator_platform: "watchOS Simulator",
    runtime_fragment: ".watchOS-",
    placeholder_names: ["Any watchOS Simulator Device"],
    reusable_device_name_patterns: [/^Apple Watch /, /^LightRoute CI /],
    device_type_name_patterns: [/^Apple Watch /],
    created_device_name: "LightRoute CI watchOS"
  }
}.freeze

def usage
  abort "usage: ruby scripts/ci/discover_simulator_destination.rb PLATFORM SHOWDESTINATIONS_PATH"
end

def normalized_version(version)
  version.to_s.scan(/\d+/).map(&:to_i)
end

def parse_showdestinations(contents, config)
  contents.each_line do |line|
    next unless line.include?("{ platform:")
    next if line.match?(/(^|,)\s*error:/)

    platform = line[/platform:([^,}]+)/, 1]&.strip
    identifier = line[/id:([^,}]+)/, 1]&.strip
    name = line[/name:([^}]+)/, 1]&.strip

    next unless platform == config[:simulator_platform]
    next if identifier.nil? || name.nil?
    next if identifier.include?("Placeholder")
    next if config[:placeholder_names].include?(name)
    next unless config[:reusable_device_name_patterns].any? { |pattern| pattern.match?(name) }

    return "platform=#{config[:simulator_platform]},id=#{identifier}"
  end

  nil
end

def choose_runtime(simctl, config)
  runtimes = simctl.fetch("runtimes").select do |runtime|
    runtime["isAvailable"] && runtime.fetch("identifier", "").include?(config[:runtime_fragment])
  end

  runtimes.max_by { |runtime| normalized_version(runtime["version"]) }
end

def choose_existing_device(simctl, runtime_identifier, config)
  devices = simctl.fetch("devices", {}).fetch(runtime_identifier, [])

  devices.find do |device|
    device["isAvailable"] && config[:reusable_device_name_patterns].any? { |pattern| pattern.match?(device.fetch("name", "")) }
  end
end

def choose_device_types(simctl, config)
  simctl.fetch("devicetypes").select do |device_type|
    config[:device_type_name_patterns].any? { |pattern| pattern.match?(device_type.fetch("name", "")) }
  end
end

def create_device(device_type_identifier, runtime_identifier, device_name)
  stdout, stderr, status = Open3.capture3(
    "xcrun",
    "simctl",
    "create",
    device_name,
    device_type_identifier,
    runtime_identifier
  )

  unless status.success?
    return [nil, stderr.empty? ? stdout : stderr]
  end

  [stdout.strip, nil]
end

def load_simctl
  stdout, stderr, status = Open3.capture3("xcrun", "simctl", "list", "-j")
  abort "Failed to list simulators: #{stderr.strip}" unless status.success?

  JSON.parse(stdout)
rescue JSON::ParserError => error
  abort "Failed to parse simulator list JSON: #{error.message}"
end

platform = ARGV[0] || usage
showdestinations_path = ARGV[1] || usage
config = CONFIG.fetch(platform) { usage }
showdestinations = File.read(showdestinations_path)

destination = parse_showdestinations(showdestinations, config)
if destination
  puts destination
  exit 0
end

simctl = load_simctl
runtime = choose_runtime(simctl, config)
abort "Failed to discover an available #{config[:simulator_platform]} runtime." if runtime.nil?

existing_device = choose_existing_device(simctl, runtime.fetch("identifier"), config)
if existing_device
  puts "platform=#{config[:simulator_platform]},id=#{existing_device.fetch("udid")}"
  exit 0
end

device_types = choose_device_types(simctl, config)
abort "Failed to discover a device type for #{config[:simulator_platform]}." if device_types.empty?

device_name = "#{config[:created_device_name]} #{runtime.fetch("version", "latest")}".strip
device_identifier = nil
creation_errors = []

device_types.each do |device_type|
  candidate_identifier, error_message = create_device(
    device_type.fetch("identifier"),
    runtime.fetch("identifier"),
    device_name
  )

  if candidate_identifier
    device_identifier = candidate_identifier
    break
  end

  creation_errors << "#{device_type.fetch("name", device_type.fetch("identifier"))}: #{error_message.to_s.strip}"
end

if device_identifier.nil?
  abort <<~MESSAGE
    Failed to create a #{config[:simulator_platform]} simulator for #{runtime.fetch("identifier")}.
    Tried device types:
    #{creation_errors.map { |error| "- #{error}" }.join("\n")}
  MESSAGE
end

puts "platform=#{config[:simulator_platform]},id=#{device_identifier}"