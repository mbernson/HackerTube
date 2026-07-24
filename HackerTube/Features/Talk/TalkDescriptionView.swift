//
//  TalkDescriptionView.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 24/07/2026.
//

import SwiftUI
import CCCApi

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
        let maxNumberOfLines = 5

        if shortened, let shortDescription = paragraphs.first, paragraphs.count > 1 {
            VStack(alignment: .leading, spacing: 20) {
                #if os(tvOS)
                    Button {
                        presentTalkDescription()
                    } label: {
                        Text(description)
                            .lineLimit(maxNumberOfLines)
                    }
                    .buttonStyle(.plain)
                #else
                    Text(shortDescription)
                        .lineLimit(maxNumberOfLines)

                    Button("Read more") {
                        presentTalkDescription()
                    }
                #endif
            }
            .truncationMode(.tail)
            .multilineTextAlignment(.leading)
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

#Preview("Full") {
    TalkDescriptionView(talk: .example, description: Conference.example.description!, shortened: false)
}

#Preview("Shortened") {
    TalkDescriptionView(talk: .example, description: Conference.example.description!, shortened: true)
}
