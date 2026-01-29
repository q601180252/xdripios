
import sys

files_to_remove = [
    "ConstantsUI.swift",
    "ConstantsBGGraphBuilder.swift",
    "FollowerBackgroundKeepAliveType.swift",
    "Bundle.swift",
    "ConstantsHomeView.swift",
    "LiveActivityType.swift",
    "Double.swift",
    "GlucoseChartType.swift",
    "ConstantsCalibrationAlgorithms.swift",
    "ConstantsBloodGlucose.swift",
    "ConstantsGlucoseChartSwiftUI.swift",
    "View.swift",
    "AlertUrgencyType.swift",
    "AlertNotificationDictionary.swift"
]

project_path = 'xdrip.xcodeproj/project.pbxproj'

try:
    with open(project_path, 'r') as f:
        lines = f.readlines()

    new_lines = []
    removed_count = 0
    
    for line in lines:
        should_remove = False
        for file_name in files_to_remove:
            # We look for the filename in the line. 
            # PBXFileReference lines look like: 54A... /* ConstantsUI.swift */ = {isa = PBXFileReference; ... path = ConstantsUI.swift; ... };
            # PBXBuildFile lines look like: 54B... /* ConstantsUI.swift in Sources */ = {isa = PBXBuildFile; fileRef = 54A... /* ConstantsUI.swift */; };
            # We want to remove both.
            if f"/* {file_name} */" in line or f"/* {file_name} in Sources */" in line or f"path = {file_name};" in line:
                should_remove = True
                break
        
        if not should_remove:
            new_lines.append(line)
        else:
            removed_count += 1

    with open(project_path, 'w') as f:
        f.writelines(new_lines)

    print(f"Successfully removed {removed_count} lines referencing missing files.")

except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
