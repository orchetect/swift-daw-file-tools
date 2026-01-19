//
//  DAWMarker Codable Tests.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Foundation
import Testing
@testable import DAWFileTools
import SwiftTimecodeCore

@Suite struct DAWMarker_Codable_Tests {
    @Test
    func timeStorage_RealTime() async throws {
        let sfBase: Timecode.SubFramesBase = .max80SubFrames
        
        let marker = DAWMarker(
            storage: .init(
                value: .realTime(relativeToStart: 3600.0),
                frameRate: .fps23_976,
                base: sfBase
            ),
            name: "Marker 1",
            comment: nil
        )
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(marker)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DAWMarker.self, from: encoded)
        
        // check properties
        #expect(marker == decoded)
        #expect(marker.name == decoded.name)
        #expect(marker.comment == decoded.comment)
        #expect(marker.timeStorage == decoded.timeStorage)
        
        // check specific time storage value
        guard case let .realTime(relativeToStart: timeValue) = decoded.timeStorage?.value else {
            Issue.record()
            return
        }
        #expect(timeValue == 3600.0)
    }
    
    @Test
    func timeStorage_TimecodeString() async throws {
        let sfBase: Timecode.SubFramesBase = .max80SubFrames
        
        let marker = DAWMarker(
            storage: .init(
                value: .timecodeString(absolute: "00:00:05:17"),
                frameRate: .fps23_976,
                base: sfBase
            ),
            name: "Marker 1",
            comment: nil
        )
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(marker)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DAWMarker.self, from: encoded)
        
        // check properties
        #expect(marker == decoded)
        #expect(marker.name == decoded.name)
        #expect(marker.comment == decoded.comment)
        #expect(marker.timeStorage == decoded.timeStorage)
        
        // check specific time storage value
        guard case let .timecodeString(absolute: timecodeString) = decoded.timeStorage?.value else {
            Issue.record()
            return
        }
        #expect(timecodeString == "00:00:05:17")
    }
    
    @Test
    func timeStorage_Rational() async throws {
        let sfBase: Timecode.SubFramesBase = .max80SubFrames
        
        let marker = DAWMarker(
            storage: .init(
                value: .rational(relativeToStart: Fraction(3600, 1)),
                frameRate: .fps23_976,
                base: sfBase
            ),
            name: "Marker 1",
            comment: nil
        )
        
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(marker)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DAWMarker.self, from: encoded)
        
        // check properties
        #expect(marker == decoded)
        #expect(marker.name == decoded.name)
        #expect(marker.comment == decoded.comment)
        #expect(marker.timeStorage == decoded.timeStorage)
        
        // check specific time storage value
        guard case let .rational(relativeToStart: fraction) = decoded.timeStorage?.value else {
            Issue.record()
            return
        }
        #expect(fraction == Fraction(3600, 1))
    }
}
