// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-tree-keyed",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Tree Keyed",
            targets: ["Tree Keyed"]
        ),
        .library(
            name: "Tree Keyed Test Support",
            targets: ["Tree Keyed Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-tree.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-index.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-dictionary.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-dictionary-ordered.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-hash.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-hash-table.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-column.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ownership-shared.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-storage-generational.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-storage.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-buffer-linear.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-buffer-ring.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-stack.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-queue.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-iterator.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-sequence.git",
            branch: "main"
        ),

        .package(
            url: "https://github.com/swift-molecules/swift-property.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "Tree Keyed",
            dependencies: [
                .product(name: "Tree", package: "swift-tree"),
                .product(name: "Index", package: "swift-index"),
                .product(name: "Dictionary Primitive", package: "swift-dictionary"),
                .product(
                    name: "Dictionary Ordered Primitive",
                    package: "swift-dictionary-ordered"
                ),
                .product(
                    name: "Dictionary Ordered",
                    package: "swift-dictionary-ordered"
                ),
                .product(name: "Hash", package: "swift-hash"),
                .product(name: "Hash Indexed Primitive", package: "swift-hash-table"),
                .product(name: "Column", package: "swift-column"),
                .product(
                    name: "Ownership Shared Primitive",
                    package: "swift-ownership-shared"
                ),
                .product(
                    name: "Storage Generational",
                    package: "swift-storage-generational"
                ),
                .product(name: "Store Primitive", package: "swift-storage"),
                .product(
                    name: "Buffer Linear Primitive",
                    package: "swift-buffer-linear"
                ),
                .product(name: "Buffer Ring Primitive", package: "swift-buffer-ring"),
                .product(name: "Stack Primitive", package: "swift-stack"),
                .product(name: "Stack", package: "swift-stack"),
                .product(name: "Queue", package: "swift-queue"),
                .product(name: "Iterator Protocol", package: "swift-iterator"),
                .product(name: "Iterator Chunk", package: "swift-iterator"),
                .product(name: "Iterable", package: "swift-iterator"),
                .product(name: "Sequence", package: "swift-sequence"),
                .product(name: "Property", package: "swift-property"),
            ]
        ),

        .target(
            name: "Tree Keyed Test Support",
            dependencies: [
                "Tree Keyed",
                .product(name: "Tree Test Support", package: "swift-tree"),
            ],
            path: "Tests/Support"
        ),

        .testTarget(
            name: "Tree Keyed Tests",
            dependencies: [
                "Tree Keyed",
                "Tree Keyed Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = [
        .enableExperimentalFeature("RawLayout")
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
