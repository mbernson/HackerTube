//
//  TalkAboutDetailPane.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 24/07/2026.
//

import SwiftUI
import CCCApi

struct TalkAboutDetailPane: View {
    let talk: Talk

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            Text(talk.title)
                .font(.title.bold())

            // Conference/event title
            Text(talk.conferenceTitle)
                .font(.headline)
                .foregroundStyle(.secondary)

            // Description
            if let description = talk.description {
                #if os(tvOS)
                let shortened = true
                #else
                let shortened = false
                #endif
                TalkDescriptionView(talk: talk, description: description, shortened: shortened)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("No description is available for this talk")
                    .italic()
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

#Preview {
    ScrollView {
        TalkAboutDetailPane(talk: .example)
            .border(.black)
    }
    .safeAreaPadding(.all)
}
