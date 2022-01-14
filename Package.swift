// swift-tools-version:5.5
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
    .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.9.0")
  ],
  targets: [
    .target(
      name: "PlayButton",
      dependencies: [],
      path: "Sources"
    ),
    .testTarget(
      name: "PlayButtonTests",
      dependencies: ["PlayButton", "SnapshotTesting"],
      resources: [
        .copy("__Snapshots__")
      ]
    ),
  ]
)
