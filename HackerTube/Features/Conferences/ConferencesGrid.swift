//
//  ConferencesGrid.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 11/09/2025.
//

import CCCApi
import SwiftUI

struct ConferencesGrid: View {
    let conferences: [Conference]
    var body: some View {
        #if os(tvOS)
            ConferencesGridTV(conferences: conferences)
        #else
            ConferencesGridRegular(conferences: conferences)
        #endif
    }
}

private struct ConferencesGridRegular: View {
    let conferences: [Conference]
    let columns: [GridItem] = Array(
        repeating: GridItem(.adaptive(minimum: 200, maximum: 400)),
        count: 2)

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(conferences) { conference in
                NavigationLink {
                    ConferenceView(conference: conference)
                } label: {
                    ConferenceCell(conference: conference)
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
        .accessibilityIdentifier("ConferencesGrid")
        .accessibilityElement(children: .contain)
    }
}

#if os(tvOS)
    private struct ConferencesGridTV: View {
        let conferences: [Conference]
        let columns: [GridItem] = Array(repeating: GridItem(), count: 4)

        var body: some View {
            LazyVGrid(columns: columns, spacing: 80) {
                ForEach(conferences) { conference in
                    VStack(alignment: .leading) {
                        NavigationLink {
                            ConferenceView(conference: conference)
                        } label: {
                            ConferenceThumbnail(conference: conference)
                        }

                        Text(conference.title)
                            .font(.headline)
                            .lineLimit(2, reservesSpace: true)
                    }
                }
            }
            .padding()
            .multilineTextAlignment(.center)
            .focusSection()
            .buttonStyle(.card)
            .accessibilityIdentifier("ConferencesGrid")
            .accessibilityElement(children: .contain)
        }
    }
#endif

#Preview {
    ConferencesGrid(conferences: [.example])
}
