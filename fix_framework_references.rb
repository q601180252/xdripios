#!/usr/bin/env ruby

require 'xcodeproj'

# Script to fix framework references in Xcode project
# This converts PBXReferenceProxy references to relative file references

def fix_framework_references(project_path)
  puts "🔧 Fixing framework references in #{project_path}"
  
  # Open the project
  project = Xcodeproj::Project.open(project_path)
  
  # Find the main target
  main_target = project.targets.find { |t| t.name == "xdrip" }
  unless main_target
    puts "❌ Main target 'xdrip' not found"
    return false
  end
  
  puts "📱 Found main target: #{main_target.name}"
  
  # Find framework references that need to be fixed
  ble_library_ref = nil
  fota_library_ref = nil
  
  project.frameworks_group.children.each do |child|
    if child.path == "BleLibrary.framework"
      ble_library_ref = child
      puts "🔍 Found BleLibrary.framework reference: #{child.class}"
    elsif child.path == "FotaLibrary.framework"
      fota_library_ref = child
      puts "🔍 Found FotaLibrary.framework reference: #{child.class}"
    end
  end
  
  # Remove existing proxy references and create new file references
  if ble_library_ref && ble_library_ref.is_a?(Xcodeproj::Project::Object::PBXReferenceProxy)
    puts "🔄 Replacing BleLibrary.framework PBXReferenceProxy with file reference"
    
    # Remove the proxy reference
    project.frameworks_group.children.delete(ble_library_ref)
    
    # Create new file reference
    new_ble_ref = project.frameworks_group.new_file("Frameworks/BleLibrary.framework")
    new_ble_ref.source_tree = "<group>"
    
    puts "✅ Created new BleLibrary.framework file reference"
  end
  
  if fota_library_ref && fota_library_ref.is_a?(Xcodeproj::Project::Object::PBXReferenceProxy)
    puts "🔄 Replacing FotaLibrary.framework PBXReferenceProxy with file reference"
    
    # Remove the proxy reference
    project.frameworks_group.children.delete(fota_library_ref)
    
    # Create new file reference
    new_fota_ref = project.frameworks_group.new_file("Frameworks/FotaLibrary.framework")
    new_fota_ref.source_tree = "<group>"
    
    puts "✅ Created new FotaLibrary.framework file reference"
  end
  
  # Fix build phase references
  puts "🔧 Fixing build phase references..."
  
  main_target.frameworks_build_phases.files.each do |build_file|
    if build_file.file_ref && build_file.file_ref.path == "BleLibrary.framework"
      puts "  - Fixed Frameworks build phase for BleLibrary.framework"
    elsif build_file.file_ref && build_file.file_ref.path == "FotaLibrary.framework"
      puts "  - Fixed Frameworks build phase for FotaLibrary.framework"
    end
  end
  
  # Fix embed frameworks phase
  embed_phase = main_target.copy_files_build_phases.find { |p| p.name == "Embed Frameworks" }
  if embed_phase
    embed_phase.files.each do |build_file|
      if build_file.file_ref && build_file.file_ref.path == "BleLibrary.framework"
        puts "  - Fixed Embed Frameworks build phase for BleLibrary.framework"
      elsif build_file.file_ref && build_file.file_ref.path == "FotaLibrary.framework"
        puts "  - Fixed Embed Frameworks build phase for FotaLibrary.framework"
      end
    end
  end
  
  # Save the project
  project.save
  puts "✅ Project saved successfully"
  
  true
end

# Main execution
if ARGV.length != 1
  puts "Usage: #{$0} <project_path>"
  puts "Example: #{$0} xdrip.xcodeproj"
  exit 1
end

project_path = ARGV[0]
unless File.exist?(project_path)
  puts "❌ Project file not found: #{project_path}"
  exit 1
end

success = fix_framework_references(project_path)
exit success ? 0 : 1