//
//  TalkMetadataDetailPane.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 24/07/2026.
//

import SwiftUI
import CCCApi

struct TalkMetadataDetailPane: View {
    let talk: Talk
    @Binding var selectedRecording: Recording?
    var viewModel: TalkViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DurationLabel(duration: talk.duration)

            // Release date
            if let releaseDate = talk.releaseDate {
                ReleaseDateLabel(releaseDate)
            }

            // View count
            ViewCountLabel(numberOfViews: talk.viewCount)

            // Presenters
            if !talk.persons.isEmpty {
                PresentersLabel(presenterNames: talk.persons)
            }

            // Copyright
            CopyrightView(talk: talk, viewModel: viewModel)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct CopyrightView: View {
    let talk: Talk
    var viewModel: TalkViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Copyright")
                .font(.headline)

            switch viewModel.copyright {
            case .loading:
                ProgressView()
            case .copyright(let string):
                Text(string)
            case .unknown:
                let title = talk.conferenceTitle
                Text(
                    "No copyright information encoded in video. Please refer to the website of the organizer of \(title) at: \(talk.conferenceURL)",
                    comment: "A label that is shown when no copyright information is available for a talk."
                )
            }
        }
        .font(.caption)
    }
}

#Preview {
    @Previewable @State var selectedRecording: Recording? = .example
    @Previewable @State var viewModel = TalkViewModel()
    TalkMetadataDetailPane(talk: .example, selectedRecording: $selectedRecording, viewModel: viewModel)
}
