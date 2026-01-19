//
//  FCPXML Root Version.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if FCP && os(macOS) // XMLNode only works on macOS

import SwiftExtensions

extension FinalCutPro.FCPXML {
    /// FCPXML format version.
    public struct Version {
        /// Returns the FCPXML format version number as a semantic version type.
        public let semanticVersion: SemanticVersion
        
        /// Major version component.
        public var major: Int { semanticVersion.major }
        
        /// Minor version component.
        public var minor: Int { semanticVersion.minor }
        
        /// Patch version component.
        public var patch: Int { semanticVersion.patch }
        
        public init(_ semVer: SemanticVersion) {
            self.semanticVersion = semVer
        }
        
        public init(_ major: UInt, _ minor: UInt, _ patch: UInt = 0) {
            semanticVersion = SemanticVersion(major, minor, patch)
        }
    }
}

extension FinalCutPro.FCPXML.Version: Equatable { }

extension FinalCutPro.FCPXML.Version: Hashable { }

extension FinalCutPro.FCPXML.Version: Sendable { }

extension FinalCutPro.FCPXML.Version: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

// MARK: - Raw String Value

extension FinalCutPro.FCPXML.Version: RawRepresentable {
    public typealias RawValue = String
    
    public init?(rawValue: String) {
        guard let semVer = SemanticVersion(nonStrict: rawValue) else { return nil }
        self.semanticVersion = semVer
    }
    
    public var rawValue: String {
        semanticVersion.patch != 0
            ? "\(semanticVersion.major).\(semanticVersion.minor).\(semanticVersion.patch)"
            : "\(semanticVersion.major).\(semanticVersion.minor)"
    }
}

// MARK: - Static Members

extension FinalCutPro.FCPXML.Version {
    public static let ver1_0: Self = Self(1, 0, 0)
    public static let ver1_1: Self = Self(1, 1, 0)
    public static let ver1_2: Self = Self(1, 2, 0)
    public static let ver1_3: Self = Self(1, 3, 0)
    public static let ver1_4: Self = Self(1, 4, 0)
    public static let ver1_5: Self = Self(1, 5, 0)
    public static let ver1_6: Self = Self(1, 6, 0)
    public static let ver1_7: Self = Self(1, 7, 0)
    public static let ver1_8: Self = Self(1, 8, 0)
    public static let ver1_9: Self = Self(1, 9, 0)
    
    /// FCPXML 1.10.
    /// Format is a `fcpxmld` bundle.
    public static let ver1_10: Self = Self(1, 10)
    
    /// FCPXML 1.11.
    /// Format is a `fcpxmld` bundle.
    public static let ver1_11: Self = Self(1, 11)
    
    /// FCPXML 1.12 introduced in Final Cut Pro 10.8.
    /// Format is a `fcpxmld` bundle.
    public static let ver1_12: Self = Self(1, 12)
    
    /// FCPXML 1.13 introduced in Final Cut Pro 11.0.
    /// Format is a `fcpxmld` bundle.
    public static let ver1_13: Self = Self(1, 13)
    
    /// FCPXML 1.14 introduced in Final Cut Pro 12.0.
    /// Format is a `fcpxmld` bundle.
    public static let ver1_14: Self = Self(1, 14)
}

extension FinalCutPro.FCPXML.Version: CaseIterable {
    public static let allCases: [FinalCutPro.FCPXML.Version] = [
        .ver1_0,
        .ver1_1,
        .ver1_2,
        .ver1_3,
        .ver1_4,
        .ver1_5,
        .ver1_6,
        .ver1_7,
        .ver1_8,
        .ver1_9,
        .ver1_10,
        .ver1_11,
        .ver1_12,
        .ver1_13,
        .ver1_14
    ]
    
    /// Returns the latest FCPXML format version supported.
    public static var latest: Self { Self.allCases.last! }
}

extension FinalCutPro.FCPXML.Version: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.semanticVersion < rhs.semanticVersion
    }
}

// API Deprecations - swift-daw-file-tools 0.7.2

extension FinalCutPro.FCPXML.Version {
    @available(*, deprecated, renamed: "init(_:_:)")
    public init(major: Int, minor: Int) {
        self.init(UInt(major), UInt(minor))
    }
}

#endif
