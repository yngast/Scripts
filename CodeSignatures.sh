#!/bin/sh

#  CodeSignatures.sh
#  
#
#  Created by Yngve Åström on 2020-02-10.
#
# Crawls through the apps in /Applications and outputs the app name, bundle id and codesignatur
# Needed an easy quick way to get the bundle id and code signatur for creating PPPC profiles
# Feel free to copy and 'steal' it

 while IFS= read -r app ; do
bundleID=$( defaults read "$app"/Contents/Info.plist CFBundleIdentifier )
codesignature=$( codesign -dr - "$app" 2>&1 | awk -F '>' '{print $2}' )
if [[ -n "$codesignature" ]]; then
echo App: "$app"
echo BundleID: "$bundleID"
echo CodeSignature: "$codesignature"
else
echo App: "$app"
echo BundleID: "$bundleID"
echo "CodeSignature: Missing Code Signature"
fi
done < <(find /Applications -iname "*.app" -maxdepth 2)
