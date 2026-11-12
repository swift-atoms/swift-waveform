// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "swift-waveform",
    platforms: [.macOS(.v27), .iOS(.v27), .tvOS(.v27), .watchOS(.v27), .visionOS(.v27)],
    products: [.library(name: "Waveform", targets: ["Waveform"])],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-trigonometry.git", branch: "main")
    ],
    targets: [
        .target(
            name: "Waveform",
            dependencies: [
                .product(name: "Trigonometry", package: "swift-trigonometry")
            ]
        ),
        .testTarget(
            name: "Waveform Tests",
            dependencies: [
                .target(name: "Waveform")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
            .strictMemorySafety(),
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
            .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
            .enableUpcomingFeature("InferIsolatedConformances"),
            .enableExperimentalFeature("Lifetimes"),
            .treatAllWarnings(as: .error),
        ]
}
