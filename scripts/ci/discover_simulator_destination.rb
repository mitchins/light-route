#!/usr/bin/env ruby

require "json"
require "open3"

CONFIG = {
  "ios" => {
    simulator_platform: "iOS Simulator",
    runtime_fragment: ".iOS-",
    placeholder_names: ["Any iOS Simulator Device"],
    device_name_patterns: [/^iPhone /, /^iPad /],
    created_device_name: "LightRoute CI iOS"
  },
  "tvos" => {
    simulator_platform: "tvOS Simulator",
    runtime_fragment: ".tvOS-",
    placeholder_names: ["Any tvOS Simulator Device"],
    device_name_patterns: [/^Apple TV/],
    created_device_name: "LightRoute CI tvOS"
  },
  "watchos" => {
    simulator_platform: "watchOS Simulator",
    runtime_fragment: ".watchOS-",
    placeholder_names: ["Any watchOS Simulator Device"],
    device_name_patterns: [/^Apple Watch /],
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

    platform = line[/platform:([^,}]+)/, 1]&.strip
    identifier = line[/id:([^,}]+)/, 1]&.strip
    name = line[/name:([^}]+)/, 1]&.strip

    next unless platform == config[:simulator_platform]
    next if identifier.nil? || name.nil?
    next if identifier.include?("Placeholder")
    next if config[:placeholder_names].include?(name)
    next unless config[:device_name_patterns].any? { |pattern| pattern.match?(name) }

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
    device["isAvailable"] && config[:device_name_patterns].any? { |pattern| pattern.match?(device.fetch("name", "")) }
  end
end

def choose_device_type(simctl, config)
  simctl.fetch("devicetypes").find do |device_type|
    config[:device_name_patterns].any? { |pattern| pattern.match?(device_type.fetch("name", "")) }
  end
end

def create_device(device_type_identifier, runtime_identifier, device_name)
  stdout, status = Open3.capture2(
    "xcrun",
    "simctl",
    "create",
    device_name,
    device_type_identifier,
    runtime_identifier
  )

  abort "Failed to create simulator #{device_name.inspect} for #{runtime_identifier}." unless status.success?

  stdout.strip
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

simctl = JSON.parse(`xcrun simctl list -j`)
runtime = choose_runtime(simctl, config)
abort "Failed to discover an available #{config[:simulator_platform]} runtime." if runtime.nil?

existing_device = choose_existing_device(simctl, runtime.fetch("identifier"), config)
if existing_device
  puts "platform=#{config[:simulator_platform]},id=#{existing_device.fetch("udid")}"
  exit 0
end

device_type = choose_device_type(simctl, config)
abort "Failed to discover a device type for #{config[:simulator_platform]}." if device_type.nil?

device_name = "#{config[:created_device_name]} #{runtime.fetch("version", "latest")}".strip
device_identifier = create_device(
  device_type.fetch("identifier"),
  runtime.fetch("identifier"),
  device_name
)

puts "platform=#{config[:simulator_platform]},id=#{device_identifier}"