// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CustomAuth",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CustomAuth",
            targets: ["CustomAuth"]
        ),

        .library(
            name: "CustomAuthUI",
            targets: ["CustomAuthUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", "11.0.0"..<"12.0.0"),
        .package(url: "https://github.com/SwiftfulThinking/SignInAppleAsync.git", "1.0.0"..<"2.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CustomAuth",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "SignInAppleAsync", package: "SignInAppleAsync"),
            ]
        ),
        .target(
            name: "CustomAuthUI"
        ),
        .testTarget(
            name: "CustomAuthTests",
            dependencies: ["CustomAuth"]
        ),
    ]
)
