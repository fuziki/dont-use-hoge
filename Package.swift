// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
let package = Package(
    name: "dont-use-hoge",
    products: [
        .executable(name: "dont-use-hoge", targets: ["dont-use-hoge"]),
        .plugin(name: "DontUseHogePlugin", targets: ["DontUseHogePlugin"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-syntax.git", exact: "0.50600.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "dont-use-hoge",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxParser", package: "swift-syntax"),
            ],
            linkerSettings: [
                .unsafeFlags(["-rpath", "/${CONFIGURATION_BUILD_DIR}/"])
            ]),
        .plugin(
            name: "DontUseHogePlugin",
            capability: .buildTool(),
            dependencies: [
                .target(name: "dont-use-hoge"),
            ]),
        .target(
            name: "Example",
            plugins: [
                .plugin(name: "DontUseHogePlugin"),
            ]),
        .testTarget(
            name: "dont-use-hogeTests",
            dependencies: ["dont-use-hoge"]),
    ]
)
