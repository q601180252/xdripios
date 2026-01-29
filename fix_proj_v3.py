import os

proj_path = "xdrip.xcodeproj/project.pbxproj"
with open(proj_path, "r") as f:
    lines = f.readlines()

# Correct IDs for current project
logs_accessor_ref = "94E56CC42D190B3300BEC953"
logs_class_ref = "94E56CC62D190B3E00BEC953"
logs_props_ref = "94E56CC72D190B3E00BEC953"
ca_collector_ref = "949BCFB32C64E75D00C3E316"

bubble_group = "F8F971DD23A5915900C3F17D"
accessors_group = "F8B3A814227DEA69004BA588"
classes_group = "F8EA6CA421B9A25B0082976B"

# Build files
logs_accessor_build = "94E56CC52D190B3300BEC953"
logs_class_build = "94E56CC92D190B3E00BEC953"
logs_props_build = "94E56CC82D190B3E00BEC953"
ca_collector_build = "949BCFB42C64E75D00C3E316"

full_content = "".join(lines)

new_output = []
for i in range(len(lines)):
    line = lines[i]
    
    # Remove from Bubble group
    if bubble_group in line:
        # Check if we are inside the children list of Bubble group
        pass # This is harder to do safely without a parser, but I'll skip it if it's there
        
    # Skip if it's already in the wrong group
    if any(ref in line for ref in [logs_accessor_ref, logs_class_ref, logs_props_ref, ca_collector_ref]):
         # If we are in the Bubble group block, skip
         in_bubble = False
         for j in range(i, max(0, i-10), -1):
             if bubble_group in lines[j]:
                 in_bubble = True
                 break
         if in_bubble:
             continue

    new_output.append(line)
    
    # Add to accessors group
    if accessors_group in line and 'isa = PBXGroup' in line:
        # Find 'children = ('
        for k in range(i+1, i+10):
            if 'children = (' in lines[k]:
                if logs_accessor_ref not in full_content:
                    pass # Handled by turn-based insertion or just check if already in output
                # Inject after 'children = ('
                new_output.append(lines[k])
                new_output.append('\t\t\t\t' + logs_accessor_ref + ' /* LogsBubbleAccessor.swift */,\n')
                # skip next line in loop if we just added it
                # actually, this simple script is risky. 
                # Let's use a simpler marker-based approach.

# RESET and use simpler approach
output = []
for line in lines:
    # 1. Add to PBXBuildFile section if missing
    if 'isa = PBXBuildFile' in line and not any(ref in full_content for ref in [logs_accessor_build, logs_class_build, logs_props_build, ca_collector_build]):
         pass # Will add at top of section
         
    # 2. Add to PBXFileReference section if missing
    
    # 3. Add to Sources phase
    
    output.append(line)

# Let's just use string replacement on known markers
c = "".join(lines)

# PBXBuildFile
if logs_accessor_build not in c:
    marker = '/* Begin PBXBuildFile section */\n'
    entry = '\t\t949BCFB42C64E75D00C3E316 /* CADataCollector.swift in Sources */ = {isa = PBXBuildFile; fileRef = 949BCFB32C64E75D00C3E316 /* CADataCollector.swift */; };\n' + \
            '\t\t94E56CC52D190B3300BEC953 /* LogsBubbleAccessor.swift in Sources */ = {isa = PBXBuildFile; fileRef = 94E56CC42D190B3300BEC953 /* LogsBubbleAccessor.swift */; };\n' + \
            '\t\t94E56CC82D190B3E00BEC953 /* LogsBubble+CoreDataProperties.swift in Sources */ = {isa = PBXBuildFile; fileRef = 94E56CC72D190B3E00BEC953 /* LogsBubble+CoreDataProperties.swift */; };\n' + \
            '\t\t94E56CC92D190B3E00BEC953 /* LogsBubble+CoreDataClass.swift in Sources */ = {isa = PBXBuildFile; fileRef = 94E56CC62D190B3E00BEC953 /* LogsBubble+CoreDataClass.swift */; };\n'
    c = c.replace(marker, marker + entry)

# PBXFileReference
if logs_accessor_ref not in c:
    marker = '/* Begin PBXFileReference section */\n'
    entry = '\t\t949BCFB32C64E75D00C3E316 /* CADataCollector.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = CADataCollector.swift; sourceTree = "<group>"; };\n' + \
            '\t\t94E56CC42D190B3300BEC953 /* LogsBubbleAccessor.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LogsBubbleAccessor.swift; sourceTree = "<group>"; };\n' + \
            '\t\t94E56CC62D190B3E00BEC953 /* LogsBubble+CoreDataClass.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "LogsBubble+CoreDataClass.swift"; sourceTree = "<group>"; };\n' + \
            '\t\t94E56CC72D190B3E00BEC953 /* LogsBubble+CoreDataProperties.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "LogsBubble+CoreDataProperties.swift"; sourceTree = "<group>"; };\n'
    c = c.replace(marker, marker + entry)

# Accessors Group
if logs_accessor_ref not in c or accessors_group in c:
    marker = accessors_group + ' /* accessors */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n'
    if marker in c and logs_accessor_ref not in c.split(marker)[1].split(');')[0]:
        c = c.replace(marker, marker + '\t\t\t\t94E56CC42D190B3300BEC953 /* LogsBubbleAccessor.swift */,\n')

# Classes Group
if logs_class_ref not in c or classes_group in c:
    marker = classes_group + ' /* classes */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n'
    if marker in c and logs_class_ref not in c.split(marker)[1].split(');')[0]:
        c = c.replace(marker, marker + '\t\t\t\t94E56CC62D190B3E00BEC953 /* LogsBubble+CoreDataClass.swift */,\n' + \
                                      '\t\t\t\t94E56CC72D190B3E00BEC953 /* LogsBubble+CoreDataProperties.swift */,\n')

# Bubble Group (for CADataCollector)
if ca_collector_ref not in c or bubble_group in c:
    marker = bubble_group + ' /* Bubble */ = {\n\t\t\tisa = PBXGroup;\n\t\t\tchildren = (\n'
    if marker in c and ca_collector_ref not in c.split(marker)[1].split(');')[0]:
        c = c.replace(marker, marker + '\t\t\t\t949BCFB32C64E75D00C3E316 /* CADataCollector.swift */,\n')

# Sources Build Phase (xdrip target)
# ID for xdrip target Sources phase? 
# Marker: F8F9721A23A5915900C3F17D /* CGMBubbleTransmitter.swift in Sources */,
if 'F8F9721A23A5915900C3F17D /* CGMBubbleTransmitter.swift in Sources */,' in c:
    marker = 'F8F9721A23A5915900C3F17D /* CGMBubbleTransmitter.swift in Sources */,'
    if ca_collector_build not in c:
        entry = '\n\t\t\t\t949BCFB42C64E75D00C3E316 /* CADataCollector.swift in Sources */,' + \
                '\n\t\t\t\t94E56CC52D190B3300BEC953 /* LogsBubbleAccessor.swift in Sources */,' + \
                '\n\t\t\t\t94E56CC82D190B3E00BEC953 /* LogsBubble+CoreDataProperties.swift in Sources */,' + \
                '\n\t\t\t\t94E56CC92D190B3E00BEC953 /* LogsBubble+CoreDataClass.swift in Sources */,'
        c = c.replace(marker, marker + entry)

with open(proj_path, "w") as f:
    f.write(c)
print("Project file fixed.")