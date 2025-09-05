// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Finoma",
    defaultLocalization: "pt-BR",
    platforms: [
        .iOS(.v16), .macOS(.v13)
    ],
    products: [
        .library(name: "FinomaCore", targets: ["FinomaCore"]),
        .library(name: "FinomaPersistence", targets: ["FinomaPersistence"]),
        .library(name: "FinomaServices", targets: ["FinomaServices"]),
        .library(name: "FinomaUI", targets: ["FinomaUI"]),
        .executable(name: "finoma-cli", targets: ["FinomaCLI"]) 
    ],
    dependencies: [
        // Sem dependências externas por enquanto
    ],
    targets: [
        .target(
            name: "FinomaCore",
            dependencies: [],
            path: "Sources/FinomaCore"
        ),
        .target(
            name: "FinomaPersistence",
            dependencies: ["FinomaCore"],
            path: "Sources/FinomaPersistence"
        ),
        .target(
            name: "FinomaServices",
            dependencies: ["FinomaCore", "FinomaPersistence"],
            path: "Sources/FinomaServices"
        ),
        .target(
            name: "FinomaUI",
            dependencies: ["FinomaServices"],
            path: "Sources/FinomaUI"
        ),
        .executableTarget(
            name: "FinomaCLI",
            dependencies: ["FinomaServices"],
            path: "Sources/FinomaCLI"
        )
    ]
)

