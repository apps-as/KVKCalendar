// swift-tools-version:5.5.0
import PackageDescription

let package = Package(
    name: "KVKCalendar",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "KVKCalendar",
            targets: ["KVKCalendar"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "KVKCalendar",
            dependencies: [],
            path: "KVKCalendar"),
    ]
)
