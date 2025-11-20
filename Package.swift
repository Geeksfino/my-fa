// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MyFA",
    platforms: [
        .iOS(.v16)
    ],
    dependencies: [
        .package(url: "https://github.com/Geeksfino/finclip-chatkit.git", from: "0.9.0")
    ],
    targets: [
        .target(
            name: "MyFA",
            dependencies: [
                .product(name: "FinClipChatKit", package: "finclip-chatkit")
            ]
        )
    ]
)

