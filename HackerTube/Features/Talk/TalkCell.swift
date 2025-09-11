//
//  TalkCell.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 03/06/2024.
//

import CCCApi
import SwiftUI

#if os(iOS)
struct TalkCell: View {
    let talk: Talk

    var subtitle: Text {
        Text(talk.conferenceTitle) +
        Text(verbatim: " • ") +
        Text("\(talk.viewCount) views") +
        Text(verbatim: " • ") +
        Text(talk.releaseDate ?? talk.updatedAt, format: .relative(presentation: .named))
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
