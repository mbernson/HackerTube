//
//  URLParserTests.swift
//  HackerTubeTests
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import Foundation
import Testing

@testable import HackerTube

struct URLParserTests {
    let parser = URLParser()

    @Test func `Parse open URL`() {
        let url = URL(string: "ccctube://talk/44ab627f-ed5d-522b-b84b-15a3ed761895")!
        #expect(parser.parseURL(url) == .openTalk(id: "44ab627f-ed5d-522b-b84b-15a3ed761895"))
    }

    @Test func `Parse play URL`() {
        let url = URL(string: "ccctube://talk/44ab627f-ed5d-522b-b84b-15a3ed761895/play")!
        #expect(parser.parseURL(url) == .playTalk(id: "44ab627f-ed5d-522b-b84b-15a3ed761895"))
    }

    @Test(arguments: [
        "ccctube://",
        "https://google.com/",
        "ccctube://foo",
        "mailto:info@example.com",
    ])
    func `Invalid URLs`(urlString: String) throws {
        let url = try #require(URL(string: urlString))
        #expect(parser.parseURL(url) == nil)
    }
}
