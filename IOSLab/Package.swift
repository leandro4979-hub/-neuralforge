// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "IOSLab",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "IOSLab",
            targets: ["IOSLab"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "IOSLab",
            dependencies: [
                "Core",
                "SimulatorIntegration",
                "DeviceProfiles",
                "ScenarioEngine",
                "App",
                .product(name: "Yams", package: "Yams"),
            ],
            path: "Sources"
        ),
        .target(
            name: "Core",
            dependencies: [
                .product(name: "Yams", package: "Yams"),
            ],
            path: "Sources/Core"
        ),
        .target(
            name: "SimulatorIntegration",
            dependencies: ["Core"],
            path: "Sources/SimulatorIntegration"
        ),
        .target(
            name: "DeviceProfiles",
            dependencies: ["Core"],
            path: "Sources/DeviceProfiles"
        ),
        .target(
            name: "ScenarioEngine",
            dependencies: [
                "Core",
                .product(name: "Yams", package: "Yams"),
            ],
            path: "Sources/ScenarioEngine"
        ),
        .target(
            name: "App",
            dependencies: [
                "Core",
                "SimulatorIntegration",
                "DeviceProfiles",
                "ScenarioEngine",
            ],
            path: "Sources/App"
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                "App",
                "Core",
                "SimulatorIntegration",
            ],
            path: "Tests/AppTests"
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: [
                "Core",
                "ScenarioEngine",
            ],
            path: "Tests/CoreTests"
        ),
    ],
    swiftLanguageModes: [.v6]
)
