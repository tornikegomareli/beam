// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "BorderBeam",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
  ],
  products: [
    .library(name: "BorderBeam", targets: ["BorderBeam"]),
  ],
  targets: [
    .target(
      name: "BorderBeam",
      resources: [
        .process("Shaders/Medium.metal"),
        .process("Shaders/Small.metal"),
        .process("Shaders/Line.metal"),
      ]
    ),
  ]
)
