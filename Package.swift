// swift-tools-version: 5.9

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Prototype",
    platforms: [.macOS(.v11), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(name: "Prototype", targets: ["Prototype"]),
        .executable(name: "PrototypeClient", targets: ["PrototypeClient"]),
        .library(name: "SwiftSyntaxExtensions", targets: ["SwiftSyntaxExtensions"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0-swift-5.9-DEVELOPMENT-SNAPSHOT-2023-04-25-b"),
    ],
    targets: [
        .macro(
            name: "PrototypeMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .target(name: "SwiftSyntaxExtensions")
            ]
        ),
        .target(
            name: "Prototype",
            dependencies: [
                .target(name: "PrototypeMacros"),
            ]
        ),
        .executableTarget(
            name: "PrototypeClient",
            dependencies: [
                .target(name: "Prototype"),
            ]
        ),
        .testTarget(
            name: "PrototypeTests",
            dependencies: [
                .target(name: "PrototypeMacros"),
                .target(name: "SwiftSyntaxExtensions"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "SwiftSyntaxExtensions",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
            ]
        )
    ]
)

