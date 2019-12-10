/*
 MIT License

 Copyright (c) 2017 Tribal Worldwide London

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation
import Cassowary
import CoreText

#if os(OSX)
	import AppKit
#elseif os(iOS)
	import UIKit
#endif

/// A PDF region that renders a String in multiple columns
public final class MultiColumnStringRegion: PDFRegion {
	/// The string that this region will draw
	public var  string:           String?

	/// The font that this region will use
	public var  font:             PDFFont?

	/// The color of the text
	public var  textColor:        PDFColor?

	/// The alignment of the text
	public var  textAlignment:    NSTextAlignment?

	/// The number of columns to use
	public var  numColumns:       UInt {
		willSet {
			guard newValue > 0 else {
				preconditionFailure("Number of columns must be 1 or more")
			}
		}
	}

	/// The spacing between each column
	public var  columnSpacing:    CGFloat = 10

	/// Create an attributed string from the string
	private var attributedString: NSAttributedString? {
		guard let string = string else {
			return nil
		}

		var attributes: [NSAttributedString.Key: Any] = [:]

		if let textColor = textColor {
			attributes[.foregroundColor] = textColor.cgColor
		}

		if let font = font {
			attributes[.font] = font as CTFont
		}

		if let textAlignment = textAlignment {
			let style = NSMutableParagraphStyle()
			style.alignment = textAlignment
			attributes[.paragraphStyle] = style
		}

		return NSAttributedString(string: string, attributes: attributes)
	}

	#if os(OSX)
		public typealias PDFAuthorStringDrawingOptions = NSString.DrawingOptions
	#else
		public typealias PDFAuthorStringDrawingOptions = NSStringDrawingOptions
	#endif

	/// The drawing options of the string
	public var drawingOptions:          PDFAuthorStringDrawingOptions = []

	/// The preferred maximum width for the String Region
	public var preferredMaxLayoutWidth: CGFloat?

	internal override var suggestedVariableValues: [(variable: Variable, strength: Double, value: Double)] {
		guard string != nil else {
			return super.suggestedVariableValues
		}

		let size = self.intrinsicContentSize() ?? .zero

		// Override parent's width + height suggested values
		let suggested = super.suggestedVariableValues.filter {
			$0.variable != width && $0.variable != height
		}

		return suggested + [(width, Strength.WEAK, Double(size.width)), (height, Strength.STRONG, Double(size.height))]
	}

	// MARK: Initializers

	/// Initialize with a string, font, text color, text alignment and number of columns
	public init(string: String,
				font: PDFFont = PDFFont.systemFont(ofSize: PDFFont.systemFontSize),
				color: PDFColor = .black,
				alignment: NSTextAlignment = .left,
				numColumns: UInt = 1) {

		self.string = string
		self.font = font
		self.textColor = color
		self.textAlignment = alignment
		self.numColumns = numColumns
		super.init()
	}

	// MARK: Drawing

	/// :nodoc:
	public override func draw(withContext context: CGContext, inRect rect: CGRect) {
		guard let str = attributedString else {
			return
		}

		let paths = createColumnPaths(forSize: rect.size)

		context.saveGState()

		context.scaleBy(x: 1.0, y: -1.0)
		context.translateBy(x: 0, y: -bounds.height)
		context.textMatrix = .identity

		let framesetter = CTFramesetterCreateWithAttributedString(str as CFAttributedString)
		var startIndex  = 0

		for path in paths {
			let frame = CTFramesetterCreateFrame(
					framesetter,
					CFRange(location: startIndex, length: 0),
					path,
					nil)
			CTFrameDraw(frame, context)

			let frameRange = CTFrameGetVisibleStringRange(frame)
			startIndex += frameRange.length
		}

		context.restoreGState()
	}

	private func createColumnPaths(forSize size: CGSize) -> [CGPath] {
		let columnWidth = (size.width - (CGFloat(numColumns - 1) * columnSpacing)) / CGFloat(numColumns)

		var paths: [CGPath] = []

		for i in 0..<numColumns {
			paths.append(CGPath(
					rect: CGRect(x: (CGFloat(i) * columnWidth) + (CGFloat(i) * columnSpacing),
								 y: 0,
								 width: columnWidth,
								 height: size.height),
					transform: nil))
		}

		return paths
	}

	private func calculateColumnHeights(forWidth width: CGFloat) -> CGFloat {
		guard let attributedString = attributedString else {
			return 0
		}

		// Firstly, calculate the height with one long column
		let scSize              = singleColumnSize(constrainedToWidth: width)

		// A good first guess is slightly under the height of the text if it were using a single column
		var estimatedHeight     = ceil(scSize.height * 0.95)
		var remainingCharacters = attributedString.length

		var iterations = 0

		while remainingCharacters > 0 {
			remainingCharacters = attributedString.length

			let columnSize  = CGSize(width: width, height: estimatedHeight)
			let columnPaths = createColumnPaths(forSize: columnSize)

			var currentStringIndex = 0
			for path in columnPaths {
				let frameSetter = CTFramesetterCreateWithAttributedString(attributedString as CFAttributedString)
				let frame       = CTFramesetterCreateFrame(
						frameSetter,
						CFRange(location: currentStringIndex,
								length: 0),
						path,
						nil)
				let range       = CTFrameGetVisibleStringRange(frame)
				currentStringIndex = range.location + range.length
				remainingCharacters -= range.length
			}

			if remainingCharacters < 1 {
				print("Iterations: \(iterations)")
				return estimatedHeight
			}

			// Not all of the characters fit- add to the estimated height and try again.
			if let font = font {
				#if os(OSX)
					let lineHeight = font.ascender + abs(font.descender) + font.leading
				#elseif os(iOS)
					let lineHeight = font.lineHeight
				#endif
				estimatedHeight += lineHeight
			} else {
				estimatedHeight += 2
			}

			iterations += 1
		}

		print("Iterations: \(iterations)")

		return estimatedHeight
	}

	private func singleColumnSize(constrainedToWidth width: CGFloat) -> CGSize {
		guard let str = attributedString else {
			return .zero
		}

		let frameSetter   = CTFramesetterCreateWithAttributedString(str as CFAttributedString)
		let suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter,
																		 CFRangeMake(0, 0),
																		 nil,
																		 CGSize(width: width - edgeInsets.left - edgeInsets.right,
																				height: .greatestFiniteMagnitude),
																		 nil)
		return CGSize(width: width, height: suggestedSize.height + 10 + edgeInsets.top + edgeInsets.bottom)
	}

	/// Returns the size of the region when constrained to a certain width
	private func size(constrainedToWidth width: CGFloat) -> CGSize {
		let height = calculateColumnHeights(forWidth: width)
		return CGSize(width: width, height: height)
	}

	/// :nodoc:
	public override func intrinsicContentSize() -> CGSize? {
		if let width = preferredMaxLayoutWidth {
			return size(constrainedToWidth: width)
		}

		guard attributedString != nil else {
			return .zero
		}

		var width = (self.width.value > 0) ? CGFloat(self.width.value) : CGFloat.greatestFiniteMagnitude
		width -= edgeInsets.left + edgeInsets.right

		return size(constrainedToWidth: width)
	}
}
