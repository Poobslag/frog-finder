#!/bin/sh
################################################################################
# This script generates our export_presets.cfg and project.godot files. It
# updates version numbers and sensitive properties which cannot be kept in
# version control.
#
# Usage:
#   generate-export-presets.sh: Update the export presets with a generated
#     version number.
#   generate-export-presets.sh [VERSION]: Update the export presets with the
#     specified version number.
#
# Further info is available in the Turbo Fat wiki:
# https://github.com/Poobslag/turbofat/wiki/release-process

if [ "$1" ]
then
  version="$1"
else
# Calculate version string
  seconds=$(date +%s)
  version=$((seconds / 2500000 - 658))
  version=$(printf 1.%02d $version)
fi

echo "version=$version"

# Update export presets
cp project/export_presets.cfg.template project/export_presets.cfg
sed -i "s/##VERSION##/$version/g" project/export_presets.cfg
echo "Updated export_presets.cfg"

# Update project.godot
sed -i "s/^config\/version=\".*\"$/config\/version=\"$version\"/g" project/project.godot
echo "Updated project.godot"
