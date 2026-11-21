//
//  Backport.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 04/11/2026.
//

import Foundation
import SwiftUI

// Thanks to: https://davedelong.com/blog/2021/10/09/simplifying-backwards-compatibility-in-swift/
struct Backport<Content> {
    let content: Content

    init(_ content: Content) {
        self.content = content
    }
}

extension View {
    var backport: Backport<Self> { Backport(self) }
}

extension Backport where Content: View {
    @ViewBuilder func asyncImageURLSession(_ urlSession: URLSession) -> some View {
        if #available(iOS 27, tvOS 27, visionOS 27, *) {
            content.asyncImageURLSession(urlSession)
        } else {
            content
        }
    }
}
