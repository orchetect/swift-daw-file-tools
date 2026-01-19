//
//  FinalCutPro FCPXML MulticamMarkers.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS) // XMLNode only works on macOS

@testable import DAWFileTools
import SwiftExtensions
import SwiftTimecodeCore
import Testing
import TestingExtensions

@Suite struct FinalCutPro_FCPXML_MulticamMarkers: FCPXMLUtilities {
    // MARK: - Test Data
    
    var fileContents: Data { get throws {
        try TestResource.FCPXMLExports.multicamMarkers.data()
    } }
    
    // MARK: - Tests
    
    @Test
    func parse() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // resources
        // let resources = fcpxml.resources()
        
        // events
        let events = fcpxml.allEvents()
        #expect(events.count == 1)
        
        let event = try #require(events[safe: 0])
        #expect(event.name == "Test Event")
        #expect(event.element._fcpEffectiveOcclusion() == .notOccluded)
        
        // projects
        let projects = event.projects
        #expect(projects.count == 1)
        
        let project = try #require(projects[safe: 0])
        #expect(project.element._fcpEffectiveOcclusion() == .notOccluded)
        
        // sequence
        let sequence = project.sequence
        #expect(sequence.element._fcpEffectiveOcclusion() == .notOccluded)
        
        // spine
        let spine = sequence.spine
        
        let storyElements = spine.storyElements.zeroIndexed
        #expect(storyElements.count == 2)
        
        // mc-clip 1
        
