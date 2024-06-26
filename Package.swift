// swift-tools-version:5.2

// swiftlint:disable explicit_top_level_acl
// swiftlint:disable prefixed_toplevel_constant
// swiftlint:disable line_length
// swiftlint:disable explicit_acl

import PackageDescription

let package = Package(
  name: "MistKit",
  platforms: [.macOS(.v10_15)],
  products: [
    .library(
      name: "MistKit",
      targets: ["MistKit"]
    ),
    .library(
      name: "MistKitNIO",
      targets: ["MistKitNIO"]
    ),
    .library(
      name: "MistKitVapor",
      targets: ["MistKitVapor"]
    ),
    .executable(name: "mistdemoc", targets: ["mistdemoc"]),
    .executable(name: "mistdemod", targets: ["mistdemod"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.20.0"),
    .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.4.0"),
    .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
    .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
    .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.6.0"),
    // dev
    .package(url: "https://github.com/shibapm/Komondor", from: "1.1.1"), // dev
    .package(url: "https://github.com/SourceDocs/SourceDocs.git", from: "2.0.1"), // dev
    .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.48.12"), // dev
    .package(url: "https://github.com/realm/SwiftLint", from: "0.43.0"), // dev
    .package(url: "https://github.com/shibapm/Rocket", from: "1.2.0"), // dev
    .package(url: "https://github.com/brightdigit/swift-test-codecov", from: "1.0.0") // dev
  ],
  targets: [
    .target(
      name: "MistKit",
      dependencies: []
    ),
    .target(
      name: "MistKitNIO",
      dependencies: [
        "MistKit",
        .product(name: "NIO", package: "swift-nio"),
        .product(name: "NIOHTTP1", package: "swift-nio"),
        .product(name: "AsyncHTTPClient", package: "async-http-client")
      ]
    ),
    .target(
      name: "MistKitVapor",
      dependencies: [
        "MistKit",
        "MistKitNIO",
        .product(name: "Vapor", package: "vapor"),
        .product(name: "Fluent", package: "fluent")
      ]
    ),
    .target(
      name: "mistdemoc",
      dependencies: [
        "MistKit",
        "MistKitNIO", "MistKitDemo",
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ]
    ),
    .target(
      name: "mistdemod",
      dependencies: [
        "MistKit", "MistKitVapor", "MistKitDemo",
        .product(name: "Vapor", package: "vapor"),
        .product(name: "Fluent", package: "fluent"),
        .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver")
      ]
    ),
    .target(
      name: "MistKitDemo",
      dependencies: ["MistKit"]
    ),
    .testTarget(
      name: "MistKitTests",
      dependencies: ["MistKit"]
    )
  ]
)

#if canImport(PackageConfig)
import PackageConfig

let requiredCoverage: Int = 40

let config = PackageConfiguration([
  "komondor": [
    "pre-push": [
      "swift test --enable-code-coverage --enable-test-discovery",
      "swift run swift-test-codecov .build/debug/codecov/MistKit.json --minimum \(requiredCoverage)"
    ],
    "pre-commit": [
      "swift test --enable-code-coverage --enable-test-discovery --generate-linuxmain",
      "swift run swiftformat .",
      "swift run swiftlint autocorrect",
      //        "swift run sourcedocs generate build -cra",
      "git add .",
      "swift run swiftformat --lint .",
      "swift run swiftlint"
    ]
  ]
]).write()
#endif
