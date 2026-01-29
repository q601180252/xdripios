ruby <<RUBY
require 'xcodeproj'

main_proj = Xcodeproj::Project.open("$MAIN_PROJECT_FILE")
main_target = main_proj.targets.find { |t| t.name == "$MAIN_TARGET" }
abort("❌ 找不到主工程 Target $MAIN_TARGET") unless main_target

subprojects_list = [
  "BleLibrary|$MAIN_PROJECT_DIR/RSL_Fota/BleLibrary/BleLibrary.xcodeproj",
  "FotaLibrary|$MAIN_PROJECT_DIR/RSL_Fota/FotaLibrary/FotaLibrary.xcodeproj"
]

subprojects_list.each do |entry|
  name, path = entry.split("|")
  puts "🔹 处理子工程 #{name}"
  sub_proj = Xcodeproj::Project.open(path)
  sub_target = sub_proj.targets.first
  abort("❌ 找不到子工程 #{name} target") unless sub_target

  # 添加 Target Dependency
  unless main_target.dependencies.any? { |d| d.target == sub_target }
    main_target.add_dependency(sub_target)
    puts "✅ 添加 Target Dependency: #{name}"
  end

  # Link Binary With Libraries
  framework_file_ref = main_proj.frameworks_group.new_file("RSL_Fota/#{name}/build/Release/#{name}.framework")
  unless main_target.frameworks_build_phases.files_references.any? { |f| f.path == "#{name}.framework" }
    main_target.frameworks_build_phases.add_file_reference(framework_file_ref)
    puts "✅ 添加 Link Binary With Libraries: #{name}.framework"
  end

  # Embed Frameworks
  embed_phase = main_target.copy_files_build_phases.find { |p| p.name == "Embed Frameworks" }
  if embed_phase.nil?
    embed_phase = main_target.new_copy_files_build_phase("Embed Frameworks")
    embed_phase.dst_subfolder_spec = "10" # Frameworks
  end
  unless embed_phase.files_references.any? { |f| f.path == "#{name}.framework" }
    file_ref = main_proj.frameworks_group.new_file("RSL_Fota/#{name}/build/Release/#{name}.framework")
    embed_phase.add_file_reference(file_ref, true)
    puts "✅ 添加 Embed Frameworks: #{name}.framework"
  end
end

main_proj.save
puts "✅ 所有子工程依赖配置完成"
RUBY
