//
//  DAWMarker Conversions Tests.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

@testable import DAWFileTools
import SwiftTimecodeCore
import Testing

@Suite struct DAWMarker_Conversions_Tests {
    /// Same frame rate.
    @Test
    func resolvedTimecodeA() async throws {
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
        
        let resolved = try #require(marker.resolvedTimecode(
            at: .fps23_976,
            base: sfBase,
            limit: .max24Hours,
            startTimecode: Timecode(.zero, at: .fps23_976, base: sfBase)
        ))
        
        #expect(resolved.frameRate == .fps23_976)
        #expect(resolved.upperLimit == .max24Hours)
        #expect(resolved.components == .init(d: 0, h: 0, m: 0, s: 5, f: 17, sf: 0))
    }
    
    /// Same frame rate.
    @Test
    func resolvedTimecodeB() async throws {
        let sfBase: Timecode.SubFramesBase = .max80SubFrames
        
        let marker = DAWMarker(
            storage: .init(
                value: .timecodeString(absolute: "00:00:09:09"),
                frameRate: .fps23_976,
                base: sfBase
            ),
            name: "Marker 1",
            comment: nil
        )
        
        let resolved = try #require(marker.resolvedTimecode(
            at: .fps23_976,
            base: sfBase,
            limit: .max24Hours,
            startTimecode: Timecode(.zero, at: .fps23_976, base: sfBase)
        ))
        
        #expect(resolved.frameRate == .fps23_976)
        #expect(resolved.upperLimit == .max24Hours)
        #expect(resolved.components == .init(d: 0, h: 0, m: 0, s: 9, f: 9, sf: 0))
    }
    
    /// Different frame rate.
    @Test
    func resolvedTimecodeC() async throws {
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
        
        let resolved = try #require(marker.resolvedTimecode(
            at: .fps30,
            base: sfBase,
            limit: .max24Hours,
            startTimecode: Timecode(.zero, at: .fps30, base: sfBase)
        ))
        
        #expect(resolved.frameRate == .fps30)
        #expect(resolved.upperLimit == .max24Hours)
        #expect(resolved.components == .init(d: 0, h: 0, m: 0, s: 5, f: 21, sf: 33))
    }
    
    // MARK: - Rational Fraction
    
    @Test
    func originalTimecode_Fraction() async throws {
        let sfBase: Timecode.SubFramesBase = .max80SubFrames
        
        let marker = DAWMarker(
            storage: .init(
                value: .rational(relativeToStart: Fraction(3600, 1)),
                frameRate: .fps24,
                base: sfBase
            ),
            name: "Marker 1",
            comment: nil
        )
        
        let original = try #require(marker.originalTimecode(base: sfBase, limit: .max100Days))
        #expect(original.frameRate == .fps24)
        #expect(original.upperLimit == .max100Days)
        #expect(original.components == .init(d: 0, h: 1, m: 0, s: 0, f: 0, sf: 0))
    }
    
    @Test
    func resolvedTimecode_Fraction() async throws {
        let sfBase: Timecode.SubFramesBase = .max80SubFrames
        
        let marker = DAWMarker(
            storage: .init(
                value: .rational(relativeToStart: Fraction(3600, 1)),
                frameRate: .fps24,
                base: sfBase
            ),
            name: "Marker 1",
            comment: nil
        )
        
        let resolved = try #require(
            marker.resolvedTimecode(
                at: .fps29_97, 
                base: sfBase,
                limit: .max24Hours,
                startTimecode: Timecode(.zero, at: .fps29_97, base: sfBase)
            )
        )
        #expect(resolved.frameRate == .fps29_97)
        #expect(resolved.upperLimit == .max24Hours)
        #expect(resolved.components == .init(d: 0, h: 0, m: 59, s: 56, f: 12, sf: 08)) // confirmed in Pro Tools
    }
}
