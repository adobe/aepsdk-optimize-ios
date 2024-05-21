export EXTENSION_NAME = AEPOptimize
PROJECT_NAME = $(EXTENSION_NAME)
TARGET_NAME_XCFRAMEWORK = $(EXTENSION_NAME).xcframework
SCHEME_NAME_XCFRAMEWORK = AEPOptimize

CURRENT_DIRECTORY := ${CURDIR}
SIMULATOR_ARCHIVE_PATH = $(CURRENT_DIRECTORY)/build/ios_simulator.xcarchive/Products/Library/Frameworks/
SIMULATOR_ARCHIVE_DSYM_PATH = $(CURRENT_DIRECTORY)/build/ios_simulator.xcarchive/dSYMs/
IOS_ARCHIVE_PATH = $(CURRENT_DIRECTORY)/build/ios.xcarchive/Products/Library/Frameworks/
IOS_ARCHIVE_DSYM_PATH = $(CURRENT_DIRECTORY)/build/ios.xcarchive/dSYMs/
IOS_DESTINATION = 'platform=iOS Simulator,name=iPhone 15'

pod-install:
	(pod install --repo-update)

pod-repo-update:
	(pod repo update)
	
ci-pod-install:
	(bundle exec pod install --repo-update)

pod-update: pod-repo-update
	(pod update)

open:
	open $(PROJECT_NAME).xcworkspace

clean:
	(rm -rf build)

test: clean
	@echo "######################################################################"
	@echo "### Testing iOS"
	@echo "######################################################################"
	xcodebuild test -workspace $(PROJECT_NAME).xcworkspace -scheme $(PROJECT_NAME) -destination $(IOS_DESTINATION) -derivedDataPath build/out -resultBundlePath build/$(PROJECT_NAME).xcresult -enableCodeCoverage YES

archive: pod-install _archive

ci-archive: ci-pod-install _archive

_archive: clean build
	xcodebuild -create-xcframework -framework $(SIMULATOR_ARCHIVE_PATH)$(EXTENSION_NAME).framework -debug-symbols $(SIMULATOR_ARCHIVE_DSYM_PATH)$(EXTENSION_NAME).framework.dSYM -framework $(IOS_ARCHIVE_PATH)$(EXTENSION_NAME).framework -debug-symbols $(IOS_ARCHIVE_DSYM_PATH)$(EXTENSION_NAME).framework.dSYM -output ./build/$(TARGET_NAME_XCFRAMEWORK)

build:
	xcodebuild archive -workspace $(PROJECT_NAME).xcworkspace -scheme $(SCHEME_NAME_XCFRAMEWORK) -archivePath "./build/ios.xcarchive" -sdk iphoneos -destination="iOS" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
	xcodebuild archive -workspace $(PROJECT_NAME).xcworkspace -scheme $(SCHEME_NAME_XCFRAMEWORK) -archivePath "./build/ios_simulator.xcarchive" -sdk iphonesimulator -destination="iOS Simulator" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
	
zip:
	cd build && zip -r -X $(PROJECT_NAME).xcframework.zip $(PROJECT_NAME).xcframework/
	swift package compute-checksum build/$(PROJECT_NAME).xcframework.zip

# Usage: make check-version VERSION=1.0.0
check-version:
	(sh ./Scripts/version.sh $(VERSION))

test-SPM-integration:
	(sh ./Scripts/test-SPM.sh)

test-podspec:
	(sh ./Scripts/test-podspec.sh)

install-swiftformat:
	(brew install swiftformat) 

check-format:
	(swiftformat --lint Sources/$(PROJECT_NAME) --swiftversion 5.1)
	
swift-format:
	(swiftformat Sources/$(PROJECT_NAME) --swiftversion 5.1)

lint:
	(./Pods/SwiftLint/swiftlint lint $(PROJECT_NAME)/Sources)

lint-autocorrect:
	($(CURRENT_DIRECTORY)/Pods/SwiftLint/swiftlint --fix)

format: lint-autocorrect swift-format

# used to test update-versions.sh script locally
test-versions:
	(sh ./scripts/update-versions.sh -n Optimize -v 5.0.1 -d "AEPCore 5.0.0, AEPEdge 5.0.0")
