// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "R2Navigator",
    platforms: [
        .macOS(.v10_10), .iOS(.v12), .tvOS(.v9), .watchOS(.v3)
    ],
    products: [
        .library(name: "R2Navigator", targets: ["R2Navigator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "1.7.4"),
        .package( path: "/Users/lei/Projects/Floral/r2-shared-swift" )
    ],
    targets: [
        .target(name: "R2Navigator",
                dependencies: ["SwiftSoup", "R2Shared"],
                path: "r2-navigator-swift"
        ),
    ]
)

