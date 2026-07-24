//
//  TalksGrid.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 27/06/2023.
//

import MediaCCCApi
import SwiftUI

struct TalksGrid: View {
    let talks: [Talk]
    var body: some View {
        #if os(tvOS)
            TalksGridTV(talks: talks)
        #else
            TalksGridRegular(talks: talks)
        #endif
    }
}

#if os(iOS) || os(visionOS)
private struct TalksGridRegular: View {
    let talks: [Talk]
    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 240), spacing: 16)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(talks) { talk in
                NavigationLink {
                    TalkView(talk: talk)
                } label: {
                    TalkCell(talk: talk)
                        #if os(visionOS)
                            .padding()
                            .contentShape(RoundedRectangle(cornerRadius: 16))
                            .hoverEffect(.lift)
                        #endif
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .multilineTextAlignment(.center)
        .accessibilityIdentifier("TalksGrid")
        .accessibilityElement(children: .contain)
    }
}
#endif

#if os(tvOS)
    private struct TalksGridTV: View {
        let talks: [Talk]
        let columns: [GridItem] = Array(
            repeating: GridItem(.flexible(minimum: 320), spacing: 48),
            count: 4
        )

        var body: some View {
            LazyVGrid(columns: columns, spacing: 64) {
                ForEach(talks) { talk in
                    VStack(alignment: .leading) {
                        NavigationLink {
                            TalkView(talk: talk)
                        } label: {
                            TalkThumbnail(talk: talk)
                        }

                        Text(talk.title)
                            .font(.headline)
                            .lineLimit(2, reservesSpace: true)
                    }
                }
            }
            .padding()
            .multilineTextAlignment(.leading)
            .focusSection()
            .buttonStyle(.card)
            .accessibilityIdentifier("TalksGrid")
            .accessibilityElement(children: .contain)
        }
    }
#endif

#Preview {
    TalksGrid(talks: [.example])
}