        let mcClip1 = try #require(storyElements[safe: 0]?.fcpAsMCClip)
        #expect(mcClip1.ref == "r2")
        #expect(mcClip1.lane == nil)
        #expect(mcClip1.offsetAsTimecode() == Self.tc("01:00:00:00", .fps23_976))
        #expect(mcClip1.offsetAsTimecode()?.frameRate == .fps23_976)
        #expect(mcClip1.name == "MC")
        #expect(mcClip1.startAsTimecode() == Self.tc("00:00:10:01", .fps23_976))
        #expect(mcClip1.durationAsTimecode() == Self.tc("00:00:40:00", .fps23_976))
        #expect(mcClip1.durationAsTimecode()?.frameRate == .fps23_976)
        #expect(mcClip1.enabled)
        let extractedMCClip1 = await mcClip1.element.fcpExtract()
        #expect(extractedMCClip1.value(forContext: .absoluteStartAsTimecode()) == Self.tc("01:00:00:00", .fps23_976))
        #expect(extractedMCClip1.value(forContext: .occlusion) == .notOccluded)
        #expect(extractedMCClip1.value(forContext: .effectiveOcclusion) == .notOccluded)
        #expect(extractedMCClip1.value(forContext: .localRoles) == [
            FinalCutPro.FCPXML.defaultVideoRole,
            FinalCutPro.FCPXML.defaultAudioRole.lowercased(derivedOnly: true)
        ])
        #expect(extractedMCClip1.value(forContext: .inheritedRoles) == [
            .defaulted(FinalCutPro.FCPXML.defaultVideoRole),
            .inherited(FinalCutPro.FCPXML.defaultAudioRole.lowercased(derivedOnly: true))
        ])
        
        // mc-clip 1 multicam media (same media used for mc-clip 2)
        
        let mc = try #require(mcClip1.multicamResource)
        
        #expect(mc.format == "r1")
        #expect(mc.tcStartAsTimecode() == Self.tc("00:00:00:00", .fps23_976))
        #expect(mc.angles.count == 5)
        
        // multicam media angles
        
        let mcAngle1 = try #require(mc.angles[safe: 0])
        #expect(mcAngle1.name == "A")
        #expect(mcAngle1.angleID == "+L5xmXXnRXOGdjFq1Eo7EQ")
        #expect(mcAngle1.contents.count == 2)
        
        let mcAngle2 = try #require(mc.angles[safe: 1])
        #expect(mcAngle2.name == "B")
        #expect(mcAngle2.angleID == "FCw5EnkUQcOHu8fwK2TiQQ")
        #expect(mcAngle2.contents.count == 2)
        
        let mcAngle3 = try #require(mc.angles[safe: 2])
        #expect(mcAngle3.name == "C")
        #expect(mcAngle3.angleID == "LphqqelgRX6/pXqi35MoGA")
        #expect(mcAngle3.contents.count == 2)
        
        let mcAngle4 = try #require(mc.angles[safe: 3])
        #expect(mcAngle4.name == "D")
        #expect(mcAngle4.angleID == "gA31yYbYRRSetqQyxAwC8g")
        #expect(mcAngle4.contents.count == 2)
        
        let mcAngle5 = try #require(mc.angles[safe: 4])
        #expect(mcAngle5.name == "Music Angle")
        #expect(mcAngle5.angleID == "9jilYFZRQZ+GI27X4ckxpQ")
        #expect(mcAngle5.contents.count == 1)
        
        // mc-clip 1 marker on main timeline
        
        let mc1Markers = mcClip1.storyElements
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        #expect(mc1Markers.count == 1)
        
        let mc1Marker = try #require(mc1Markers[safe: 0])
        #expect(mc1Marker.name == "Marker on Multicam Clip 1")
        let extractedMC1Marker = await mc1Marker.element.fcpExtract()
        #expect(
            extractedMC1Marker.value(forContext: .absoluteStartAsTimecode())
                == Self.tc("01:00:01:09", .fps23_976)
        )
        #expect(extractedMC1Marker.value(forContext: .occlusion) == .notOccluded) // within mc-clip 1
        #expect(extractedMC1Marker.value(forContext: .effectiveOcclusion) == .notOccluded) // main timeline
        #expect(extractedMC1Marker.value(forContext: .localRoles) == []) // markers never contain roles
        #expect(extractedMC1Marker.value(forContext: .inheritedRoles) == [
            .defaulted(FinalCutPro.FCPXML.defaultVideoRole),
            .inherited(FinalCutPro.FCPXML.defaultAudioRole.lowercased(derivedOnly: true))
        ])
        
        // mc-clip 2
        
        let mcClip2 = try #require(storyElements[safe: 1]?.fcpAsMCClip)
        #expect(mcClip2.ref == "r2")
        #expect(mcClip2.lane == nil)
        #expect(mcClip2.offsetAsTimecode() == Self.tc("01:00:40:00", .fps23_976))
        #expect(mcClip2.offsetAsTimecode()?.frameRate == .fps23_976)
        #expect(mcClip2.name == "MC")
        #expect(mcClip2.startAsTimecode() == Self.tc("00:00:13:01", .fps23_976))
        #expect(mcClip2.durationAsTimecode() == Self.tc("00:00:10:00", .fps23_976))
        #expect(mcClip2.durationAsTimecode()?.frameRate == .fps23_976)
        #expect(mcClip2.enabled)
        let extractedMCClip2 = await mcClip2.element.fcpExtract()
        #expect(
            extractedMCClip2.value(forContext: .absoluteStartAsTimecode())
                == Self.tc("01:00:40:00", .fps23_976)
        )
        #expect(extractedMCClip2.value(forContext: .occlusion) == .notOccluded)
        #expect(extractedMCClip2.value(forContext: .effectiveOcclusion) == .notOccluded)
        #expect(extractedMCClip2.value(forContext: .localRoles) == [
            FinalCutPro.FCPXML.defaultVideoRole,
            FinalCutPro.FCPXML.defaultAudioRole.lowercased(derivedOnly: true)
        ])
        #expect(extractedMCClip2.value(forContext: .inheritedRoles) == [
            .defaulted(FinalCutPro.FCPXML.defaultVideoRole),
            .inherited(FinalCutPro.FCPXML.defaultAudioRole.lowercased(derivedOnly: true))
        ])
        
        // mc-clip 2 marker on main timeline
        
        let mc2Markers = mcClip2.storyElements
            .filter(whereFCPElement: .marker)
            .zeroIndexed
        #expect(mc2Markers.count == 1)
        
        let mc2Marker = try #require(mc2Markers[safe: 0])
        #expect(mc2Marker.name == "Marker on Multicam Clip 2")
        let extractedMC2Marker = await mc2Marker.element.fcpExtract()
        #expect(
            extractedMC2Marker.value(forContext: .absoluteStartAsTimecode())
                == Self.tc("01:00:44:08", .fps23_976)
        )
        #expect(extractedMC2Marker.value(forContext: .occlusion) == .notOccluded) // within mc-clip 2
        #expect(extractedMC2Marker.value(forContext: .effectiveOcclusion) == .notOccluded) // main timeline
        #expect(extractedMC2Marker.value(forContext: .localRoles) == []) // markers never contain roles
        #expect(extractedMC2Marker.value(forContext: .inheritedRoles) == [
            .defaulted(FinalCutPro.FCPXML.defaultVideoRole),
            .inherited(FinalCutPro.FCPXML.defaultAudioRole.lowercased(derivedOnly: true))
        ])
    }
    
    /// Test main timeline markers extraction with limited occlusion conditions.
    @Test
    func extractMarkers_MainTimeline_LimitedOcclusions() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = await event.extract(preset: .markers, scope: .mainTimeline)
        #expect(extractedMarkers.count == 2)
        
        #expect(
            extractedMarkers.map(\.name)
                == ["Marker on Multicam Clip 1", "Marker on Multicam Clip 2"]
        )
    }
    
    /// Test main timeline markers extraction with all occlusion conditions and active MC angles.
    @Test
    func extractMarkers_MainTimeline_AllOcclusions_ActiveAngles() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        var scope = FinalCutPro.FCPXML.ExtractionScope.mainTimeline
        scope.mcClipAngles = .active
        scope.occlusions = .allCases
        let extractedMarkers = await event.extract(preset: .markers, scope: scope)
        #expect(extractedMarkers.count == 2)
        
        #expect(
            extractedMarkers.map(\.name)
                == ["Marker on Multicam Clip 1", "Marker on Multicam Clip 2"]
        )
    }
    
    /// Test main timeline markers extraction with all occlusion conditions and all MC angles.
    /// NOTE: The auditions rule and the mcClipAngles rule have slightly different effects
    /// since audition clips are peer elements, but mc-clip angles are nested elements.
    /// This means that applying the `mainTimeline` extraction scope prevents any angles
    /// from being extracted.
    @Test
    func extractMarkers_MainTimeline_AllOcclusions_AllAngles() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        var scope = FinalCutPro.FCPXML.ExtractionScope.mainTimeline
        scope.mcClipAngles = .all
        scope.occlusions = .allCases
        let extractedMarkers = await event.extract(preset: .markers, scope: scope)
        #expect(extractedMarkers.count == 2)
        
        #expect(
            extractedMarkers.map(\.name)
                == ["Marker on Multicam Clip 1", "Marker on Multicam Clip 2"]
        )
    }
    
    /// Test deep markers extraction with all occlusion conditions with active MC angles.
    @Test
    func extractMarkers_Deep_AllOcclusions_ActiveAngles() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = await event.extract(
            preset: .markers,
            scope: .deep(mcClipAngles: .active)
        )
        // 1 on each mc-clip, and 5 within each mc-clip
        #expect(extractedMarkers.count == 4)
        
        // note these are not sorted chronologically; they're in parsing order
        #expect(extractedMarkers.map(\.name) == [
            "Marker on Multicam Clip 1", // on mc-clip 1
            "Marker in Multicam Clip on Angle D", // within mc-clip 1
            "Marker on Multicam Clip 2", // on mc-clip 2
            "Marker in Multicam Clip on Angle B", // within mc-clip 2
        ])
    }
    
    /// Test deep markers extraction with all occlusion conditions and all MC angles.
    @Test
    func extractMarkers_Deep_AllOcclusions_AllAngles() async throws {
        // load file
        let rawData = try fileContents
        
        // parse file
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // event
        let event = try #require(fcpxml.allEvents().first)
        
        // extract markers
        let extractedMarkers = await event.extract(
            preset: .markers,
            scope: .deep(mcClipAngles: .all)
        )
        #expect(extractedMarkers.count == 2 + (2 * 5))
        
        #expect(
            extractedMarkers.map(\.name) == [
                "Marker on Multicam Clip 1", // on mc-clip 1
                "Marker in Multicam Clip on Angle A", // within mc-clip 1
                "Marker in Multicam Clip on Angle B", // within mc-clip 1
                "Marker in Multicam Clip on Angle C", // within mc-clip 1
                "Marker in Multicam Clip on Angle D", // within mc-clip 1
                "Marker in Multicam Clip on Music Angle", // within mc-clip 1
                "Marker on Multicam Clip 2", // on mc-clip 2
                "Marker in Multicam Clip on Angle A", // within mc-clip 2
                "Marker in Multicam Clip on Angle B", // within mc-clip 2
                "Marker in Multicam Clip on Angle C", // within mc-clip 2
                "Marker in Multicam Clip on Angle D", // within mc-clip 2
                "Marker in Multicam Clip on Music Angle" // within mc-clip 2
            ]
        )
    }
    
    /// Test metadata that applies to marker(s).
    @Test
    func extractMarkersMetadata_MainTimeline() async throws {
        // load file
        let rawData = try fileContents
        
        // load
        let fcpxml = try FinalCutPro.FCPXML(fileContent: rawData)
        
        // project
        let project = try #require(fcpxml.allProjects().first)
        
        let extractedMarkers = await project
            .extract(preset: .markers, scope: .mainTimeline)
            .sortedByAbsoluteStartTimecode()
        // .zeroIndexed // not necessary after sorting - sort returns new array
        
        let markers = extractedMarkers
        
        let expectedMarkerCount = 2
        #expect(markers.count == expectedMarkerCount)
        
        print("Markers sorted by absolute timecode:")
        print(Self.debugString(for: markers))
        
        // markers
        
        func md(
            in mdtm: [FinalCutPro.FCPXML.Metadata.Metadatum],
            key: FinalCutPro.FCPXML.Metadata.Key
        ) -> FinalCutPro.FCPXML.Metadata.Metadatum? {
            let matches = mdtm.filter { $0.key == key }
            #expect(matches.count < 2)
            return matches.first
        }
        
        // marker 1
        do {
            let marker = try #require(markers[safe: 0])
            let mtdm = marker.value(forContext: .metadata)
            #expect(mtdm.count == 9)
            
            // metadata from media
            #expect(md(in: mtdm, key: .cameraName)?.value == "Cam 4 Camera Name")
            #expect(md(in: mtdm, key: .rawToLogConversion)?.value == "0")
            #expect(md(in: mtdm, key: .colorProfile)?.value == nil)
            #expect(md(in: mtdm, key: .cameraISO)?.value == "0")
            #expect(md(in: mtdm, key: .cameraColorTemperature)?.value == "0")
            #expect(md(in: mtdm, key: .codecs)?.valueArray == nil)
            #expect(md(in: mtdm, key: .ingestDate)?.value == "2022-09-13 17:57:24 -0700")
            // metadata from clip
            #expect(md(in: mtdm, key: .reel)?.value == "Cam 4 Reel")
            #expect(md(in: mtdm, key: .scene)?.value == "Cam 4 Scene")
            #expect(md(in: mtdm, key: .take)?.value == "Cam 4 Take")
            #expect(md(in: mtdm, key: .cameraAngle)?.value == "D")
        }
        
        // marker 2
        do {
            let marker = try #require(markers[safe: 1])
            let mtdm = marker.value(forContext: .metadata)
            #expect(mtdm.count == 9)
            
            // metadata from media
            #expect(md(in: mtdm, key: .cameraName)?.value == "Cam 2 Camera Name")
            #expect(md(in: mtdm, key: .rawToLogConversion)?.value == "0")
            #expect(md(in: mtdm, key: .colorProfile)?.value == nil)
            #expect(md(in: mtdm, key: .cameraISO)?.value == "0")
            #expect(md(in: mtdm, key: .cameraColorTemperature)?.value == "0")
            #expect(md(in: mtdm, key: .codecs)?.valueArray == nil)
            #expect(md(in: mtdm, key: .ingestDate)?.value == "2022-09-13 17:57:22 -0700")
            // metadata from clip
            #expect(md(in: mtdm, key: .reel)?.value == "Cam 2 Reel")
            #expect(md(in: mtdm, key: .scene)?.value == "Cam 2 Scene")
            #expect(md(in: mtdm, key: .take)?.value == "Cam 2 Take")
            #expect(md(in: mtdm, key: .cameraAngle)?.value == "B")
        }
    }
}

#endif
