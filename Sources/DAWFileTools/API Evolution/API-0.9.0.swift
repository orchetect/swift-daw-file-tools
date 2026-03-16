//
//  API-0.9.0.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if FCP && os(macOS)

import Foundation
import SwiftFCPXML
import SwiftTimecodeCore

extension FinalCutPro {
    @_documentation(visibility: internal)
    @available(*, deprecated, renamed: "FCPXML.timecodeSubFramesBase")
    public static var timecodeSubFramesBase: Timecode.SubFramesBase {
        SwiftFCPXML.FCPXML.timecodeSubFramesBase
    }
    
    @_documentation(visibility: internal)
    @available(*, deprecated, renamed: "FCPXML.timecodeUpperLimit")
    public static var timecodeUpperLimit: Timecode.UpperLimit {
        SwiftFCPXML.FCPXML.timecodeUpperLimit
    }
    
    @_documentation(visibility: internal)
    @available(*, deprecated, renamed: "FCPXML.timecodeStringFormat")
    public static var timecodeStringFormat: Timecode.StringFormat {
        SwiftFCPXML.FCPXML.timecodeStringFormat
    }
}

extension FinalCutPro {
    @_documentation(visibility: internal)
    @available(*, deprecated, renamed: "FCPXML.formTimecode(at:)")
    public static func formTimecode(
        at rate: TimecodeFrameRate
    ) -> Timecode {
        SwiftFCPXML.FCPXML.formTimecode(at: rate)
    }
    
    @_documentation(visibility: internal)
    @available(*, deprecated, renamed: "FCPXML.formTimecode(rational:at:)")
    public static func formTimecode(
        rational fraction: Fraction,
        at rate: TimecodeFrameRate
    ) throws -> Timecode {
        try SwiftFCPXML.FCPXML.formTimecode(rational: fraction, at: rate)
    }
    
    @_documentation(visibility: internal)
    @available(*, deprecated, renamed: "FCPXML.formTimecode(realTime:at:)")
    public static func formTimecode(
        realTime seconds: TimeInterval,
        at rate: TimecodeFrameRate
    ) throws -> Timecode {
        try SwiftFCPXML.FCPXML.formTimecode(realTime: seconds, at: rate)
    }
    
    @_documentation(visibility: internal)
    @available(*, deprecated, renamed: "FCPXML.formTimecodeInterval(at:)")
    public static func formTimecodeInterval(
        at rate: TimecodeFrameRate
    ) -> TimecodeInterval {
        SwiftFCPXML.FCPXML.formTimecodeInterval(at: rate)
    }
    
    @_documentation(visibility: internal)
    @available(*, deprecated, renamed: "FCPXML.formTimecodeInterval(realTime:at:)")
    public static func formTimecodeInterval(
        realTime seconds: TimeInterval,
        at rate: TimecodeFrameRate
    ) throws -> TimecodeInterval {
        try SwiftFCPXML.FCPXML.formTimecodeInterval(realTime: seconds, at: rate)
    }
    
    @_documentation(visibility: internal)
    @available(*, deprecated, renamed: "FCPXML.formTimecodeInterval(rational:at:)")
    public static func formTimecodeInterval(
        rational fraction: Fraction,
        at rate: TimecodeFrameRate
    ) throws -> TimecodeInterval {
        try SwiftFCPXML.FCPXML.formTimecodeInterval(rational: fraction, at: rate)
    }
}

#endif
