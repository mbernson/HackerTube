//
//  TalkLabels.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 24/07/2026.
//

import SwiftUI

struct DurationLabel: View {
    let duration: TimeInterval

    var body: some View {
        Label {
            Text(Duration.seconds(duration), format: .time(pattern: .hourMinute))
        } icon: {
            Image(systemName: "clock")
        }
    }
}

struct ReleaseDateLabel: View {
    let releaseDate: Date

    init(_ releaseDate: Date) {
        self.releaseDate = releaseDate
    }

    var body: some View {
        Label {
            Text(releaseDate, style: .date)
        } icon: {
            Image(systemName: "calendar")
        }
    }
}

struct ViewCountLabel: View {
    let numberOfViews: Int

    var body: some View {
        Label("\(numberOfViews) views", systemImage: "eye")
    }
}

struct PresentersLabel: View {
    let presenterNames: [String]

    var body: some View {
        Label(presenterNames.joined(separator: ", "), systemImage: "person")
    }
}

#Preview {
    DurationLabel(duration: 3600 + 42)
}

#Preview {
    ReleaseDateLabel(Date(timeIntervalSince1970: 1784896301))
}

#Preview {
    ViewCountLabel(numberOfViews: 4200)
}

#Preview {
    PresentersLabel(presenterNames: ["Huey", "Dewey", "Louie"])
}
