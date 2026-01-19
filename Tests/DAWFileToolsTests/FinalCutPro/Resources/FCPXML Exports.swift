//
//  FCPXML Exports.swift
//  swift-daw-file-tools • https://github.com/orchetect/swift-daw-file-tools
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import TestingExtensions

extension TestResource {
    private static let subFolder: String = "FCPXML Exports"
    
    enum FCPXMLExports {
        static let `23.98` = File(name: "23.98", ext: "fcpxml", subFolder: subFolder)
        static let `24` = File(name: "24", ext: "fcpxml", subFolder: subFolder)
        static let `24With25Media` = File(name: "24With25Media", ext: "fcpxml", subFolder: subFolder)
        static let `25i` = File(name: "25i", ext: "fcpxml", subFolder: subFolder)
        static let `29.97` = File(name: "29.97", ext: "fcpxml", subFolder: subFolder)
        static let `29.97d` = File(name: "29.97d", ext: "fcpxml", subFolder: subFolder)
        static let `30` = File(name: "30", ext: "fcpxml", subFolder: subFolder)
        static let `50` = File(name: "50", ext: "fcpxml", subFolder: subFolder)
        static let `59.94` = File(name: "59.94", ext: "fcpxml", subFolder: subFolder)
        static let `60` = File(name: "60", ext: "fcpxml", subFolder: subFolder)
        static let annotations = File(name: "Annotations", ext: "fcpxml", subFolder: subFolder)
        static let audioOnly = File(name: "AudioOnly", ext: "fcpxml", subFolder: subFolder)
        static let auditionMarkers = File(name: "AuditionMarkers", ext: "fcpxml", subFolder: subFolder)
        static let auditionMarkers2 = File(name: "AuditionMarkers2", ext: "fcpxml", subFolder: subFolder)
        static let auditionMarkers3 = File(name: "AuditionMarkers3", ext: "fcpxml", subFolder: subFolder)
        static let basicMarkers = File(name: "BasicMarkers", ext: "fcpxml", subFolder: subFolder)
        static let basicMarkers_1HourProjectStart = File(name: "BasicMarkers_1HourProjectStart", ext: "fcpxml", subFolder: subFolder)
        static let clipMetadata = File(name: "ClipMetadata", ext: "fcpxml", subFolder: subFolder)
        static let complex = File(name: "Complex", ext: "fcpxml", subFolder: subFolder)
        static let compoundClips = File(name: "CompoundClips", ext: "fcpxml", subFolder: subFolder)
        static let disabledClips = File(name: "DisabledClips", ext: "fcpxml", subFolder: subFolder)
        static let keywords = File(name: "Keywords", ext: "fcpxml", subFolder: subFolder)
        static let multicamMarkers = File(name: "MulticamMarkers", ext: "fcpxml", subFolder: subFolder)
        static let multicamMarkers2 = File(name: "MulticamMarkers2", ext: "fcpxml", subFolder: subFolder)
        static let occlusion = File(name: "Occlusion", ext: "fcpxml", subFolder: subFolder)
        static let occlusion2 = File(name: "Occlusion2", ext: "fcpxml", subFolder: subFolder)
        static let occlusion3 = File(name: "Occlusion3", ext: "fcpxml", subFolder: subFolder)
        static let rolesList = File(name: "RolesList", ext: "fcpxml", subFolder: subFolder)
        static let standaloneAssetClip = File(name: "StandaloneAssetClip", ext: "fcpxml", subFolder: subFolder)
        static let standaloneLibraryEventClip = File(name: "StandaloneLibraryEventClip", ext: "fcpxml", subFolder: subFolder)
        static let standaloneRefClip = File(name: "StandaloneRefClip", ext: "fcpxml", subFolder: subFolder)
        static let structure = File(name: "Structure", ext: "fcpxml", subFolder: subFolder)
        static let syncClip = File(name: "SyncClip", ext: "fcpxml", subFolder: subFolder)
        static let syncClipRoles = File(name: "SyncClipRoles", ext: "fcpxml", subFolder: subFolder)
        static let syncClipRoles2 = File(name: "SyncClipRoles2", ext: "fcpxml", subFolder: subFolder)
        static let titlesRoles = File(name: "TitlesRoles", ext: "fcpxml", subFolder: subFolder)
        static let transitionMarkers1 = File(name: "TransitionMarkers1", ext: "fcpxml", subFolder: subFolder)
        static let transitionMarkers2 = File(name: "TransitionMarkers2", ext: "fcpxml", subFolder: subFolder)
        static let twoClipsMarkers = File(name: "TwoClipsMarkers", ext: "fcpxml", subFolder: subFolder)
    }
}
