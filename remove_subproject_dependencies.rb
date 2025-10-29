#!/usr/bin/env ruby

require 'xcodeproj'

def remove_subproject_dependencies(project_path)
  puts "🔧 Removing subproject dependencies from #{project_path}"
  
  project = Xcodeproj::Project.open(project_path)
  
  # Find main target
  main_target = project.targets.find { |t| t.name == "xdrip" }
  unless main_target
    puts "❌ Main target 'xdrip' not found"
    return false
  end
  
  puts "📱 Found main target: #{main_target.name}"
  
  # Remove subproject dependencies
  dependencies_to_remove = []
  main_target.dependencies.each do |dep|
    if dep.target && (dep.target.name.include?("BleLibrary") || dep.target.name.include?("FotaLibrary"))
      dependencies_to_remove << dep
      puts "🗑️  Removing dependency: #{dep.target.name}"
    end
  end
  
  dependencies_to_remove.each { |dep| main_target.dependencies.delete(dep) }
  
  # Remove subproject references (this might be handled differently in different xcodeproj versions)
  # For now, we'll focus on removing the proxy references and dependencies
  
  # Remove PBXReferenceProxy framework references
  proxy_refs_to_remove = []
  project.frameworks_group.children.each do |child|
    if child.is_a?(Xcodeproj::Project::Object::PBXReferenceProxy) &&
       (child.path.include?("BleLibrary") || child.path.include?("FotaLibrary"))
      proxy_refs_to_remove << child
      puts "🗑️  Removing PBXReferenceProxy: #{child.path}"
    end
  end
  
  proxy_refs_to_remove.each { |ref| project.frameworks_group.children.delete(ref) }
  
  # Remove Products groups for subprojects
  products_groups_to_remove = []
  project.main_group.children.each do |group|
    if group.is_a?(Xcodeproj::Project::Object::PBXGroup) && group.name == "Products"
      group.children.each do |child|
        if child.path && (child.path.include?("BleLibrary") || child.path.include?("FotaLibrary"))
          products_groups_to_remove << child
          puts "🗑️  Removing product reference: #{child.path}"
        end
      end
      products_groups_to_remove.each { |child| group.children.delete(child) }
    end
  end
  
  puts "✅ Subproject dependencies removed"
  
  # Create framework references if they don't exist
  frameworks_group = project.frameworks_group
  
  # Check if BleLibrary.framework reference exists
  ble_ref = frameworks_group.children.find { |child| child.path == "Frameworks/BleLibrary.framework" }
  unless ble_ref
    puts "➕ Creating BleLibrary.framework reference"
    ble_ref = frameworks_group.new_file("Frameworks/BleLibrary.framework")
    ble_ref.source_tree = "<group>"
  end
  
  # Check if FotaLibrary.framework reference exists  
  fota_ref = frameworks_group.children.find { |child| child.path == "Frameworks/FotaLibrary.framework" }
  unless fota_ref
    puts "➕ Creating FotaLibrary.framework reference"
    fota_ref = frameworks_group.new_file("Frameworks/FotaLibrary.framework")
    fota_ref.source_tree = "<group>"
  end
  
  # Fix build phase references
  puts "🔧 Fixing build phase references..."
  
  # Update Frameworks build phase
  main_target.frameworks_build_phases.files.each do |build_file|
    if build_file.file_ref && (build_file.file_ref.path.include?("BleLibrary") || build_file.file_ref.path.include?("FotaLibrary"))
      if build_file.file_ref.path.include?("BleLibrary")
        build_file.file_ref = ble_ref
        puts "  - Updated Frameworks build phase for BleLibrary.framework"
      elsif build_file.file_ref.path.include?("FotaLibrary")
        build_file.file_ref = fota_ref
        puts "  - Updated Frameworks build phase for FotaLibrary.framework"
      end
    end
  end
  
  # Update Embed Frameworks build phase
  embed_phase = main_target.copy_files_build_phases.find { |p| p.name == "Embed Frameworks" }
  if embed_phase
    embed_phase.files.each do |build_file|
      if build_file.file_ref && (build_file.file_ref.path.include?("BleLibrary") || build_file.file_ref.path.include?("FotaLibrary"))
        if build_file.file_ref.path.include?("BleLibrary")
          build_file.file_ref = ble_ref
          puts "  - Updated Embed Frameworks build phase for BleLibrary.framework"
        elsif build_file.file_ref.path.include?("FotaLibrary")
          build_file.file_ref = fota_ref
          puts "  - Updated Embed Frameworks build phase for FotaLibrary.framework"
        end
      end
    end
  end
  
  # Save project
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

success = remove_subproject_dependencies(project_path)
exit success ? 0 : 1