// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "R2Navigator",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v9), .watchOS(.v3)
    ],
    products: [
        .library(name: "R2Navigator", targets: ["R2Navigator"]),
    ],
    dependencies: [
        .package(path: "/Users/lei/Projects/Floral/Floral/modules/PreferSetting"),
        .package(path: "/Users/lei/Projects/Floral/Translator"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "1.7.4"),
        .package(url: "https://github.com/mxcl/PromiseKit.git", .upToNextMajor(from: "6.8.4")),
        .package(name:"R2Shared", url: "https://github.com/lololo/r2-shared-swift.git", .branch("develop") )
    ],
    targets: [
        .target(name: "R2Navigator",
                dependencies: ["SwiftSoup", "R2Shared", "Translator", "PromiseKit", "PreferSetting"],
                path: "r2-navigator-swift",
                exclude:["Info.plist"],
                resources:[
                    .process("Resources"),
                    .copy("EPUB/Resources")
                ]
        ),
    ]
)

