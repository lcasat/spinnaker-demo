#!/bin/bash
#
# Pretend "build" script for spinnaker-demo project...
# 
# Expects release version as argument (defaults to "Unknown")

version=0.1.1
release=$1
fullversion="${version}-${release:-unknown}"
buildDir=build
htmlDir=$buildDir/html
rootDir=$(pwd)
echo "Building spinnaker-demo project..."
sleep 5

echo "Cleaning $buildDir directory..."
sleep 2
[ -d $buildDir ] && rm -rf $buildDir

echo "Creating new $htmlDir directory and generating build..."
sleep 2
mkdir -p $htmlDir
cp -r src/* $htmlDir/

echo "Updating version to ${fullversion}..."
# Is it safe to just run this on all files in the $buildDir?
sed -i s/VERSION/${fullversion}/ $htmlDir/index.html
sed -i s/VERSION/${fullversion}/ $htmlDir/health

echo "Packaging Started..."
sleep 2
./package.sh $fullversion
echo "Packaging finished.."


# Expect $BUCKET, $ACCESS_KEY_ID, $SECRET_ACCESS_KEY to be set in Jenkins 
# credentials and fetched in pipeline.

echo "Bucket Name: "$BUCKET
echo "Access Key: " $ACCESS_KEY_ID
echo "Secret Key: " $SECRET_ACCESS_KEY
PACKAGE_PATH=build
echo "Upload to S3 Started...."
echo "Package path:"$PACKAGE_PATH
deb-s3 upload --bucket $BUCKET --access-key-id $ACCESS_KEY_ID --secret-access-key $SECRET_ACCESS_KEY --s3-region us-east-2 --arch amd64 --codename trusty --preserve-versions true $PACKAGE_PATH/*.deb
echo "Build completed..."
