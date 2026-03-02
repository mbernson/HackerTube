//
//  URLParserTests.swift
//  HackerTubeTests
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import Foundation
import Testing
@testable import HackerTube

@Suite("URLParser")
struct URLParserTests {
    let parser = URLParser()

    @Test("Parses valid ccctube:// URLs", arguments: zip(
        [
            URL(string: "ccctube://talk/44ab627f-ed5d-522b-b84b-15a3ed761895")!,
            URL(string: "ccctube://talk/44ab627f-ed5d-522b-b84b-15a3ed761895/play")!,
        ],
        [
            URLRoute.openTalk(id: "44ab627f-ed5d-522b-b84b-15a3ed761895"),
            URLRoute.playTalk(id: "44ab627f-ed5d-522b-b84b-15a3ed761895"),
        ]
    ))
    func parsesValidURL(_ url: URL, expectedRoute: URLRoute) {
        #expect(parser.parseURL(url) == expectedRoute)
    }

    @Test("Returns nil for invalid URLs", arguments: [
        "ccctube://",
        "https://google.com/",
        "ccctube://foo",
        "mailto:info@example.com",
    ])
    func returnsNilForInvalidURL(_ urlString: String) {
        #expect(parser.parseURL(URL(string: urlString)!) == nil)
    }
}
