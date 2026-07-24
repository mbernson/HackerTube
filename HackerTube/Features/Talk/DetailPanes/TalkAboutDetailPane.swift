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

struct TalkDescriptionView: View {
    let talk: Talk
    let description: String
    let shortened: Bool

    @State private var talkDescription: TalkDescription?

    private struct TalkDescription: Identifiable {
        let id: Int = 1
        let text: String
    }

    var body: some View {
        let paragraphs = description.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        if shortened, let shortDescription = paragraphs.first, paragraphs.count > 1 {
            VStack(alignment: .leading, spacing: 20) {
                #if os(tvOS)
                    Button {
                        presentTalkDescription()
                    } label: {
                        Text(shortDescription)
                            .lineLimit(5)
                            .multilineTextAlignment(.leading)
                            .padding()
                    }
                    .padding()
                    .buttonStyle(.plain)
                #else
                    Text(shortDescription)
                        .lineLimit(5)
                        .multilineTextAlignment(.leading)

                    Button("Read more") {
                        presentTalkDescription()
                    }
                #endif
            }
            .sheet(item: $talkDescription) { talkDescription in
                #if os(tvOS)
                TalkDescriptionSheetView(talk: talk, description: talkDescription.text)
                #else
                NavigationStack {
                    TalkDescriptionSheetView(talk: talk, description: talkDescription.text)
                }
                #endif
            }
        } else {
            Text(description)
                .multilineTextAlignment(.leading)
        }
    }

    func presentTalkDescription() {
        talkDescription = TalkDescription(text: description)
    }
}

private struct TalkDescriptionSheetView: View {
    let talk: Talk
    let description: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            Text(description)
                .font(.body)
                .multilineTextAlignment(.leading)
                .padding()
        }
        .navigationTitle(talk.title)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done", role: .cancel) {
                    dismiss()
                }
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
