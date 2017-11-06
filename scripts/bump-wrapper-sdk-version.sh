#!/bin/bash
# Bump version of App Center React Native SDK for release

set -e

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        --newWrapperSdkVersion)
            newWrapperSdkVersion=$VALUE ;;
        *)
    esac
    shift
done

# Exit if newWrapperSdkVersion has not been set
if [ -z $newWrapperSdkVersion ]; then
    echo "--newWrapperSdkVersion cannot be empty. Please pass in new sdk version as parameter."
    exit 1
fi

# Find out the old wrapper sdk version
oldWrapperSdkVersionString=$(grep versionName ./appcenter/android/build.gradle)
[[ ${oldWrapperSdkVersionString} =~ ([0-9]+.[0-9]+.[0-9]+) ]]
oldWrapperSdkVersion="${BASH_REMATCH[1]}"

# Find out the old Android versionCode
oldAndroidVersionCodeString=$(grep versionCode ./appcenter/android/build.gradle)
[[ ${oldAndroidVersionCodeString} =~ ([0-9]+) ]]
oldAndroidVersionCode="${BASH_REMATCH[1]}"

# Compute the new Android versionCode by adding one to old Android versionCode
newAndroidVersionCode=$(($oldAndroidVersionCode + 1))

# Exit if any of the parameters have not been set
if [ -z $oldWrapperSdkVersion ]; then
    echo "oldWrapperSdkVersion cannot be empty"
    exit 1
fi
if [ -z $oldAndroidVersionCode ]; then
    echo "oldAndroidVersionCode cannot be empty"
    exit 1
fi
if [ -z $newAndroidVersionCode ]; then
    echo "newAndroidVersionCode cannot be empty"
    exit 1
fi

echo "React-Native SDK $oldWrapperSdkVersion will be updated to $newWrapperSdkVersion"
echo "React-Native SDK Android VersionCode $oldAndroidVersionCode will be updated to $newAndroidVersionCode"

# Update wrapper sdk version in package.json for appcenter, appcenter-crashes, appcenter-analytics, 
# appcenter-push and appcenter-link-script NPM packages

export newVersion=$newWrapperSdkVersion
cat ./appcenter/package.json | jq -r '.version = env.newVersion' | jq -r '.dependencies."appcenter-link-scripts" = env.newVersion' > ./appcenter/package.json.temp && mv ./appcenter/package.json.temp ./appcenter/package.json
cat ./appcenter-crashes/package.json | jq -r '.version = env.newVersion' | jq -r '.dependencies."appcenter" = env.newVersion' > ./appcenter-crashes/package.json.temp && mv ./appcenter-crashes/package.json.temp ./appcenter-crashes/package.json 
cat ./appcenter-analytics/package.json | jq -r '.version = env.newVersion' | jq -r '.dependencies."appcenter" = env.newVersion' > ./appcenter-analytics/package.json.temp && mv ./appcenter-analytics/package.json.temp ./appcenter-analytics/package.json
cat ./appcenter-push/package.json | jq -r '.version = env.newVersion' | jq -r '.dependencies."appcenter" = env.newVersion' > ./appcenter-push/package.json.temp && mv ./appcenter-push/package.json.temp ./appcenter-push/package.json
cat ./appcenter-link-scripts/package.json | jq -r '.version = env.newVersion' > ./appcenter-link-scripts/package.json.temp && mv ./appcenter-link-scripts/package.json.temp ./appcenter-link-scripts/package.json

# Update wrapperk sdk version and android VersionCode in Android build.gradle for appcenter, appcenter-crashes, appcenter-analytics,
# appcenter-push and AppCenterReactNativeShared projects

gradleFileContent="$(cat ./appcenter/android/build.gradle)"
gradleFileContent=`echo "${gradleFileContent/versionName \"$oldWrapperSdkVersion\"/versionName \"$newWrapperSdkVersion\"}"`
gradleFileContent=`echo "${gradleFileContent/com.microsoft.appcenter.reactnative\:appcenter-react-native\:$oldWrapperSdkVersion/com.microsoft.appcenter.reactnative:appcenter-react-native:$newWrapperSdkVersion}"`
echo "${gradleFileContent/versionCode $oldAndroidVersionCode/versionCode $newAndroidVersionCode}" > ./appcenter/android/build.gradle

