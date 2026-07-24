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
    private let parser = URLParser()

    @Test func parseOpenURL() throws {
        let url = try #require(URL(string: "ccctube://talk/44ab627f-ed5d-522b-b84b-15a3ed761895"))
        #expect(parser.parseURL(url) == .openTalk(id: "44ab627f-ed5d-522b-b84b-15a3ed761895"))
    }

    @Test func parsePlayURL() throws {
        let url = try #require(URL(string: "ccctube://talk/44ab627f-ed5d-522b-b84b-15a3ed761895/play"))
        #expect(parser.parseURL(url) == .playTalk(id: "44ab627f-ed5d-522b-b84b-15a3ed761895"))
    }

    @Test(arguments: [
        "ccctube://",
        "https://google.com/",
        "ccctube://foo",
        "mailto:info@example.com",
    ])
    func invalidURLs(urlString: String) throws {
        let url = try #require(URL(string: urlString))
        #expect(parser.parseURL(url) == nil)
    }
}
