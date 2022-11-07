// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "PlayButton",
  platforms: [
    .iOS(.v11),
    .tvOS(.v10)
  ],
  products: [
    .library(
      name: "PlayButton",
      targets: ["PlayButton"]
    ),
  ],
  dependencies: [
		.package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", exact: "1.9.0")
  ],
  targets: [
    .target(
      name: "PlayButton",
      dependencies: [],
      path: "Sources"
    ),
    .testTarget(
      name: "PlayButtonTests",
      dependencies: [
        "PlayButton",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
      ],
      resources: [
        .copy("__Snapshots__")
      ]
    ),
  ]
)
