#!/bin/bash

for myScheme in LiveShow LiveShow-TH LiveShow-VN LiveShow-JP LiveShow-Backup
do
	xcodebuild -workspace LiveShow.xcworkspace -scheme $myScheme archive
done
