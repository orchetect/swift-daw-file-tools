// swift-tools-version: 6.2
// (be sure to update the .swift-version file when this Swift version changes)

import PackageDescription

let package = Package(
    name: "swift-daw-file-tools",
    platforms: [
        .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(name: "DAWFileTools", targets: ["DAWFileTools"])
    ],
    traits: [
        .cubase,
        .fcp,
        .midiFile,
        .proTools,
        .srt,
        .default(enabledTraits: [.cubase, .fcp, .midiFile, .proTools, .srt])
    ],
    dependencies: [
        .package(url: "https://github.com/orchetect/swift-extensions", from: "2.0.0"),
        .package(url: "https://github.com/orchetect/swift-timecode", from: "3.0.0"),
        .package(url: "https://github.com/orchetect/MIDIKit", from: "0.10.7"),
        
        // testing-only dependnecies
        .package(url: "https://github.com/orchetect/swift-testing-extensions", from: "0.2.4"),
    ],
    targets: [
        .target(
            name: "DAWFileTools",
            dependencies: [
                .product(name: "SwiftExtensions", package: "swift-extensions"),
                .product(name: "SwiftTimecodeCore", package: "swift-timecode"),
                .product(name: "MIDIKitSMF", package: "MIDIKit", condition: .when(traits: [.midiFile]))
            ]
        ),
        .testTarget(
            name: "DAWFileToolsTests",
            dependencies: [
                "DAWFileTools",
                .product(name: "TestingExtensions", package: "swift-testing-extensions")
            ],
            resources: [
                .copy("Cubase/Resources/Cubase TrackArchive XML Exports"),
                .copy("ProTools/Resources/PT Session Text Exports"),
                .copy("FinalCutPro/Resources/FCPXML Exports"),
                .copy("SRT/Resources/SRT Files")
            ]
        )
    ]
)

// MARK: - Traits

extension Trait {
    static var cubase: Trait { .trait(name: "Cubase") }
    static var fcp: Trait { .trait(name: "FCP") }
    static var midiFile: Trait { .trait(name: "MIDIFile") }
    static var proTools: Trait { .trait(name: "ProTools") }
    static var srt: Trait { .trait(name: "SRT") }
}

// MARK: - Helpers

@available(_PackageDescription 6.1)
extension Trait {
    @_disfavoredOverload
    public static func trait(name: String, description: String? = nil, enabledTraits: Set<Trait> = []) -> Trait {
        .trait(name: name, description: description, enabledTraits: Set(enabledTraits.map(\.name)))
    }
    
    @_disfavoredOverload
    public static func `default`(enabledTraits: Set<Trait>) -> Trait {
        .default(enabledTraits: Set(enabledTraits.map(\.name)))
    }
}

extension TargetDependencyCondition {
    @available(_PackageDescription 6.1)
    @_disfavoredOverload
    public static func when(platforms: [Platform], traits: Set<Trait>) -> TargetDependencyCondition? {
        .when(platforms: platforms, traits: Set(traits.map(\.name)))
    }
    
    @available(_PackageDescription 6.1)
    @_disfavoredOverload
    public static func when(traits: Set<Trait>) -> TargetDependencyCondition? {
        .when(traits: Set(traits.map(\.name)))
    }
}
