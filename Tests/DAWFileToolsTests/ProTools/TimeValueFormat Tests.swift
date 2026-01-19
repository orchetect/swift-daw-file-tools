//
//  TimeValueFormat Tests.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing

@Suite struct ProTools_TimeValueFormatTests {
    typealias Fmt = ProTools.SessionInfo.TimeValueFormat
    
    @Test
    func heuristic_BaselineChecks() async throws {
        // empty
        #expect(throws: (any Error).self) {try Fmt(heuristic: "") }
        #expect(throws: (any Error).self) {try Fmt(heuristic: " ") }
        
        // garbage data
        #expect(throws: (any Error).self) {try Fmt(heuristic: "ABC") }
    }
    
    @Test
    func heuristic_Timecode() async throws {
        // -- subframes not enabled --
        // non-drop
        #expect(try Fmt(heuristic: "00:00:00:00") == .timecode)
        #expect(try Fmt(heuristic: "01:23:45:10") == .timecode)
        // drop-frame
        #expect(try Fmt(heuristic: "00:00:00;00") == .timecode)
        #expect(try Fmt(heuristic: "01:23:45;10") == .timecode)
        
        // -- subframes enabled --
        // non-drop
        #expect(try Fmt(heuristic: "00:00:00:00.00") == .timecode)
        #expect(try Fmt(heuristic: "01:23:45:10.23") == .timecode)
        // drop-frame
        #expect(try Fmt(heuristic: "00:00:00;00.00") == .timecode)
        #expect(try Fmt(heuristic: "01:23:45;10.23") == .timecode)
        
        // malformed
        #expect(throws: (any Error).self) { try Fmt(heuristic: ":::") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: ":::.") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0:00:00:00") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0:00:00:00.00") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "000:00:00:00") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "000:00:00:00.00") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0:00:00:00:00") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0:00:00:00:00.00") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "00:00:00:00.") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "00:00:00:00.0") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "00:00:00:00.000") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "AB:00:00:00") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "AB:00:00:00.00") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0.00.00.00") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "00.00.00.00") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "00.00.00.00.00") }
    }
    
    @Test
    func heuristic_MinSecs() async throws {
        // -- subframes not enabled -- (no milliseconds)
        #expect(try Fmt(heuristic: "0:00") == .minSecs)
        #expect(try Fmt(heuristic: "1:23") == .minSecs)
        #expect(try Fmt(heuristic: "123:23") == .minSecs)
        
        // -- subframes enabled -- (includes milliseconds)
        #expect(try Fmt(heuristic: "0:00.000") == .minSecs)
        #expect(try Fmt(heuristic: "1:23.456") == .minSecs)
        #expect(try Fmt(heuristic: "123:23.456") == .minSecs)
        
        // malformed
        #expect(throws: (any Error).self) { try Fmt(heuristic: ":") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: ":.") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0:0") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "00:0") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0:000") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "1:123") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "A:00") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "A0:00") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0:00A") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0.00") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0:00.0") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0:00.00") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0:00.0000") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0.00.0") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0.00.00") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0.00.0000") }
    }
    
    @Test
    func heuristic_Samples() async throws {
        #expect(try Fmt(heuristic: "0") == .samples)
        #expect(try Fmt(heuristic: "1") == .samples)
        #expect(try Fmt(heuristic: "123") == .samples)
        #expect(try Fmt(heuristic: "123456789") == .samples)
        
        // malformed
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0.0") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "1.2") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "-1") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "-1.2") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "A0") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0A") }
    }
    
    @Test
    func heuristic_BarsAndBeats() async throws {
        // -- subframes not enabled -- (no ticks)
        #expect(try Fmt(heuristic: "0|0") == .barsAndBeats)
        #expect(try Fmt(heuristic: "1|3") == .barsAndBeats)
        #expect(try Fmt(heuristic: "105|12") == .barsAndBeats)
        
        // -- subframes enabled -- (includes ticks)
        #expect(try Fmt(heuristic: "0|0| 000") == .barsAndBeats)
        #expect(try Fmt(heuristic: "1|3| 123") == .barsAndBeats)
        #expect(try Fmt(heuristic: "105|12| 123") == .barsAndBeats)
        
        // malformed
        #expect(throws: (any Error).self) { try Fmt(heuristic: "|0") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0|") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "||") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "|| ") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "|0|0") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "|0|") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "A0|0") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0|0A") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0|0 ") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0|0|0") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0|0|00") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0|0|000") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0|0|00000") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0|0| 0000") }
    }
    
    @Test
    func heuristic_FeetAndFrames() async throws {
        // -- subframes not enabled --
        #expect(try Fmt(heuristic: "0+00") == .feetAndFrames)
        #expect(try Fmt(heuristic: "1+00") == .feetAndFrames)
        #expect(try Fmt(heuristic: "10+09") == .feetAndFrames)
        
        // -- subframes enabled --
        #expect(try Fmt(heuristic: "0+00.00") == .feetAndFrames)
        #expect(try Fmt(heuristic: "1+00.23") == .feetAndFrames)
        #expect(try Fmt(heuristic: "10+09.23") == .feetAndFrames)
        
        // malformed
        #expect(throws: (any Error).self) { try Fmt(heuristic: "+") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "+.") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0+0") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "00+0") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0+000") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0+") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "+00") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "A0+00") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0+00A") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0+00.") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0+00.0") }
        #expect(throws: (any Error).self) { try Fmt(heuristic: "0+00.000") }
    }
}
