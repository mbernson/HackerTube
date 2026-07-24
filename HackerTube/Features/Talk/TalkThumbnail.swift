//
//  TalkThumbnail.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 14/07/2023.
//

import MediaCCCApi
import SwiftUI

struct TalkThumbnail: View {
    let talk: Talk
    @State private var id: UUID?

    var body: some View {
        AsyncImage(url: talk.posterURL ?? talk.thumbURL) { phase in
            if let image = phase.image {
                image.resizable().scaledToFit()
            } else if let error = phase.error as? NSError {
                Image(systemName: "xmark.circle")
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.regularMaterial)
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
        .id(id)
    }
}

#Preview("Talk thumbnail") {
    TalkThumbnail(talk: .example)
        .border(.blue)
}
