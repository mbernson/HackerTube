//
//  Examples.swift
//  MediaCCCApi
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import Foundation

// swiftlint:disable force_try

extension Conference {
    public static let example = Conference(
        acronym: "MCH2022",
        slug: "conferences/camp-NL/mch2022",
        title: "May Contain Hackers 2022",
        updatedAt: try! Date("2022-07-29T20:45:05Z", strategy: .iso8601),
        eventLastReleasedAt: try! Date("2022-07-26T00:00:00Z", strategy: .iso8601),
        link: URL(string: "https://mch2022.org/")!,
        description:
            "MCH2022 was a nonprofit outdoor hacker camp taking place in Zeewolde, the Netherlands, July 22 to 26 2022. The event is organized for and by volunteers from and around all facets of the worldwide hacker community.\r\n\r\nKnowledge sharing, technological advancement, experimentation, connecting with your hacker peers and hacking are some of the core values of this event.\r\n\r\nMCH2022 is the successor of a string of similar events happening every four years since 1989. These are GHP, HEU, HIP, HAL, WTH, HAR, OHM and SHA.",
        aspectRatio: AspectRatio(width: 16, height: 9),
        webgenLocation: "conferences/camp-NL/mch2022",
        url: URL(string: "https://static.media.ccc.de/media/events/MCH2022/logo.png")!,
        logoURL: URL(string: "https://api.media.ccc.de/public/conferences/MCH2022")!,
        imagesURL: nil,
        recordingsURL: nil
    )
}

extension Talk {
    public static let example = Talk(
        guid: "cf4dc17c-aab4-5868-9b57-100a55a1c2fb",
        title: "⚠️ May Contain Hackers 2022 Closing",
        subtitle: nil,
        slug: "mch2022-110--may-contain-hackers-2022-closing",
        link: URL(string: "https://program.mch2022.org/mch2022/talk/DZAUQA/")!,
        description: "It's over before you know it...",
        originalLanguage: "eng",
        persons: [
            "Elger \"Stitch\" Jonker"
        ],
        tags: [
            "mch2022",
            "110",
            "2022",
            "MCH2022 Curated content",
        ],
        viewCount: 255,
        isPromoted: false,
        date: try! Date("2022-07-26T16:00:00Z", strategy: .iso8601),
        releaseDate: try! Date("2022-07-26T00:00:00Z", strategy: .iso8601),
        updatedAt: try! Date("2022-07-29T17:15:05Z", strategy: .iso8601),
        duration: 1066,
        conferenceTitle: "May Contain Hackers 2022",
        conferenceURL: URL(string: "https://api.media.ccc.de/public/conferences/MCH2022")!,
        thumbURL: URL(
            string:
                "https://static.media.ccc.de/media/events/MCH2022/110-cf4dc17c-aab4-5868-9b57-100a55a1c2fb.jpg"
        )!,
        posterURL: URL(
            string:
                "https://static.media.ccc.de/media/events/MCH2022/110-cf4dc17c-aab4-5868-9b57-100a55a1c2fb_preview.jpg"
        )!,
        timelineURL: URL(
            string:
                "https://static.media.ccc.de/media/events/MCH2022/110-cf4dc17c-aab4-5868-9b57-100a55a1c2fb.timeline.jpg"
        )!,
        thumbnailsURL: URL(
            string:
                "https://static.media.ccc.de/media/events/MCH2022/110-cf4dc17c-aab4-5868-9b57-100a55a1c2fb.thumbnails.vtt"
        )!,
        frontendLink: URL(
            string: "https://media.ccc.de/v/mch2022-110--may-contain-hackers-2022-closing")!,
        url: URL(
            string: "https://api.media.ccc.de/public/events/cf4dc17c-aab4-5868-9b57-100a55a1c2fb")!,
        related: []
    )
}

extension Recording {
    public static let example = Recording(
        size: Measurement(value: 461, unit: .megabytes),
        length: 1066,
        mimeType: "video/mp4",
        language: "eng",
        filename: "mch2022-110-eng-May_Contain_Hackers_2022_Closing_hd.mp4",
        state: "new",
        folder: "h264-hd",
        isHighQuality: true,
        width: 1920,
        height: 1080,
        updatedAt: try! Date("2022-07-26T17:41:57Z", strategy: .iso8601),
        recordingURL: URL(
            string:
                "https://cdn.media.ccc.de/events/MCH2022/h264-hd/mch2022-110-eng-May_Contain_Hackers_2022_Closing_hd.mp4"
        )!, url: URL(string: "https://api.media.ccc.de/public/recordings/60586")!,
        eventURL: URL(
            string: "https://api.media.ccc.de/public/events/cf4dc17c-aab4-5868-9b57-100a55a1c2fb")!,
        conferenceURL: URL(string: "https://api.media.ccc.de/public/conferences/MCH2022")!
    )
}

