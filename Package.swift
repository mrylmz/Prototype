// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Prototype",
    platforms: [.macOS(.v14), .iOS(.v16), .tvOS(.v16), .watchOS(.v6), .macCatalyst(.v16)],
    products: [
        .library(name: "Prototype", targets: ["Prototype", "PrototypeAPI"]),
        .library(name: "PrototypeUI", targets: ["PrototypeUI"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            from: "600.0.0"
        ),
    ],
    targets: [
        .macro(
            name: "PrototypeMacros",
            dependencies: [
                .target(name: "PrototypeAPI"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .target(name: "SwiftSyntaxExtensions")
            ]
        ),
        .target(
            name: "Prototype",
            dependencies: [
                .target(name: "PrototypeMacros"),
                .target(name: "PrototypeAPI"),
            ]
        ),
        .target(
            name: "PrototypeAPI"
        ),
        .executableTarget(
            name: "PrototypeClient",
            dependencies: [
                .target(name: "Prototype"),
                .target(name: "PrototypeUI")
            ]
        ),
        .target(
            name: "PrototypeUI"
        ),
        .target(
            name: "SwiftSyntaxExtensions",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "PrototypeTests",
            dependencies: [
                .target(name: "PrototypeAPI"),
                .target(name: "PrototypeMacros"),
                .target(name: "SwiftSyntaxExtensions"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)

