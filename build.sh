#!/bin/bash

PROJECT_NAME="HandyMenuFramework"
ARCHIVES_PATH="../Archives"
OLD_FRAMEWORK_NAME="HandyMenuFramework"
OLD_FRAMEWORK_ARCHIVE_PATH="${ARCHIVES_PATH}/${OLD_FRAMEWORK_NAME}"
NEW_FRAMEWORK_NAME="HandyMenuModern"
NEW_FRAMEWORK_ARCHIVE_PATH="${ARCHIVES_PATH}/${NEW_FRAMEWORK_NAME}"

PLUGIN_BUNDLE_NAME="HandyMenu.sketchplugin"
PLUGIN_BUNDLE_PATH="../${PLUGIN_BUNDLE_NAME}/"

CONTENT_SOURCE_PATH="../Contents"
CONTENT_TARGET_PATH="${PLUGIN_BUNDLE_PATH}/Contents"

PLUGIN_TARGET_PATH="/Users/serge/Library/Application Support/com.bohemiancoding.sketch3/Plugins/${PLUGIN_BUNDLE_NAME}"

# Cleaning
echo "Cleaning..."
if [ -d "${PLUGIN_BUNDLE_PATH}/" ]; then
    rm -rf $PLUGIN_BUNDLE_PATH
fi

# Create Bundle
echo "Creating the new bundle..."
mkdir $PLUGIN_BUNDLE_PATH

# Move Content
echo "Moving Contents..."
mkdir $CONTENT_TARGET_PATH
cp -avR $CONTENT_SOURCE_PATH $PLUGIN_BUNDLE_PATH

# Arhiving Frameworks
echo "Arhiving frameworks..."
if [ -d "$ARCHIVES_PATH" ]; then
    echo "Removing old arhives"
    rm -rf "$ARCHIVES_PATH"
fi
xcodebuild archive -project "${PROJECT_NAME}.xcodeproj" -scheme ${OLD_FRAMEWORK_NAME} -destination="platform=OS X,arch=x86_64" -archivePath $OLD_FRAMEWORK_ARCHIVE_PATH SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
xcodebuild archive -project "${PROJECT_NAME}.xcodeproj" -scheme ${NEW_FRAMEWORK_NAME} -destination="platform=OS X,arch=x86_64" -archivePath $NEW_FRAMEWORK_ARCHIVE_PATH SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

# Moving Frameworks
echo "Moving frameworks to ${CONTENT_TARGET_PATH}"
cp -R "${OLD_FRAMEWORK_ARCHIVE_PATH}.xcarchive/Products/Library/Frameworks/${OLD_FRAMEWORK_NAME}.framework" "${CONTENT_TARGET_PATH}/Resources/${OLD_FRAMEWORK_NAME}.framework"
cp -R "${NEW_FRAMEWORK_ARCHIVE_PATH}.xcarchive/Products/Library/Frameworks/${NEW_FRAMEWORK_NAME}.framework" "${CONTENT_TARGET_PATH}/Resources/${NEW_FRAMEWORK_NAME}.framework"

rm -rf "$ARCHIVES_PATH"

# Installing plugin
echo "Copying plugin to $PLUGIN_TARGET_PATH"
if [ -d "$PLUGIN_TARGET_PATH" ]; then
    echo "Previous build is found. Removing..."
    rm -rf "$PLUGIN_TARGET_PATH"
fi

cp -R $PLUGIN_BUNDLE_PATH "$PLUGIN_TARGET_PATH"