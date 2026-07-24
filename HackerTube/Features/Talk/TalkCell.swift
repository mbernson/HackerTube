//
//  TalkCell.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 03/06/2024.
//

import MediaCCCApi
import SwiftUI

#if os(iOS) || os(visionOS)
struct TalkCell: View {
    let talk: Talk

    var subtitle: Text {
        let releaseDate: String? = talk.releaseDate.flatMap { $0.formatted(.relative(presentation: .named)) }
        return Text(
            [
                talk.conferenceTitle,
                "\(talk.viewCount.formatted()) views",
                releaseDate,
            ]
            .compactMap { $0 }
            .joined(separator: " • ")
        )
    }

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        VStack {
            if #available(iOS 26.0, *) {
                TalkThumbnail(talk: talk)
                    .clipShape(ConcentricRectangle(
                        corners: .concentric,
                        isUniform: true
                    ))
            } else {
                TalkThumbnail(talk: talk)
            }

            VStack(alignment: .leading) {
                Text(talk.title)
                    .font(.headline)
                    .lineLimit(2, reservesSpace: horizontalSizeClass == .regular ? true : false)

                subtitle
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .tint(.black)
        .containerShape(.rect(cornerRadius: 24))
    }
}

#Preview {
    Button {
    } label: {
        TalkCell(talk: .example)
    }
    .border(.blue)
    .padding()
}
#endif
