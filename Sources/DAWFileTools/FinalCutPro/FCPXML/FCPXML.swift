//
//  FCPXML.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2026 Steffan Andrews • Licensed under MIT License
//

#if FCP

@_exported import SwiftFCPXML

// Note:
// FCPXML was extracted into its own repository called swift-fcpxml as of swift-daw-file-tools 0.9.0

extension FinalCutPro {
    #if os(macOS) // XMLNode only works on macOS

    @available(
        *,
        deprecated,
        message: "FCPXML is now outsourced to swift-fcpxml. FCPXML can be accessed as a top-level global type and the FinalCutPro namespace is no longer necessary to use."
    )
    public typealias FCPXML = SwiftFCPXML.FCPXML

    #endif
}

#endif
