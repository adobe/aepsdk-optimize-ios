# Adobe Experience Platform Mobile Personalization SDK

## About this project

The AEP Mobile Personalization SDK Extension provides APIs to enable real-time personalization workflows in Adobe Experience Platform SDKs using the Edge decisioning services. It depends on AEPCore and requires AEPEdge Extension to send personalization query Events to the Experience Edge network.

## Requirements
- Xcode 11.0 (or newer)
- Swift 5.1 (or newer)

## Installation

These are currently the supported installation options:

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

```ruby
# Podfile
use_frameworks!

# for app development, include all the following pods
target 'YOUR_TARGET_NAME' do
      pod 'AEPCore'
      pod 'AEPEdge'
      pod 'AEPEdgePersonalization'
end
```

Replace `YOUR_TARGET_NAME` and then, in the `Podfile` directory, type:

```ruby
$ pod install
```

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

To add the AEPEdgePersonalization Package to your application, from the Xcode menu select:

`File > Swift Packages > Add Package Dependency...`

Enter the URL for the AEPEdgePersonalization package repository: `https://github.com/adobe/aepsdk-edgepersonalization-ios.git`.

When prompted, make sure you change the branch to `main`.

Alternatively, if your project has a `Package.swift` file, you can add AEPEdgePersonalization directly to your dependencies:

```
dependencies: [
    .package(url: "https://github.com/adobe/aepsdk-edgepersonalization-ios.git", .branch: "main"),
targets: [
       .target(name: "YourTarget",
                    dependencies: ["AEPEdgePersonalization"],
              path: "your/path"),
    ]
]
```

### Binaries

To generate `AEPEdgePersonalization.xcframework`, run the following Makefile target from the project root directory:

```ruby
$ make archive
```

This generates the xcframework under the `build` folder. Drag and drop the `.xcframework` to your app target in Xcode.

## Development

To install pod dependencies after you clone or download this project, run the following Makefile target from the root directory:

~~~
make pod-install
~~~

To fetch latest versions of the dependencies, run the following Makefile target from the project root directory:

~~~
make pod-update
~~~

#### Open the project Xcode workspace
To open the project workspace in Xcode, click on `AEPPersonalization.xcworkspace` or run the following Makefile target from the project root directory:

~~~
make open
~~~

#### Run tests

To execute the tests, run the following Makefile target from the project root directory:

~~~
make test
~~~

## Documentation
TBD

## Related Projects

| Project                                                      | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [AEPCore Extensions](https://github.com/adobe/aepsdk-core-ios) | The AEPCore extensions provide a common set of functionality and services required by all the Mobile SDK extensions. |
| [AEPEdge Extension](https://github.com/adobe/aepsdk-edge-ios) | The AEPEdge extension enables sending data to Adobe Experience Platform from Mobile Apps. | 
| [AEP SDK Sample App for iOS](https://github.com/adobe/aepsdk-sample-app-ios) | It contains iOS sample apps, both Objective-C and Swift variants, for the AEP Mobile SDKs. |

## Contributing

Contributions are welcome! Read the [Contributing Guide](./.github/CONTRIBUTING.md) for more information.

## Licensing

This project is licensed under the Apache V2 License. See [LICENSE](LICENSE) for more information.
