#!/usr/bin/env ruby
# frozen_string_literal: true

root = File.expand_path("..", __dir__)
bubble_path = File.join(root, "xdrip/BluetoothTransmitter/CGM/Libre/Bubble/CGMBubbleTransmitter.swift")
parser_path = File.join(root, "xdrip/BluetoothTransmitter/CGM/Libre/Utilities/LibreDataParser.swift")

bubble = File.read(bubble_path)
parser = File.read(parser_path)

failures = []

unless bubble.match?(/private static let minimumGlucoseReadIntervalInSeconds\s*=\s*4\.5\s*\*\s*60\.0/)
  failures << "Bubble transmitter should define a 4.5 minute minimum read guard."
end

unless bubble.match?(/if libreSensorType == \.libreProH\s*\{\s*return 0x05\s*\}/m)
  failures << "Libre Pro start commands should always request the 5 minute interval."
end

if bubble.include?("临时注释限流检查")
  failures << "Temporary disabled read throttling block is still present."
end

unless bubble.match?(/Date\(\)\.timeIntervalSince\(last\) < CGMBubbleTransmitter\.minimumGlucoseReadIntervalInSeconds/m)
  failures << "DataInfo handling should skip reads before the minimum interval has elapsed."
end

unless parser.include?("lastLibreProSensorTimeInMinutes")
  failures << "Libre Pro parser should remember the last accepted sensor minute."
end

unless parser.match?(/sensorTimeInMinutes - lastLibreProSensorTimeInMinutes < 5/m)
  failures << "Libre Pro parser should suppress readings less than 5 sensor minutes apart."
end

if failures.empty?
  puts "Libre Pro reading policy checks passed."
else
  warn failures.join("\n")
  exit 1
end
