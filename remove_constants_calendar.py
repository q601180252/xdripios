
import sys

# Define the file to remove
target_file = "ConstantsCalendar.swift"
project_path = 'xdrip.xcodeproj/project.pbxproj'

try:
    with open(project_path, 'r') as f:
        lines = f.readlines()

    new_lines = []
    removed_count = 0
    
    # We need to identify the file ID first to be safe, but a broad string match 
    # on the filename within comments /* ... */ usually works well for pbxproj files.
    
    for line in lines:
        # Check for various ways the file might be referenced
        if (f"/* {target_file} */" in line or 
            f"/* {target_file} in Sources */" in line or 
            f"path = {target_file};" in line):
            
            removed_count += 1
            continue
            
        new_lines.append(line)

    with open(project_path, 'w') as f:
        f.writelines(new_lines)

    print(f"Successfully removed {removed_count} lines referencing {target_file}.")

except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
