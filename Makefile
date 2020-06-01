UNAME = ${shell uname}

PACKAGE_NAME = ShapefileParserPackageTests

PLATFORM = x86_64-apple-macosx

BUILD_RESOURCES_DIRECTORY = ./.build/${PLATFORM}/debug/${PACKAGE_NAME}.xctest/Contents/Resources

copyTestResources:
	mkdir -p ${BUILD_RESOURCES_DIRECTORY}
	cp Resources/* ${BUILD_RESOURCES_DIRECTORY}

test: copyTestResources
	swift test

clean:
	rm -rf .build
