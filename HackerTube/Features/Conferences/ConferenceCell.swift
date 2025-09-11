//
//  ConferenceCell.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 26/01/2025.
//

import CCCApi
import SwiftUI

#if os(iOS)
struct ConferenceCell: View {
    let conference: Conference

    var body: some View {
        VStack {
            if #available(iOS 26.0, *) {
                ConferenceThumbnail(conference: conference)
                    .clipShape(ConcentricRectangle(
                        corners: .concentric,
                        isUniform: true
                    ))
            } else {
                ConferenceThumbnail(conference: conference)
            }

            Text(conference.title)
                .font(.headline)
                .lineLimit(2, reservesSpace: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .containerShape(.rect(cornerRadius: 24))
    }
}

#Preview {
    Button {
    } label: {
        ConferenceCell(conference: .example)
    }
    .border(.blue)
    .padding()
}
#endif
