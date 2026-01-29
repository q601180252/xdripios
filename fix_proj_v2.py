import os

proj_path = "xdrip.xcodeproj/project.pbxproj"
with open(proj_path, "r") as f:
    lines = f.readlines()

# IDs
logs_accessor_ref = "94E56CC42D190B3300BEC953"
logs_class_ref = "94E56CC62D190B3E00BEC953"
logs_props_ref = "94E56CC72D190B3E00BEC953"
bubble_group = "F8F971DD23A5915900C3F17D"
accessors_group = "F8EA6CA321B9A2320082976B"
classes_group = "F8EA6CA421B9A25B0082976B"

# 1. Update paths in FileReferences
# LogsBubbleAccessor.swift -> path = "Core Data/accessors/LogsBubbleAccessor.swift"
# But it is inside xdrip/ folder.
# Actually, since groups have paths, the file reference path should be just the filename.

# 2. Fix group memberships
output = []
for line in lines:
    # Remove from Bubble group
    if bubble_group in line or '/* Bubble */' in line:
        pass # Handle later
    
    # Add to accessors group
    if accessors_group in line or '/* accessors */' in line:
        pass # Handle later
    
    output.append(line)

# Correct logic: find the children block of each group and modify
new_output = []
skip_mode = None
for i in range(len(lines)):
    line = lines[i]
    
    # Identify group blocks
    if '94E56CC42D190B3300BEC953 /* LogsBubbleAccessor.swift */,' in line:
        # Check if we are in the WRONG group (Bubble)
        # Find backwards for group start
        found_bubble = False
        for j in range(i, i-20, -1):
            if 'F8F971DD23A5915900C3F17D /* Bubble */ = {' in lines[j]:
                found_bubble = True
                break
        if found_bubble:
            continue # skip adding it here
            
    if '94E56CC62D190B3E00BEC953 /* LogsBubble+CoreDataClass.swift */,' in line or \
       '94E56CC72D190B3E00BEC953 /* LogsBubble+CoreDataProperties.swift */,' in line:
        found_bubble = False
        for j in range(i, i-20, -1):
            if 'F8F971DD23A5915900C3F17D /* Bubble */ = {' in lines[j]:
                found_bubble = True
                break
        if found_bubble:
            continue

    new_output.append(line)
    
    # Add to correct groups
    if 'F8EA6CA321B9A2320082976B /* accessors */ = {' in line:
        # find children start
        j = i + 1
        while 'children = (' not in lines[j]: j += 1
        # skip to next turn or inject immediately if we are at line j
    
    if 'children = (' in line:
        # Check if parent is accessors
        if i > 0 and 'F8EA6CA321B9A2320082976B /* accessors */' in lines[i-1]:
             new_output.append('\t\t\t\t94E56CC42D190B3300BEC953 /* LogsBubbleAccessor.swift */,\n')
        
        # Check if parent is classes
        if i > 0 and 'F8EA6CA421B9A25B0082976B /* classes */' in lines[i-1]:
             new_output.append('\t\t\t\t94E56CC62D190B3E00BEC953 /* LogsBubble+CoreDataClass.swift */,\n')
             new_output.append('\t\t\t\t94E56CC72D190B3E00BEC953 /* LogsBubble+CoreDataProperties.swift */,\n')

with open(proj_path, "w") as f:
    f.writelines(new_output)
print("Project file corrected.")