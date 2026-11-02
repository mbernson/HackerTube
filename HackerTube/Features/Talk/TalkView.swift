//
//  TalkView.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 29/07/2022.
//

import MediaCCCApi
import SwiftUI

struct TalkView: View {
    let talk: Talk
    /// Whether playback of the preferred recording starts as soon as it is known.
    var autoplay = false
    @State private var selectedRecording: Recording?
    @State private var viewModel = TalkViewModel()
    @State private var error: Error?
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        Group {
            #if os(tvOS) || os(visionOS)
            TalkViewTV(talk: talk, viewModel: viewModel)
            #else
            TalkViewDefault(talk: talk, selectedRecording: $selectedRecording, viewModel: viewModel)
            #endif
        }
        .task(id: talk) {
            guard talk != viewModel.currentTalk else { return }
            do {
                try await viewModel.loadRecordings(for: talk)
                if autoplay, let recording = viewModel.preferredRecording {
                    coordinator.play(talk: talk, recording: recording)
                }
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

/// Talk View with an inline player, used on iOS and macOS.
private struct TalkViewDefault: View {
    let talk: Talk
    @Binding var selectedRecording: Recording?
    var viewModel: TalkViewModel

    @State var selectedDetailPane: TalkDetailPane = .about

    enum TalkDetailPane: Hashable {
        case about, metadata
    }

    var body: some View {
        VStack {
            TalkVideoPlayerView(
                talk: talk,
                preferredRecording: viewModel.preferredRecording
            )

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
            .safeAreaPadding()
        }
    }
}

/// Talk View that is specific to tvOS and visionOS.
private struct TalkViewTV: View {
    let talk: Talk
    var viewModel: TalkViewModel
    @Environment(AppCoordinator.self) private var coordinator
    @FocusState private var isWatchButtonFocused: Bool

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
                            if let recording = viewModel.preferredRecording {
                                coordinator.play(talk: talk, recording: recording)
                            }
                        } label: {
                            Label("Watch", systemImage: "play.fill")
                                .padding(.horizontal, 64)
                        }
                        .disabled(viewModel.preferredRecording == nil)
                        .focused($isWatchButtonFocused)
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
            #if os(visionOS)
            .safeAreaPadding()
            #endif
        }
        .onChange(of: viewModel.preferredRecording != nil) { _, canWatch in
            // Move focus into the content once the Watch button is enabled. Without this, focus can remain on the
            // tab bar, e.g. when the talk was opened from a deep link, and Menu would then exit the app.
            guard canWatch else { return }
            Task { @MainActor in
                isWatchButtonFocused = true
            }
        }
    }
}

#Preview {
    let playback = PlaybackController()
    NavigationStack {
        TalkView(talk: .example)
    }
    .environment(ApiService())
    .environment(playback)
    .environment(AppCoordinator(playback: playback))
}
