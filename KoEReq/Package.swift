import PackageDescription

let package = Package(
    name: "KoEReq",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(name: "KoEReq", targets: ["KoEReq"]),
    ],
    dependencies: [
        .package(url: "https://github.com/argmaxinc/WhisperKit", from: "0.6.0"),
        .package(url: "https://github.com/Azure/azure-sdk-for-swift.git", from: "1.3.0"),
    ],
    targets: [
        .executableTarget(
            name: "KoEReq",
            dependencies: [
                .product(name: "WhisperKit", package: "WhisperKit"),
                .product(name: "AzureOpenAI", package: "azure-sdk-for-swift"),
                .product(name: "AzureStorage", package: "azure-sdk-for-swift"),
            ],
            path: "Sources"
        ),
    ]
)
