//
//  SRTFile EncodeError.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if SRT

import Foundation

extension SRTFile {
    public enum EncodeError: LocalizedError {
        case encodeError

        public var errorDescription: String? {
            switch self {
            case .encodeError:
                "Failed to encode SRT file data."
            }
        }
    }
}

#endif
