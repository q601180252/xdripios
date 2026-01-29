
import sys

# Define the files to remove
target_files = [
    "ConstantsHomeView.swift",
    "GlucoseChartType.swift",
    "LiveActivityType.swift",
    "AlertUrgencyType.swift",
    "ConstantsUI.swift",
    "ConstantsBGGraphBuilder.swift",
    "FollowerBackgroundKeepAliveType.swift",
    "Bundle.swift",
    "Double.swift",
    "ConstantsCalibrationAlgorithms.swift",
    "ConstantsBloodGlucose.swift",
    "ConstantsGlucoseChartSwiftUI.swift",
    "View.swift",
    "AlertNotificationDictionary.swift",
]

project_path = 'xdrip.xcodeproj/project.pbxproj'

try:
    with open(project_path, 'r') as f:
        lines = f.readlines()

    new_lines = []
    removed_count = 0
    
    for line in lines:
        should_remove = False
        for target_file in target_files:
            # Check for various ways the file might be referenced
            if (f"/* {target_file} */" in line or 
                f"/* {target_file} in Sources */" in line or 
                f"path = {target_file};" in line):
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
