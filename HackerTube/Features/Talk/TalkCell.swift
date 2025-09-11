//
//  TalkCell.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 03/06/2024.
//

import CCCApi
import SwiftUI

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
            TalkThumbnail(talk: talk)

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
