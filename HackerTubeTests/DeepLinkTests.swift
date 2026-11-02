//
//  DeepLinkTests.swift
//  HackerTubeTests
//
//  Created by Mathijs Bernson on 30/07/2022.
//

import Foundation
import Testing

@testable import HackerTube

@Suite struct DeepLinkTests {
    let id = "44ab627f-ed5d-522b-b84b-15a3ed761895"

    @Test func `Parse open URL`() throws {
        let url = try #require(URL(string: "ccctube://talk/\(id)"))
        #expect(DeepLink(url: url) == .talk(id: id, action: .open))
    }

    @Test func `Parse play URL`() throws {
        let url = try #require(URL(string: "ccctube://talk/\(id)/play"))
        #expect(DeepLink(url: url) == .talk(id: id, action: .play))
    }

    @Test(arguments: [
        "ccctube://",
        "ccctube://talk",
        "https://google.com/",
        "ccctube://foo",
        "mailto:info@example.com",
    ])
    func `Invalid URLs`(urlString: String) throws {
        let url = try #require(URL(string: urlString))
        #expect(DeepLink(url: url) == nil)
    }

    @Test(arguments: [DeepLink.TalkAction.open, .play])
    func `URL round trip`(action: DeepLink.TalkAction) {
        let link = DeepLink.talk(id: id, action: action)
        #expect(DeepLink(url: link.url) == link)
    }

    @Test func `URLs match the format used by the Top Shelf`() {
        #expect(DeepLink.talk(id: id, action: .open).url.absoluteString == "ccctube://talk/\(id)")
        #expect(DeepLink.talk(id: id, action: .play).url.absoluteString == "ccctube://talk/\(id)/play")
    }
}
