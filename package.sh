#!/bin/sh
################################################################################
# This script packages the results of Godot's export process into artifacts
# suitable for uploading to GitHub and itch.io.
#
# Most of Godot's export presets produce two or more files, so this script
# combines them into a zip file. Some exports only produce a single file, so
# those are left alone.

# Calculate the version string
version=$(grep "config/version=" project/project.godot | awk -F "\"" '{print $2}')
echo "version=$version"

################################################################################
# Package the windows release

win_export_path="project/export/windows"
win_zip_filename="$win_export_path/frog-finder-win-v$version.zip"

# Delete the existing windows zip file
if [ -f "$win_zip_filename" ]; then
  echo "Deleting $win_zip_filename"
  rm "$win_zip_filename"
fi

# Assemble the windows zip file
echo "Packaging $win_zip_filename"
zip "$win_zip_filename" "$win_export_path/frog-finder-win-v$version.*" -x "*.zip" -j

################################################################################
# Package the linux release

linux_export_path="project/export/linux-x11"
linux_zip_filename="$linux_export_path/frog-finder-linux-v$version.zip"

# Delete the existing linux zip file
if [ -f "$linux_zip_filename" ]; then
  echo "Deleting $linux_zip_filename"
  rm "$linux_zip_filename"
fi

# Assemble the linux zip file
echo "Packaging $linux_zip_filename"
zip "$linux_zip_filename" "$linux_export_path/frog-finder-linux-v$version.*" -x "*.zip" -j

################################################################################
# Package the html5 release

html5_export_path="project/export/html5"
html5_old_index_filename="$html5_export_path/frog-finder.html"
html5_new_index_filename="$html5_export_path/index.html"
html5_zip_filename="$html5_export_path/frog-finder-html5-v$version.zip"

# Rename the 'frog-finder.html' file to 'index.html', as required by itch.io
if [ -f "$html5_old_index_filename" ]; then
  if [ -f "$html5_new_index_filename" ]; then
    echo "Deleting $html5_new_index_filename"
    rm "$html5_new_index_filename"
  fi
  echo "Renaming frog-finder.html to index.html"
  mv "$html5_export_path/frog-finder.html" $html5_new_index_filename
fi

# Delete the existing html5 zip file
if [ -f "$html5_zip_filename" ]; then
  echo "Deleting $html5_zip_filename"
  rm "$html5_zip_filename"
fi

# Assemble the html5 zip file
echo "Packaging $html5_zip_filename"
zip "$html5_zip_filename" "$html5_export_path/*" -x "*.zip" "$html5_export_path/.*" "*.import" -j
