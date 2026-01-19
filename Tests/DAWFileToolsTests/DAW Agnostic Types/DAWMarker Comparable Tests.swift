//
//  DAWMarker Comparable Tests.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Testing
@testable import DAWFileTools
import SwiftTimecodeCore

@Suite struct DAWMarker_Comparable_Tests {
    /// For comparison with the context of a timeline that is != `00:00:00:00`.
    @Test
    func compareTo() async throws {
        let frameRate: TimecodeFrameRate = .fps24
        
        func dawMarker(_ string: String) -> DAWMarker {
            DAWMarker(
                storage: .init(
                    value: .timecodeString(absolute: string),
                    frameRate: frameRate,
                    base: .max80SubFrames
                ),
                name: "Name",
                comment: nil
            )
        }
        
        func tc(_ string: String) throws -> Timecode {
            try Timecode(.string(string), at: frameRate)
        }
        
        // orderedSame (==)
        
        #expect(
            try dawMarker("00:00:00:00")
                .compare(to: dawMarker("00:00:00:00"), timelineStart: tc("00:00:00:00"))
            == .orderedSame
        )
        
        #expect(
            try dawMarker("00:00:00:00")
                .compare(to: dawMarker("00:00:00:00"), timelineStart: tc("01:00:00:00"))
            == .orderedSame
        )
        
        #expect(
            try dawMarker("00:00:00:00.01")
                .compare(to: dawMarker("00:00:00:00.01"), timelineStart: tc("00:00:00:00"))
            == .orderedSame
        )
        
        #expect(
            try dawMarker("01:00:00:00")
                .compare(to: dawMarker("01:00:00:00"), timelineStart: tc("00:00:00:00"))
            == .orderedSame
        )
        
        #expect(
            try dawMarker("01:00:00:00")
                .compare(to: dawMarker("01:00:00:00"), timelineStart: tc("01:00:00:00"))
            == .orderedSame
        )
        
        #expect(
            try dawMarker("01:00:00:00")
                .compare(to: dawMarker("01:00:00:00"), timelineStart: tc("02:00:00:00"))
            == .orderedSame
        )
        
        // orderedAscending (<)
        
        #expect(
            try dawMarker("00:00:00:00")
                .compare(to: dawMarker("00:00:00:00.01"), timelineStart: tc("00:00:00:00"))
            == .orderedAscending
        )
        
        #expect(
            try dawMarker("00:00:00:00")
                .compare(to: dawMarker("00:00:00:01"), timelineStart: tc("00:00:00:00"))
            == .orderedAscending
        )
        
        #expect(
            try dawMarker("00:00:00:00")
                .compare(to: dawMarker("00:00:00:01"), timelineStart: tc("01:00:00:00"))
            == .orderedAscending
        )
        
        #expect(
            try dawMarker("23:00:00:00")
                .compare(to: dawMarker("00:00:00:00"), timelineStart: tc("23:00:00:00"))
            == .orderedAscending
        )
        
        #expect(
            try dawMarker("23:30:00:00")
                .compare(to: dawMarker("00:00:00:00"), timelineStart: tc("23:00:00:00"))
            == .orderedAscending
        )
        
        #expect(
            try dawMarker("23:30:00:00")
                .compare(to: dawMarker("01:00:00:00"), timelineStart: tc("23:00:00:00"))
            == .orderedAscending
        )
        
        // orderedDescending (>)
        
        #expect(
            try tc("00:00:00:00.01")
                .compare(to: tc("00:00:00:00"), timelineStart: tc("00:00:00:00"))
            == .orderedDescending
        )
        
        #expect(
            try dawMarker("00:00:00:01")
                .compare(to: dawMarker("00:00:00:00"), timelineStart: tc("00:00:00:00"))
            == .orderedDescending
        )
        
        #expect(
            try dawMarker("23:30:00:00")
                .compare(to: dawMarker("00:00:00:00"), timelineStart: tc("00:00:00:00"))
            == .orderedDescending
        )
        
        #expect(
            try dawMarker("00:00:00:00")
                .compare(to: dawMarker("23:30:00:00"), timelineStart: tc("23:00:00:00"))
            == .orderedDescending
        )
    }
    
    @Test
    func collection_isSorted() async throws {
        let frameRate: TimecodeFrameRate = .fps24
        
        func dawMarker(_ string: String) -> DAWMarker {
            DAWMarker(
                storage: .init(
                    value: .timecodeString(absolute: string),
                    frameRate: frameRate,
                    base: .max80SubFrames
                ),
                name: "Name",
                comment: nil
            )
        }
        
        func tc(_ string: String) throws -> Timecode {
            try Timecode(.string(string), at: frameRate)
        }
        
        #expect(
            [
                dawMarker("00:00:00:00"),
                dawMarker("00:00:00:01"),
                dawMarker("00:00:00:14"),
                dawMarker("00:00:00:15"),
                dawMarker("00:00:00:15"), // sequential dupe
                dawMarker("00:00:01:00"),
                dawMarker("00:00:01:01"),
                dawMarker("00:00:01:23"),
                dawMarker("00:00:02:00"),
                dawMarker("00:01:00:05"),
                dawMarker("00:02:00:08"),
                dawMarker("00:23:00:10"),
                dawMarker("01:00:00:00"),
                dawMarker("02:00:00:00"),
                dawMarker("03:00:00:00")
            ]
            .isSorted() // timelineStart of zero
            == true
        )
        
        #expect(
            [
                dawMarker("00:00:00:00"),
                dawMarker("00:00:00:01"),
                dawMarker("00:00:00:14"),
                dawMarker("00:00:00:15"),
                dawMarker("00:00:00:15"), // sequential dupe
                dawMarker("00:00:01:00"),
                dawMarker("00:00:01:01"),
                dawMarker("00:00:01:23"),
                dawMarker("00:00:02:00"),
                dawMarker("00:01:00:05"),
                dawMarker("00:02:00:08"),
                dawMarker("00:23:00:10"),
                dawMarker("01:00:00:00"),
                dawMarker("02:00:00:00"),
                dawMarker("03:00:00:00")
            ]
            .isSorted(timelineStart: try tc("01:00:00:00"))
            == false
        )
        
        #expect(
            [
                dawMarker("01:00:00:00"),
                dawMarker("02:00:00:00"),
                dawMarker("03:00:00:00"),
                dawMarker("00:00:00:00"),
                dawMarker("00:00:00:01"),
                dawMarker("00:00:00:14"),
                dawMarker("00:00:00:15"),
                dawMarker("00:00:00:15"), // sequential dupe
                dawMarker("00:00:01:00"),
                dawMarker("00:00:01:01"),
                dawMarker("00:00:01:23"),
                dawMarker("00:00:02:00"),
                dawMarker("00:01:00:05"),
                dawMarker("00:02:00:08"),
                dawMarker("00:23:00:10"),
                dawMarker("00:59:59:23") // 1 frame before wrap around
            ]
            .isSorted(timelineStart: try tc("01:00:00:00"))
            == true
        )
        
        #expect(
            [
                dawMarker("01:00:00:00"),
                dawMarker("02:00:00:00"),
                dawMarker("03:00:00:00"),
                dawMarker("00:00:00:00"),
                dawMarker("00:00:00:01"),
                dawMarker("00:00:00:14"),
                dawMarker("00:00:00:15"),
                dawMarker("00:00:00:15"), // sequential dupe
                dawMarker("00:00:01:00"),
                dawMarker("00:00:01:01"),
                dawMarker("00:00:01:23"),
                dawMarker("00:00:02:00"),
                dawMarker("00:01:00:05"),
                dawMarker("00:02:00:08"),
                dawMarker("00:23:00:10"),
                dawMarker("00:59:59:23") // 1 frame before wrap around
            ]
            .isSorted(ascending: false, timelineStart: try tc("01:00:00:00"))
            == false
        )
        
        #expect(
            [
                dawMarker("00:59:59:23"), // 1 frame before wrap around
                dawMarker("00:23:00:10"),
                dawMarker("00:02:00:08"),
                dawMarker("00:01:00:05"),
                dawMarker("00:00:02:00"),
                dawMarker("00:00:01:23"),
                dawMarker("00:00:01:01"),
                dawMarker("00:00:01:00"),
                dawMarker("00:00:00:15"),
                dawMarker("00:00:00:15"), // sequential dupe
                dawMarker("00:00:00:14"),
                dawMarker("00:00:00:01"),
                dawMarker("00:00:00:00"),
                dawMarker("03:00:00:00"),
                dawMarker("02:00:00:00"),
                dawMarker("01:00:00:00")
            ]
            .isSorted(ascending: false, timelineStart: try tc("01:00:00:00"))
            == true
        )
    }
}
