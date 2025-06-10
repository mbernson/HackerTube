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
        ScrollView {
            #if os(tvOS)
                HStack(alignment: .top) {
                    TalkMainView(talk: talk, viewModel: viewModel)

                    TalkMetaView(
                        talk: talk, selectedRecording: $selectedRecording, viewModel: viewModel
                    )
                    .frame(maxWidth: 480, maxHeight: .infinity)
                }
            #else
                VStack(spacing: 20) {
                    TalkMainView(talk: talk, viewModel: viewModel)

                    TalkMetaView(
                        talk: talk, selectedRecording: $selectedRecording, viewModel: viewModel
                    )
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .navigationBarTitleDisplayMode(.inline)
            #endif
        }
        .navigationTitle(talk.title)
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

private struct TVPlayerView: View {
    let talk: Talk
    let recording: Recording?
    @State private var selectedRecording: Recording?

    var body: some View {
        Button {
            selectedRecording = recording
        } label: {
            TalkThumbnail(talk: talk)
                .overlay {
                    Image(systemName: "play.fill")
                        .font(.title)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 20)
                }
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .contentShape(RoundedRectangle(cornerRadius: 24))
                .hoverEffect()
        }
        #if !os(tvOS)
            .buttonStyle(.plain)
        #endif
        .disabled(recording == nil)
        .fullScreenCover(item: $selectedRecording) { recording in
            TalkPlayerView(talk: talk, recording: recording, automaticallyStartsPlayback: true)
        }
    }
}

private struct TalkMainView: View {
    let talk: Talk
    var viewModel: TalkViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Group {
                #if os(tvOS) || os(visionOS)
                    TVPlayerView(talk: talk, recording: viewModel.preferredRecording)
                #else
                    Group {
                        if let preferredRecording = viewModel.preferredRecording {
                            TalkPlayerView(
                                talk: talk, recording: preferredRecording,
                                automaticallyStartsPlayback: true)
                        } else {
                            Rectangle()
                                .fill(.black)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(16 / 9, contentMode: .fit)
                #endif
            }
            .frame(maxWidth: 1024)
            .frame(maxWidth: .infinity, alignment: .center)

            if let description = talk.description {
                TalkDescriptionView(talk: talk, description: description)
                    .font(.body)
                    .padding(.horizontal)
            }

            CopyrightView(talk: talk, viewModel: viewModel)
                .padding(.horizontal)
        }
        .animation(.default, value: viewModel.copyright)
        #if os(tvOS)
            .focusSection()
            .buttonStyle(.card)
        #endif
        .multilineTextAlignment(.leading)
        #if !os(tvOS)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: talk.frontendLink)
                }
            }
        #endif
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
                let link = talk.link ?? talk.conferenceURL
                Text(
                    "No copyright information encoded in video. Please refer to the website of the organizer of \(title) at: \(talk.conferenceURL)",
                    comment: "A label that is shown when no copyright information is available for a talk."
                )
            }
        }
        .font(.caption)
    }
}

private struct TalkDescriptionView: View {
    let talk: Talk
    let description: String

    @State private var talkDescription: TalkDescription?

    private struct TalkDescription: Identifiable {
        let id: Int = 1
        let text: String
    }

    var body: some View {
        let paragraphs = description.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        if let shortDescription = paragraphs.first, paragraphs.count > 1 {
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
                NavigationStack {
                    ScrollView {
                        Text(talkDescription.text)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .padding()
                    }
                    .navigationTitle(talk.title)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done", role: .cancel) {
                                self.talkDescription = nil
                            }
                        }
                    }
                }
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

private struct TalkMetaView: View {
    let talk: Talk
    @Binding var selectedRecording: Recording?
    var viewModel: TalkViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Label {
                Text(Duration.seconds(talk.duration), format: .time(pattern: .hourMinute))
            } icon: {
                Image(systemName: "clock")
            }

            if let releaseDate = talk.releaseDate {
                Label {
                    Text(releaseDate, style: .date)
                } icon: {
                    Image(systemName: "calendar")
                }
            }

            Label("\(talk.viewCount) views", systemImage: "eye")

            if !talk.persons.isEmpty {
                Label(talk.persons.joined(separator: ", "), systemImage: "person")
            }
        }
    }
}

struct TalkView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TalkView(talk: .example)
        }
    }
}
