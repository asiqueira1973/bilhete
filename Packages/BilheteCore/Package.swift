// swift-tools-version: 6.2
// Package interno do Bilhete (spec 4.6). Tudo o que o app e a widget extension
// compartilham vive aqui — modelo, store, intents, Live Activity, preferências
// e direito de compra. Nenhum arquivo é duplicado entre targets (spec 18.3).

import PackageDescription

let package = Package(
    name: "BilheteCore",
    defaultLocalization: "pt-BR",
    platforms: [
        // iPhone apenas, iOS 18.0 (spec 4.2 e decisão D-2).
        .iOS(.v18)
    ],
    products: [
        .library(name: "BilheteCore", targets: ["BilheteCore"])
    ],
    targets: [
        .target(
            name: "BilheteCore",
            resources: [
                // A paleta da seção 16.2 vive aqui para o app e a widget
                // extension usarem o mesmo arquivo (spec 18.3).
                .process("Resources/Colors.xcassets")
            ],
            swiftSettings: [
                // O app inteiro vive na main actor: SwiftData e SwiftUI já são
                // isolados nela, e o store é o dono único da escrita (13.1).
                .defaultIsolation(MainActor.self)
            ]
        )
    ]
)
