import Foundation
import CoreGraphics
import CNanoSVG

/// Errors thrown while rendering an SVG to a bitmap.
public enum NanoSVGError: Error, Equatable {
    /// The input contained no bytes.
    case emptyData
    /// NanoSVG could not parse the input (malformed or unsupported SVG).
    case parseFailed
    /// The SVG reported a zero or negative intrinsic width/height.
    case invalidImageDimensions
    /// The requested target size or scale was zero or negative.
    case invalidTargetSize
    /// NanoSVG failed to allocate a rasterizer context.
    case rasterizerUnavailable
    /// A `CGImage` could not be constructed from the rasterized pixels.
    case imageCreationFailed
}

/// Rasterizes SVG documents to `CGImage`s using NanoSVG.
public struct NanoSVGRenderer {

    /// Reference resolution (dots per inch) used to convert absolute SVG units
    /// (mm, pt, in, …) to pixels. Defaults to the CSS standard of `96`. Output
    /// crispness at a given pixel size is governed by ``render(svgData:targetSize:scale:)``'s
    /// `scale`, not this value; DPI only affects SVGs sized in physical units.
    public let dpi: CGFloat

    /// Creates a renderer.
    /// - Parameter dpi: Reference resolution for absolute-unit conversion (default `96`).
    public init(dpi: CGFloat = 96) {
        self.dpi = dpi
    }

    /// Rasterizes SVG data into a `CGImage`, aspect-fit and centered within the
    /// requested pixel box.
    ///
    /// - Parameters:
    ///   - svgData: Raw SVG document bytes (UTF-8).
    ///   - targetSize: Desired size in points.
    ///   - scale: Pixel scale factor (e.g. `2` for `@2x`). The output pixel dimensions are `targetSize * scale`.
    /// - Returns: A non-premultiplied RGBA `CGImage` of `targetSize * scale` pixels.
    public func render(svgData: Data, targetSize: CGSize, scale: CGFloat) throws -> CGImage {
        guard !svgData.isEmpty else { throw NanoSVGError.emptyData }
        guard targetSize.width > 0, targetSize.height > 0, scale > 0 else {
            throw NanoSVGError.invalidTargetSize
        }

        // `nsvgParse` mutates its input and requires a null-terminated C string.
        // It does not retain the buffer, so a temporary mutable copy is safe.
        var mutable = svgData
        mutable.append(0)
        let imagePointer: UnsafeMutablePointer<NSVGimage>? = mutable.withUnsafeMutableBytes { raw in
            nsvgParse(raw.baseAddress!.assumingMemoryBound(to: CChar.self), "px", Float(dpi))
        }
        guard let image = imagePointer else { throw NanoSVGError.parseFailed }
        defer { nsvgDelete(image) }

        let svgWidth = CGFloat(image.pointee.width)
        let svgHeight = CGFloat(image.pointee.height)
        guard svgWidth > 0, svgHeight > 0 else { throw NanoSVGError.invalidImageDimensions }

        let pixelWidth = Int((targetSize.width * scale).rounded())
        let pixelHeight = Int((targetSize.height * scale).rounded())
        guard pixelWidth > 0, pixelHeight > 0 else { throw NanoSVGError.invalidTargetSize }

        // Aspect-fit the SVG into the pixel box and center it.
        let fit = min(CGFloat(pixelWidth) / svgWidth, CGFloat(pixelHeight) / svgHeight)
        let tx = (CGFloat(pixelWidth) - svgWidth * fit) / 2
        let ty = (CGFloat(pixelHeight) - svgHeight * fit) / 2

        guard let rasterizer = nsvgCreateRasterizer() else {
            throw NanoSVGError.rasterizerUnavailable
        }
        defer { nsvgDeleteRasterizer(rasterizer) }

        let stride = pixelWidth * 4
        var pixels = Array<UInt8>(repeating: 0, count: stride * pixelHeight)
        pixels.withUnsafeMutableBytes { buffer in
            nsvgRasterize(
                rasterizer, image,
                Float(tx), Float(ty), Float(fit),
                buffer.baseAddress!.assumingMemoryBound(to: UInt8.self),
                Int32(pixelWidth), Int32(pixelHeight), Int32(stride)
            )
        }

        // NanoSVG produces non-premultiplied RGBA (alpha last).
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue)
        guard let provider = CGDataProvider(data: Data(pixels) as CFData),
              let cgImage = CGImage(
                width: pixelWidth,
                height: pixelHeight,
                bitsPerComponent: 8,
                bitsPerPixel: 32,
                bytesPerRow: stride,
                space: colorSpace,
                bitmapInfo: bitmapInfo,
                provider: provider,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent
              )
        else { throw NanoSVGError.imageCreationFailed }

        return cgImage
    }

    /// Rasterizes an SVG string into a `CGImage`. See ``render(svgData:targetSize:scale:)``.
    public func render(svgString: String, targetSize: CGSize, scale: CGFloat) throws -> CGImage {
        try render(svgData: Data(svgString.utf8), targetSize: targetSize, scale: scale)
    }
}