gradleFileContent="$(cat ./appcenter-crashes/android/build.gradle)"
gradleFileContent=`echo "${gradleFileContent/versionName \"$oldWrapperSdkVersion\"/versionName \"$newWrapperSdkVersion\"}"`
gradleFileContent=`echo "${gradleFileContent/com.microsoft.appcenter.reactnative\:appcenter-react-native\:$oldWrapperSdkVersion/com.microsoft.appcenter.reactnative:appcenter-react-native:$newWrapperSdkVersion}"`
echo "${gradleFileContent/versionCode $oldAndroidVersionCode/versionCode $newAndroidVersionCode}" > ./appcenter-crashes/android/build.gradle

gradleFileContent="$(cat ./appcenter-analytics/android/build.gradle)"
gradleFileContent=`echo "${gradleFileContent/versionName \"$oldWrapperSdkVersion\"/versionName \"$newWrapperSdkVersion\"}"`
gradleFileContent=`echo "${gradleFileContent/com.microsoft.appcenter.reactnative\:appcenter-react-native\:$oldWrapperSdkVersion/com.microsoft.appcenter.reactnative:appcenter-react-native:$newWrapperSdkVersion}"`
echo "${gradleFileContent/versionCode $oldAndroidVersionCode/versionCode $newAndroidVersionCode}" > ./appcenter-analytics/android/build.gradle

gradleFileContent="$(cat ./appcenter-push/android/build.gradle)"
gradleFileContent=`echo "${gradleFileContent/versionName \"$oldWrapperSdkVersion\"/versionName \"$newWrapperSdkVersion\"}"`
gradleFileContent=`echo "${gradleFileContent/com.microsoft.appcenter.reactnative\:appcenter-react-native\:$oldWrapperSdkVersion/com.microsoft.appcenter.reactnative:appcenter-react-native:$newWrapperSdkVersion}"`
echo "${gradleFileContent/versionCode $oldAndroidVersionCode/versionCode $newAndroidVersionCode}" > ./appcenter-push/android/build.gradle

gradleFileContent="$(cat ./AppCenterReactNativeShared/android/build.gradle)"
gradleFileContent=`echo "${gradleFileContent/versionName \"$oldWrapperSdkVersion\"/versionName \"$newWrapperSdkVersion\"}"`
echo "${gradleFileContent/versionCode $oldAndroidVersionCode/versionCode $newAndroidVersionCode}" > ./AppCenterReactNativeShared/android/build.gradle

# Update wrapper sdk version in postlink.js for appcenter, appcenter-crashes, appcenter-analytics,
# and appcenter-push
postlinkFileContent="$(cat ./appcenter/scripts/postlink.js)"
echo "${postlinkFileContent/$oldWrapperSdkVersion/$newWrapperSdkVersion}" > ./appcenter/scripts/postlink.js

postlinkFileContent="$(cat ./appcenter-crashes/scripts/postlink.js)"
echo "${postlinkFileContent/$oldWrapperSdkVersion/$newWrapperSdkVersion}" > ./appcenter-crashes/scripts/postlink.js

postlinkFileContent="$(cat ./appcenter-analytics/scripts/postlink.js)"
echo "${postlinkFileContent/$oldWrapperSdkVersion/$newWrapperSdkVersion}" > ./appcenter-analytics/scripts/postlink.js

postlinkFileContent="$(cat ./appcenter-push/scripts/postlink.js)"
echo "${postlinkFileContent/$oldWrapperSdkVersion/$newWrapperSdkVersion}" > ./appcenter-push/scripts/postlink.js

# Update wrapper sdk version in AppCenterReactNativeShared/Products/AppCenterReactNativeShared.podspec
podspecFileContent="$(cat ./AppCenterReactNativeShared/Products/AppCenterReactNativeShared.podspec)"
echo "${podspecFileContent/$oldWrapperSdkVersion/$newWrapperSdkVersion}" > ./AppCenterReactNativeShared/Products/AppCenterReactNativeShared.podspec

# Update wrapper sdk version in AppCenterReactNativeShared/ios/AppCenterReactNativeShared/AppCenterReactNativeShared.m
fileContent="$(cat ./AppCenterReactNativeShared/ios/AppCenterReactNativeShared/AppCenterReactNativeShared.m)"
echo "${fileContent/$oldWrapperSdkVersion/$newWrapperSdkVersion}" > ./AppCenterReactNativeShared/ios/AppCenterReactNativeShared/AppCenterReactNativeShared.m

echo "done."