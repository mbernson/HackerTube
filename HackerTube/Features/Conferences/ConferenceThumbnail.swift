//
//  ConferenceThumbnail.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 14/07/2023.
//

import CCCApi
import SwiftUI

/// Renders the thumbnail of a conference.
/// Some conferences have an SVG image as their thumbnail. This is not supported by Apple's `AsyncImage` so a custom
/// `SVGImageView` is used. It downloads the SVG, renders it to a bitmap and displays it.
struct ConferenceThumbnail: View {
    let conference: Conference
    @State private var id: UUID?

    var body: some View {
        thumbnail
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(16 / 9, contentMode: .fit)
            .background(.regularMaterial)
            .id(id)
    }

    @ViewBuilder private var thumbnail: some View {
        if conference.logoURL.pathExtension.caseInsensitiveCompare("svg") == .orderedSame {
            SVGImageView(url: conference.logoURL) { fallback }
        } else {
            AsyncImage(url: conference.logoURL) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFit()
                } else if let error = phase.error as? NSError {
                    fallback
                        .onAppear {
                            // Needed to reload the image when the request has been cancelled.
                            // This happens when the image scrolls out of view before it has finished loading.
                            if error.domain == NSURLErrorDomain, error.code == NSURLErrorCancelled {
                                id = UUID()
                            }
                        }
                } else {
                    ProgressView()
                }
            }
        }
    }

    private var fallback: some View {
        Text(conference.acronym)
            .font(.title3.monospaced())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Conference thumbnail") {
    ConferenceThumbnail(conference: .example)
        .border(.blue)
}
