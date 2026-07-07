//
//  SVGImageView.swift
//  HackerTube
//
//  Created by Mathijs Bernson on 06/07/2026.
//

import SwiftUI
import NanoSVG

/// Loads an SVG from a URL and rasterizes it to a bitmap using `NanoSVG`.
struct SVGImageView<Fallback: View>: View {
    let url: URL
    @ViewBuilder var fallback: () -> Fallback

    private var cache = SVGImageCache.shared
    @Environment(\.displayScale) private var displayScale
    @State private var image: CGImage?
    @State private var didFail = false

    init(url: URL, @ViewBuilder fallback: @escaping () -> Fallback) {
        self.url = url
        self.fallback = fallback
    }

    var body: some View {
        GeometryReader { proxy in
            content
                .frame(width: proxy.size.width, height: proxy.size.height)
                .task(id: RenderKey(url: url, size: proxy.size, scale: displayScale)) {
                    await load(size: proxy.size)
                }
        }
    }

    @ViewBuilder private var content: some View {
        if let image {
            Image(decorative: image, scale: displayScale, orientation: .up)
                .resizable()
                .scaledToFit()
        } else if didFail {
            fallback()
        } else {
            ProgressView()
        }
    }

    private func load(size: CGSize) async {
        guard size.width > 0, size.height > 0 else { return }
        let key = RenderKey(url: url, size: size, scale: displayScale)

        if let cached = cache[key] {
            image = cached
            return
        }

        didFail = false
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            try Task.checkCancellation()
            let rendered = try await rasterizeSVG(data: data, size: size, scale: displayScale)
            cache[key] = rendered
            image = rendered
        } catch is CancellationError {
            // View scrolled away mid-load; task will re-run on reappearance.
        } catch {
            image = nil
            didFail = true
        }
    }
}

/// Equatable identity for the render task, so it re-runs only when the URL or
/// the target pixel size meaningfully changes (rounded to whole pixels to avoid
/// thrashing on sub-pixel layout changes).
private struct RenderKey: Equatable, CustomStringConvertible {
    let url: URL
    let pixelWidth: Int
    let pixelHeight: Int

    init(url: URL, size: CGSize, scale: CGFloat) {
        self.url = url
        self.pixelWidth = Int((size.width * scale).rounded())
        self.pixelHeight = Int((size.height * scale).rounded())
    }

    var description: String {
        "\(url.absoluteString)|\(pixelWidth)x\(pixelHeight)"
    }
}

/// Off-main, CPU-bound rasterization. The non-Sendable `NanoSVGRenderer` is
/// created and consumed entirely here, so it never crosses a concurrency domain.
@concurrent
private func rasterizeSVG(data: Data, size: CGSize, scale: CGFloat) async throws -> CGImage {
    try NanoSVGRenderer().render(svgData: data, targetSize: size, scale: scale)
}

// MARK: Caching

/// In-memory cache of rasterized SVG bitmaps, keyed by source URL and target
/// pixel size, so identical thumbnails aren't re-downloaded and re-rendered.
///
/// `NSCache` is thread-safe and automatically evicts entries under memory
/// pressure, so no manual eviction is needed.
private final class SVGImageCache {
    private let cache = NSCache<NSString, CGImage>()

    static let shared = SVGImageCache()

    private init() {
        cache.countLimit = 5 // Maximum number of cached images
    }

    subscript(key: RenderKey) -> CGImage? {
        get {
            let key = key.description as NSString
            return cache.object(forKey: key)
        }
        set(image) {
            let key = key.description as NSString
            if let image {
                cache.setObject(image, forKey: key)
            } else {
                cache.removeObject(forKey: key)
            }
        }
    }
}

#Preview("SVG logo") {
    SVGImageView(url: URL(string: "https://static.media.ccc.de/media/events/gpn/gpn24/logo.svg")!) {
        Text("GPN42")
    }
    .frame(width: 320, height: 180)
    .border(.blue)
}
