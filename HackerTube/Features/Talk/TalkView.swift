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

    var body: some View {
        Group {
            #if os(tvOS)
            TalkViewTV(talk: talk, selectedRecording: $selectedRecording, viewModel: viewModel)
            #else
            TalkViewInner(talk: talk, selectedRecording: $selectedRecording, viewModel: viewModel)
            #endif
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

@available(tvOS, unavailable)
private struct TalkViewInner: View {
    let talk: Talk
    @Binding var selectedRecording: Recording?
    var viewModel: TalkViewModel

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
    }
}

@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
private struct TalkViewTV: View {
    let talk: Talk
    @Binding var selectedRecording: Recording?
    var viewModel: TalkViewModel

    var body: some View {
        ScrollView {
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(talk.title)
                            .font(.title.bold())

                        Text(talk.conferenceTitle)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    TalkThumbnail(talk: talk)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .frame(maxWidth: 768, alignment: .trailing)
                }

                HStack(alignment: .top) {
                    VStack {
                        Button {
                            selectedRecording = viewModel.preferredRecording
                        } label: {
                            Label("Watch", systemImage: "play.fill")
                                .padding(.horizontal, 64)
                        }
                        .disabled(viewModel.preferredRecording == nil)
                    }

                    VStack(alignment: .leading) {
                        // Description
                        if let description = talk.description {
                            TalkDescriptionView(talk: talk, description: description, shortened: true)
                                .font(.body)
                        } else {
                            Text("No description is available for this talk")
                                .italic()
                                .font(.body)
                        }

                        // Metadata
                        HStack {
                            if let releaseDate = talk.releaseDate {
                                ReleaseDateLabel(releaseDate)
                            }

                            DurationLabel(duration: talk.duration)

                            ViewCountLabel(numberOfViews: talk.viewCount)

                            if !talk.persons.isEmpty {
                                PresentersLabel(presenterNames: talk.persons)
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .fullScreenCover(item: $selectedRecording) { recording in
            TalkPlayerView(talk: talk, recording: recording, automaticallyStartsPlayback: true)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    NavigationStack {
        TalkView(talk: .example)
    }
}
