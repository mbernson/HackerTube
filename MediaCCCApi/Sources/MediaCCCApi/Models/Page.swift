//
//  Page.swift
//  MediaCCCApi
//
//  Created by Mathijs Bernson on 05/07/2026.
//

import Foundation

/// A single page of results from a paginated API endpoint.
///
/// The media.ccc.de API paginates list endpoints using the `api-pagination` gem,
/// which returns pagination metadata in the HTTP response headers (`Total`,
/// `Per-Page`, and an RFC-5988 `Link` header) rather than in the response body.
/// This type combines the decoded items with that parsed header metadata.
public struct Page<Element>: Sendable where Element: Sendable {
    /// The items on this page.
    public let items: [Element]
    /// The page number that was requested (1-based).
    public let currentPage: Int
    /// The page size reported by the server, if present.
    public let perPage: Int?
    /// The total number of items across all pages, if present.
    public let totalCount: Int?
    /// The next page number, or `nil` when there are no more pages.
    ///
    /// This is `currentPage + 1` when the server's `Link` header advertises a
    /// `rel="next"` relation.
    public let nextPage: Int?

    /// Whether another page of results is available.
    public var hasNextPage: Bool { nextPage != nil }

    public init(
        items: [Element], currentPage: Int, perPage: Int?, totalCount: Int?, nextPage: Int?
    ) {
        self.items = items
        self.currentPage = currentPage
        self.perPage = perPage
        self.totalCount = totalCount
        self.nextPage = nextPage
    }
}
