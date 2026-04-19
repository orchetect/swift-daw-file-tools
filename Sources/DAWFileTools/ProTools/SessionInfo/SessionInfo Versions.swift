//
//  SessionInfo Versions.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if ProTools

import Foundation

extension ProTools.SessionInfo {
    public enum MarkersListingVersion: Equatable, Hashable {
        /// Pro Tools versions prior to 2023.12.
        case legacy

        /// Pro Tools 2023.12 and up.
        case pt2023_12
    }
}

extension ProTools.SessionInfo.MarkersListingVersion: Sendable { }

extension ProTools.SessionInfo.MarkersListingVersion {
    public var columnCount: Int {
        switch self {
        case .legacy: 6
        case .pt2023_12: 8
        }
    }

    public var commentColumnIndex: Int {
        switch self {
        case .legacy: 5
        case .pt2023_12: 7
        }
    }
}

#endif
