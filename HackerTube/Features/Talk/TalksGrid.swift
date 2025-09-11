//
//  TalksGrid.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 27/06/2023.
//

import CCCApi
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

private struct TalksGridRegular: View {
    let talks: [Talk]
    let columns: [GridItem] = [GridItem(.adaptive(minimum: 200, maximum: 400))]

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(talks) { talk in
                NavigationLink {
                    TalkView(talk: talk)
                } label: {
                    TalkCell(talk: talk)
                        #if os(visionOS)
                            .padding()
                            .contentShape(Rectangle())
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

#if os(tvOS)
    private struct TalksGridTV: View {
        let talks: [Talk]
        let columns: [GridItem] = Array(repeating: GridItem(), count: 4)

        var body: some View {
            LazyVGrid(columns: columns, spacing: 80) {
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
            .multilineTextAlignment(.center)
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
