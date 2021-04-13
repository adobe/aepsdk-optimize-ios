export EXTENSION_NAME = AEPEdgePersonalization
PROJECT_NAME = $(EXTENSION_NAME)
TARGET_NAME_XCFRAMEWORK = $(EXTENSION_NAME).xcframework
SCHEME_NAME_XCFRAMEWORK = AEPEdgePersonalization

SIMULATOR_ARCHIVE_PATH = ./build/ios_simulator.xcarchive/Products/Library/Frameworks/
IOS_ARCHIVE_PATH = ./build/ios.xcarchive/Products/Library/Frameworks/

pod-install:
	(pod install --repo-update)

pod-repo-update:
	(pod repo update)
	
ci-pod-install:
	(bundle exec pod install --repo-update)

pod-update: pod-repo-update
	(pod update)

pod-lint:
	(pod lib lint --allow-warnings --verbose --swift-version=5.1)

open:
	open $(PROJECT_NAME).xcworkspace

clean:
	(rm -rf build)

test: clean
	@echo "######################################################################"
	@echo "### Testing iOS"
	@echo "######################################################################"
	xcodebuild test -workspace $(PROJECT_NAME).xcworkspace -scheme $(PROJECT_NAME) -destination 'platform=iOS Simulator,name=iPhone 8' -derivedDataPath build/out -enableCodeCoverage YES

archive:
	xcodebuild archive -workspace $(PROJECT_NAME).xcworkspace -scheme $(SCHEME_NAME_XCFRAMEWORK) -archivePath "./build/ios.xcarchive" -sdk iphoneos -destination="iOS" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
	xcodebuild archive -workspace $(PROJECT_NAME).xcworkspace -scheme $(SCHEME_NAME_XCFRAMEWORK) -archivePath "./build/ios_simulator.xcarchive" -sdk iphonesimulator -destination="iOS Simulator" SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
	xcodebuild -create-xcframework -framework $(SIMULATOR_ARCHIVE_PATH)$(EXTENSION_NAME).framework -framework $(IOS_ARCHIVE_PATH)$(EXTENSION_NAME).framework -output ./build/$(TARGET_NAME_XCFRAMEWORK)
	
# Usage: make check-version VERSION=1.0.0
check-version:
	(sh ./Scripts/version.sh $(VERSION))

test-SPM-integration:
	(sh ./Scripts/test-SPM.sh)

test-podspec:
	(sh ./Scripts/test-podspec.sh)

install-swiftlint:
	brew update-reset && brew install swiftlint && brew cleanup swiftlint

lint-autocorrect:
	(swiftlint autocorrect --format)

lint:
	(swiftlint lint Sources/AEPEdgePersonalization)

install-swiftformat:
	(brew install swiftformat) 

check-format:
	(swiftformat --lint Sources/AEPEdgePersonalization --swiftversion 5.1)
	
format:
	(swiftformat Sources/AEPEdgePersonalization --swiftversion 5.1)


