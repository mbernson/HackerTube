//
//  TalkView.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import CCCApi
import SwiftUI

struct TalkView: View {
    let talk: Talk
    @State var selectedRecording: Recording?
    @State private var viewModel = TalkViewModel()
    @State private var error: Error?

    @State var selectedDetailPane: TalkDetailPane = .about

    enum TalkDetailPane: Hashable {
        case about, metadata
    }

    var body: some View {
        VStack {
            TalkVideoPlayerView(talk: talk, preferredRecording: viewModel.preferredRecording)
                .frame(maxWidth: 1024)
                .frame(maxWidth: .infinity, alignment: .center)

            Picker("Mode", selection: $selectedDetailPane) {
                Text("About").tag(TalkDetailPane.about)
                Text("Metadata").tag(TalkDetailPane.metadata)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 4)

            ScrollView {
                switch selectedDetailPane {
                case .about:
                    TalkAboutDetailPane(talk: talk)
                case .metadata:
                    TalkMetadataDetailPane(talk: talk, selectedRecording: $selectedRecording, viewModel: viewModel)
                }
            }
            .safeAreaPadding(.all)
        }
        .task(id: talk) {
            guard talk != viewModel.currentTalk else { return }
            do {
                try await viewModel.loadRecordings(for: talk)
            } catch is CancellationError {
            } catch {
                self.error = error
            }
        }
        .alert("Failed to load data from the media.ccc.de API", error: $error)
        .accessibilityIdentifier("TalkView")
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    NavigationStack {
        TalkView(talk: .example)
    }
}