extension Array where Element == RelatedTalk {
    public static let example: [RelatedTalk] = [
        RelatedTalk(
            eventID: 2291,
            eventGUID: "2f68e356-6c3f-4034-9640-c06d717ed96b",
            weight: 52
        ),
        RelatedTalk(
            eventID: 2814,
            eventGUID: "3cb4101c-2042-4883-b6fb-6591994a70c0",
            weight: 62
        ),
        RelatedTalk(
            eventID: 2938,
            eventGUID: "03c8501f-d327-4228-a9fe-2635370d25d2",
            weight: 40
        ),
        RelatedTalk(
            eventID: 3596,
            eventGUID: "b8e0eb47-4832-4726-bc9b-9015bd96becf",
            weight: 45
        ),
        RelatedTalk(
            eventID: 3597,
            eventGUID: "87092ad2-d3fd-4a37-bb58-1fe71217a06b",
            weight: 90
        ),
    ]
}

extension Array where Element == Recording {
    public static let example: [Recording] = [
        Recording(
            size: Measurement(value: 16, unit: .megabytes),
            length: 1066,
            mimeType: "audio/mpeg",
            language: "eng",
            filename: "mch2022-110-eng-May_Contain_Hackers_2022_Closing_mp3.mp3",
            state: "new",
            folder: "mp3",
            isHighQuality: false,
            width: 0,
            height: 0,
            updatedAt: try! Date("2022-07-26T23:32:01Z", strategy: .iso8601),
            recordingURL: URL(
                string:
                    "https://cdn.media.ccc.de/events/MCH2022/mp3/mch2022-110-eng-May_Contain_Hackers_2022_Closing_mp3.mp3"
            )!,
            url: URL(string: "https://api.media.ccc.de/public/recordings/60723")!,
            eventURL: URL(
                string:
                    "https://api.media.ccc.de/public/events/cf4dc17c-aab4-5868-9b57-100a55a1c2fb")!,
            conferenceURL: URL(string: "https://api.media.ccc.de/public/conferences/MCH2022")!
        ),
        Recording(
            size: Measurement(value: 101, unit: .megabytes),
            length: 1066,
            mimeType: "video/mp4",
            language: "eng",
            filename: "mch2022-110-eng-May_Contain_Hackers_2022_Closing_sd.mp4",
            state: "new",
            folder: "h264-sd",
            isHighQuality: false,
            width: 720,
            height: 576,
            updatedAt: try! Date("2022-07-26T23:30:43Z", strategy: .iso8601),
            recordingURL: URL(
                string:
                    "https://cdn.media.ccc.de/events/MCH2022/h264-sd/mch2022-110-eng-May_Contain_Hackers_2022_Closing_sd.mp4"
            )!,
            url: URL(string: "https://api.media.ccc.de/public/recordings/60722")!,
            eventURL: URL(
                string:
                    "https://api.media.ccc.de/public/events/cf4dc17c-aab4-5868-9b57-100a55a1c2fb")!,
            conferenceURL: URL(string: "https://api.media.ccc.de/public/conferences/MCH2022")!
        ),
        Recording(
            size: Measurement(value: 461, unit: .megabytes),
            length: 1066,
            mimeType: "video/mp4",
            language: "eng",
            filename: "mch2022-110-eng-May_Contain_Hackers_2022_Closing_hd.mp4",
            state: "new",
            folder: "h264-hd",
            isHighQuality: true,
            width: 1920,
            height: 1080,
            updatedAt: try! Date("2022-07-26T17:41:57Z", strategy: .iso8601),
            recordingURL: URL(
                string:
                    "https://cdn.media.ccc.de/events/MCH2022/h264-hd/mch2022-110-eng-May_Contain_Hackers_2022_Closing_hd.mp4"
            )!,
            url: URL(string: "https://api.media.ccc.de/public/recordings/60586")!,
            eventURL: URL(
                string:
                    "https://api.media.ccc.de/public/events/cf4dc17c-aab4-5868-9b57-100a55a1c2fb")!,
            conferenceURL: URL(string: "https://api.media.ccc.de/public/conferences/MCH2022")!
        ),
    ]
}

// swiftlint:enable force_try
