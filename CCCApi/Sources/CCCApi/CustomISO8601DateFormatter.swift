//
//  CustomISO8601DateFormatter.swift
//  CCCApi
//
//  Created by Mathijs Bernson on 09/06/2025.
//

import Foundation

/// This class is needed for use with `JSONDecoder` because:
/// 1. The `JSONDecoder.DateDecodingStrategy.iso8601` strategy uses ISO8601 format settings that are incompatible.
/// 2. The `JSONDecoder.DateDecodingStrategy.custom(_:)` raises a sendable warning. This class works around that.
class CustomISO8601DateFormatter: DateFormatter, @unchecked Sendable {
    private let iso8601Formatter: ISO8601DateFormatter

    override init() {
        iso8601Formatter = ISO8601DateFormatter()

        // Format should be: yyyy-MM-dd'T'HH:mm:ss.mmm+hh:mm
        iso8601Formatter.formatOptions = [
            .withFullDate, .withFullTime, .withTimeZone,
            .withDashSeparatorInDate, .withColonSeparatorInTime, .withColonSeparatorInTimeZone,
            .withFractionalSeconds,
        ]
        iso8601Formatter.timeZone = .autoupdatingCurrent

        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func date(from string: String) -> Date? {
        return iso8601Formatter.date(from: string)
    }

    override func string(from date: Date) -> String {
        return iso8601Formatter.string(from: date)
    }
}
