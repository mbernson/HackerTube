//
//  ConferenceThumbnail.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 14/07/2023.
//

import CCCApi
import SwiftUI

struct ConferenceThumbnail: View {
    let conference: Conference
    @State private var id: UUID?

    var body: some View {
        AsyncImage(url: conference.logoURL) { phase in
            if let image = phase.image {
                image.resizable().scaledToFit()
            } else if let error = phase.error as? NSError {
                Text(conference.acronym)
                    .font(.title3.monospaced())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(16 / 9, contentMode: .fit)
        .background(.regularMaterial)
        .id(id)
    }
}

#Preview("Conference thumbnail") {
    ConferenceThumbnail(conference: .example)
        .border(.blue)
}
