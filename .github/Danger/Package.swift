// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "Danger-CI",
  platforms: [
    .macOS(.v10_15)
  ],
  products: [
    .library(name: "DangerDeps", type: .dynamic, targets: ["DangerDependencies"])
  ],
  dependencies: [
    .package(name: "danger-swift", url: "https://github.com/danger/swift", from: "3.12.3"),
  ],
  targets: [
    .target(name: "DangerDependencies", dependencies: [
      .product(name: "Danger", package: "danger-swift"),
    ], path: "DangerFakeSources", sources: ["DangerFakeSource.swift"])
  ]
)
