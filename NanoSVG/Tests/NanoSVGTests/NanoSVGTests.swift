import CoreGraphics
import Foundation
import Testing

@testable import NanoSVG

@Suite("NanoSVG Renderer")
struct NanoSVGRendererTests {
    private let renderer = NanoSVGRenderer()

    /// A minimal, well-formed SVG: a red rectangle in a 100×50 viewBox.
    private let sampleSVG = """
        <?xml version="1.0"?>
        <svg xmlns="http://www.w3.org/2000/svg" width="100" height="50" viewBox="0 0 100 50">
        <rect x="0" y="0" width="100" height="50" fill="#ff0000"/>
        </svg>
        """

    private func loadTestData(_ name: String) throws -> Data {
        let url = try #require(
            Bundle.module.url(forResource: name, withExtension: "svg", subdirectory: "TestData"))
        return try Data(contentsOf: url)
    }

    @Test func rendersToRequestedPixelDimensions() throws {
        let image = try renderer.render(
            svgString: sampleSVG,
            targetSize: CGSize(width: 100, height: 100),
            scale: 2
        )
        #expect(image.width == 200)
        #expect(image.height == 200)
    }

    @Test func nonSquareTargetKeepsRequestedBox() throws {
        // A 100×50 SVG rendered into a square box is letterboxed, not stretched.
        let image = try renderer.render(
            svgString: sampleSVG,
            targetSize: CGSize(width: 64, height: 64),
            scale: 1
        )
        #expect(image.width == 64)
        #expect(image.height == 64)
    }

    @Test func actuallyRasterizesPixels() throws {
        let image = try renderer.render(
            svgString: sampleSVG,
            targetSize: CGSize(width: 100, height: 50),
            scale: 1
        )
        let data = try #require(image.dataProvider?.data as Data?)
        // At least one pixel must be non-transparent — proves real rasterization.
        let hasDrawnPixel = stride(from: 3, to: data.count, by: 4).contains { data[$0] != 0 }
        #expect(hasDrawnPixel)
    }

    @Test func stringAndDataOverloadsAgree() throws {
        let fromString = try renderer.render(
            svgString: sampleSVG,
            targetSize: CGSize(width: 40, height: 40),
            scale: 1
        )
        let fromData = try renderer.render(
            svgData: Data(sampleSVG.utf8),
            targetSize: CGSize(width: 40, height: 40),
            scale: 1
        )
        #expect(fromString.width == fromData.width)
        #expect(fromString.height == fromData.height)
    }

    @Test func rendersBundledTestSVG() throws {
        let image = try renderer.render(
            svgData: try loadTestData("test"),
            targetSize: CGSize(width: 310, height: 236),
            scale: 2
        )
        #expect(image.width == 620)
        #expect(image.height == 472)
    }

    @Test func throwsOnEmptyData() {
        #expect(throws: NanoSVGError.emptyData) {
            try renderer.render(
                svgData: Data(), targetSize: CGSize(width: 10, height: 10), scale: 1)
        }
    }

    @Test func throwsOnUnparseableData() {
        // NanoSVG's parser is lenient: non-SVG bytes yield an empty, zero-dimension
        // image rather than a NULL result, which surfaces as invalidImageDimensions.
        #expect(throws: NanoSVGError.invalidImageDimensions) {
            try renderer.render(
                svgData: Data([0x00, 0x01, 0x02, 0x03]), targetSize: CGSize(width: 10, height: 10),
                scale: 1)
        }
    }

    @Test(arguments: [
        CGSize(width: 0, height: 10),
        CGSize(width: 10, height: 0),
    ])
    func throwsOnZeroTargetSize(size: CGSize) {
        #expect(throws: NanoSVGError.invalidTargetSize) {
            try renderer.render(svgString: sampleSVG, targetSize: size, scale: 1)
        }
    }

    @Test func throwsOnZeroScale() {
        #expect(throws: NanoSVGError.invalidTargetSize) {
            try renderer.render(
                svgString: sampleSVG, targetSize: CGSize(width: 10, height: 10), scale: 0)
        }
    }
}
