//
//  TimeValue Tests.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing

@Suite struct ProTools_TimeValueTests {
    typealias PTSI = ProTools.SessionInfo
    
    @Test
    func formTimeValue_Timecode() async throws {
        // empty
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(timecodeString: "", at: .fps30) }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(timecodeString: " ", at: .fps30) }
        
        // -- subframes not enabled --
        // non-drop
        #expect(
            try PTSI.formTimeValue(timecodeString: "00:00:00:00", at: .fps30)
                == .timecode(try Timecode(.string("00:00:00:00"), at: .fps30))
        )
        #expect(
            try PTSI.formTimeValue(timecodeString: "01:23:45:10", at: .fps30)
                == .timecode(try Timecode(.string("01:23:45:10"), at: .fps30))
        )
        // drop-frame
        #expect(
            try PTSI.formTimeValue(timecodeString: "00:00:00;00", at: .fps29_97d)
                == .timecode(try Timecode(.string("00:00:00;00"), at: .fps29_97d))
        )
        #expect(
            try PTSI.formTimeValue(timecodeString: "01:23:45;10", at: .fps29_97d)
                == .timecode(try Timecode(.string("01:23:45;10"), at: .fps29_97d))
        )
        
        // -- subframes enabled --
        // non-drop
        #expect(
            try PTSI.formTimeValue(timecodeString: "00:00:00:00.00", at: .fps30)
                == .timecode(try Timecode(.string("00:00:00:00.00"), at: .fps30))
        )
        #expect(
            try PTSI.formTimeValue(timecodeString: "01:23:45:10.23", at: .fps30)
                == .timecode(try Timecode(.string("01:23:45:10.23"), at: .fps30))
        )
        // drop-frame
        #expect(
            try PTSI.formTimeValue(timecodeString: "00:00:00;00.00", at: .fps29_97d)
                == .timecode(try Timecode(.string("00:00:00;00.00"), at: .fps29_97d))
        )
        #expect(
            try PTSI.formTimeValue(timecodeString: "01:23:45;10.23", at: .fps29_97d)
                == .timecode(try Timecode(.string("01:23:45;10.23"), at: .fps29_97d))
        )
         
        // malformed
        // * - the non-throwing lines below are valid in swift-timecode but are not valid
        //     in a Pro Tools session info text file, however this is not an error condition
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(timecodeString: ":::", at: .fps30) }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(timecodeString: ":::.", at: .fps30) }
        #expect(throws: Never.self) { try PTSI.formTimeValue(timecodeString: "0:00:00:00", at: .fps30) } // *
        #expect(throws: Never.self) { try PTSI.formTimeValue(timecodeString: "0:00:00:00.00", at: .fps30) } // *
        #expect(throws: Never.self) { try PTSI.formTimeValue(timecodeString: "000:00:00:00", at: .fps30) } // *
        #expect(throws: Never.self) { try PTSI.formTimeValue(timecodeString: "000:00:00:00.00", at: .fps30) } // *
        #expect(throws: Never.self) { try PTSI.formTimeValue(timecodeString: "0:00:00:00:00", at: .fps30) } // *
        #expect(throws: Never.self) { try PTSI.formTimeValue(timecodeString: "0:00:00:00:00.00", at: .fps30) } // *
        #expect(throws: Never.self) { try PTSI.formTimeValue(timecodeString: "00:00:00:00.", at: .fps30) } // *
        #expect(throws: Never.self) { try PTSI.formTimeValue(timecodeString: "00:00:00:00.0", at: .fps30) } // *
        #expect(throws: Never.self) { try PTSI.formTimeValue(timecodeString: "00:00:00:00.000", at: .fps30) } // *
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(timecodeString: "AB:00:00:00", at: .fps30) }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(timecodeString: "AB:00:00:00.00", at: .fps30) }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(timecodeString: "0.00.00.00", at: .fps30) }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(timecodeString: "00.00.00.00", at: .fps30) }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(timecodeString: "00.00.00.00.00", at: .fps30) }
    }
    
    @Test
    func formTimeValue_MinSecs() async throws {
        // empty
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(minSecsString: "") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(minSecsString: " ") }
        
        // -- subframes not enabled -- (no milliseconds)
        #expect(
            try PTSI.formTimeValue(minSecsString: "0:00")
                == .minSecs(min: 0, sec: 0, ms: nil)
        )
        #expect(
            try PTSI.formTimeValue(minSecsString: "1:23")
                == .minSecs(min: 1, sec: 23, ms: nil)
        )
        #expect(
            try PTSI.formTimeValue(minSecsString: "123:23")
                == .minSecs(min: 123, sec: 23, ms: nil)
        )
        
        // -- subframes enabled -- (includes milliseconds)
        #expect(
            try PTSI.formTimeValue(minSecsString: "0:00.000")
                == .minSecs(min: 0, sec: 0, ms: 0)
        )
        #expect(
            try PTSI.formTimeValue(minSecsString: "1:23.456")
                == .minSecs(min: 1, sec: 23, ms: 456)
        )
        #expect(
            try PTSI.formTimeValue(minSecsString: "123:23.456")
                == .minSecs(min: 123, sec: 23, ms: 456)
        )
        
        // malformed
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(minSecsString: ":") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(minSecsString: ":.") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(minSecsString: "0:0") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(minSecsString: "00:0") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(minSecsString: "0:000") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(minSecsString: "1:123") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(minSecsString: "A:00") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(minSecsString: "A0:00") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(minSecsString: "0:00A") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(minSecsString: "0.00") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(minSecsString: "0:00.0") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(minSecsString: "0:00.00") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(minSecsString: "0:00.0000") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(minSecsString: "0.00.0") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(minSecsString: "0.00.00") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(minSecsString: "0.00.0000") }
    }
    
    @Test
    func formTimeValue_Samples() async throws {
        // empty
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(samplesString: "") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(samplesString: " ") }
        
        #expect(
            try PTSI.formTimeValue(samplesString: "0")
                == .samples(0)
        )
        #expect(
            try PTSI.formTimeValue(samplesString: "1")
                == .samples(1)
        )
        #expect(
            try PTSI.formTimeValue(samplesString: "123")
                == .samples(123)
        )
        #expect(
            try PTSI.formTimeValue(samplesString: "123456789")
                == .samples(123_456_789)
        )
        
        // malformed
        // * - the non-throwing lines below are possible because
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(samplesString: "0.0") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(samplesString: "1.2") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(samplesString: "-1") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(samplesString: "-1.2") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(samplesString: "A0") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(samplesString: "0A") }
    }
    
    @Test
    func formTimeValue_BarsAndBeats() async throws {
        // empty
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(barsAndBeatsString: "") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(barsAndBeatsString: " ") }
        
        // -- subframes not enabled -- (no ticks)
        #expect(
            try PTSI.formTimeValue(barsAndBeatsString: "0|0")
                == .barsAndBeats(bar: 0, beat: 0, ticks: nil)
        )
        #expect(
            try PTSI.formTimeValue(barsAndBeatsString: "1|3")
                == .barsAndBeats(bar: 1, beat: 3, ticks: nil)
        )
        #expect(
            try PTSI.formTimeValue(barsAndBeatsString: "105|12")
                == .barsAndBeats(bar: 105, beat: 12, ticks: nil)
        )
        
        // -- subframes enabled -- (includes ticks)
        #expect(
            try PTSI.formTimeValue(barsAndBeatsString: "0|0| 000")
                == .barsAndBeats(bar: 0, beat: 0, ticks: 0)
        )
        #expect(
            try PTSI.formTimeValue(barsAndBeatsString: "1|3| 123")
                == .barsAndBeats(bar: 1, beat: 3, ticks: 123)
        )
        #expect(
            try PTSI.formTimeValue(barsAndBeatsString: "105|12| 123")
                == .barsAndBeats(bar: 105, beat: 12, ticks: 123)
        )
        
        // malformed
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(barsAndBeatsString: "|0") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(barsAndBeatsString: "0|") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(barsAndBeatsString: "||") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(barsAndBeatsString: "|| ") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(barsAndBeatsString: "|0|0") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(barsAndBeatsString: "|0|") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(barsAndBeatsString: "A0|0") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(barsAndBeatsString: "0|0A") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(barsAndBeatsString: "0|0 ") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(barsAndBeatsString: "0|0|0") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(barsAndBeatsString: "0|0|00") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(barsAndBeatsString: "0|0|000") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(barsAndBeatsString: "0|0|00000") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(barsAndBeatsString: "0|0| 0000") }
    }
    
    @Test
    func formTimeValue_FeetAndFrames() async throws {
        // empty
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(feetAndFramesString: "") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(feetAndFramesString: " ") }
        
        // -- subframes not enabled --
        #expect(
            try PTSI.formTimeValue(feetAndFramesString: "0+00")
                == .feetAndFrames(feet: 0, frames: 0, subFrames: nil)
        )
        #expect(
            try PTSI.formTimeValue(feetAndFramesString: "1+00")
                == .feetAndFrames(feet: 1, frames: 0, subFrames: nil)
        )
        #expect(
            try PTSI.formTimeValue(feetAndFramesString: "10+09")
                == .feetAndFrames(feet: 10, frames: 9, subFrames: nil)
        )
        
        // -- subframes enabled --
        #expect(
            try PTSI.formTimeValue(feetAndFramesString: "0+00.00")
                == .feetAndFrames(feet: 0, frames: 0, subFrames: 0)
        )
        #expect(
            try PTSI.formTimeValue(feetAndFramesString: "1+00.23")
                == .feetAndFrames(feet: 1, frames: 0, subFrames: 23)
        )
        #expect(
            try PTSI.formTimeValue(feetAndFramesString: "10+09.23")
                == .feetAndFrames(feet: 10, frames: 9, subFrames: 23)
        )
        
        // malformed
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(feetAndFramesString: "+") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(feetAndFramesString: "+.") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(feetAndFramesString: "0+0") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(feetAndFramesString: "00+0") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(feetAndFramesString: "0+000") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(feetAndFramesString: "0+") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(feetAndFramesString: "+00") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(feetAndFramesString: "A0+00") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(feetAndFramesString: "0+00A") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(feetAndFramesString: "0+00.") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(feetAndFramesString: "0+00.0") }
        #expect(throws: (any Error).self) { try PTSI.formTimeValue(feetAndFramesString: "0+00.000") }
    }
}
