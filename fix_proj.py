import os
import re

proj_path = "xdrip.xcodeproj/project.pbxproj"
with open(proj_path, "r") as f:
    lines = f.readlines()

# New entries
new_build_files = [
    '\t\t949BCFB42C64E75D00C3E316 /* CADataCollector.swift in Sources */ = {isa = PBXBuildFile; fileRef = 949BCFB32C64E75D00C3E316 /* CADataCollector.swift */; };',
    '\t\t94E56CC52D190B3300BEC953 /* LogsBubbleAccessor.swift in Sources */ = {isa = PBXBuildFile; fileRef = 94E56CC42D190B3300BEC953 /* LogsBubbleAccessor.swift */; };',
    '\t\t94E56CC82D190B3E00BEC953 /* LogsBubble+CoreDataProperties.swift in Sources */ = {isa = PBXBuildFile; fileRef = 94E56CC72D190B3E00BEC953 /* LogsBubble+CoreDataProperties.swift */; };',
    '\t\t94E56CC92D190B3E00BEC953 /* LogsBubble+CoreDataClass.swift in Sources */ = {isa = PBXBuildFile; fileRef = 94E56CC62D190B3E00BEC953 /* LogsBubble+CoreDataClass.swift */; };'
]

new_file_refs = [
    '\t\t949BCFB32C64E75D00C3E316 /* CADataCollector.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = CADataCollector.swift; sourceTree = "<group>"; };',
    '\t\t94E56CC42D190B3300BEC953 /* LogsBubbleAccessor.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = LogsBubbleAccessor.swift; sourceTree = "<group>"; };',
    '\t\t94E56CC62D190B3E00BEC953 /* LogsBubble+CoreDataClass.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "LogsBubble+CoreDataClass.swift"; sourceTree = "<group>"; };',
    '\t\t94E56CC72D190B3E00BEC953 /* LogsBubble+CoreDataProperties.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "LogsBubble+CoreDataProperties.swift"; sourceTree = "<group>"; };'
]

new_source_build_files = [
    '\t\t\t\t949BCFB42C64E75D00C3E316 /* CADataCollector.swift in Sources */,',
    '\t\t\t\t94E56CC52D190B3300BEC953 /* LogsBubbleAccessor.swift in Sources */,',
    '\t\t\t\t94E56CC82D190B3E00BEC953 /* LogsBubble+CoreDataProperties.swift in Sources */,',
    '\t\t\t\t94E56CC92D190B3E00BEC953 /* LogsBubble+CoreDataClass.swift in Sources */,'
]

new_group_children = [
    '\t\t\t\t949BCFB32C64E75D00C3E316 /* CADataCollector.swift */,',
    '\t\t\t\t94E56CC42D190B3300BEC953 /* LogsBubbleAccessor.swift */,',
    '\t\t\t\t94E56CC62D190B3E00BEC953 /* LogsBubble+CoreDataClass.swift */,',
    '\t\t\t\t94E56CC72D190B3E00BEC953 /* LogsBubble+CoreDataProperties.swift */,'
]

# Process lines
output = []
for line in lines:
    output.append(line)
    
    # 1. PBXBuildFile
    if 'F8F9721A23A5915900C3F17D /* CGMBubbleTransmitter.swift in Sources */' in line:
        if '949BCFB42C64E75D00C3E316' not in "".join(lines):
            for bf in new_build_files:
                output.append(bf + "\n")
                
    # 2. PBXFileReference
    if 'F8F971DE23A5915900C3F17D /* CGMBubbleTransmitter.swift */' in line and 'isa = PBXFileReference' in line:
        if '949BCFB32C64E75D00C3E316' not in "".join(lines):
            for fr in new_file_refs:
                output.append(fr + "\n")
                
    # 3. Sources build phase
    if 'F8F9721A23A5915900C3F17D /* CGMBubbleTransmitter.swift in Sources */,' in line:
        if '949BCFB42C64E75D00C3E316 /* CADataCollector.swift in Sources */,' not in "".join(lines):
            for sbf in new_source_build_files:
                output.append(sbf + "\n")
                
    # 4. Group children
    if 'F8F971DE23A5915900C3F17D /* CGMBubbleTransmitter.swift */,' in line:
        if '949BCFB32C64E75D00C3E316 /* CADataCollector.swift */,' not in "".join(lines):
            for gc in new_group_children:
                output.append(gc + "\n")

with open(proj_path, "w") as f:
    f.writelines(output)
print("Project file patched successfully.")