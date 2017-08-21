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
    public typealias PDFFont = NSFont
#elseif os(iOS)
    import UIKit
    public typealias PDFFont = UIFont
#endif

/// A PDF region that renders and NSAttributedString
public class StringRegion: PDFRegion {
    /// The attributed string that this region will draw
    public var attributedString: NSAttributedString?
    
    
#if os(OSX)
    public typealias PDFAuthorStringDrawingOptions = NSString.DrawingOptions
#else
    public typealias PDFAuthorStringDrawingOptions = NSStringDrawingOptions
#endif
    
    /// The drawing options of the string
    public var drawingOptions: PDFAuthorStringDrawingOptions = []
    
    /// The preferred maximum width for the String Region
    public var preferredMaxLayoutWidth: CGFloat?
    
    internal override var suggestedVariableValues: [(variable: Variable, strength: Double, value: Double)] {
        guard attributedString != nil else {
            return super.suggestedVariableValues
        }
        
        let size = self.intrinsicContentSize() ?? .zero
        
        // Override parent's width + height suggested values
        let suggested = super.suggestedVariableValues.filter { $0.variable != width && $0.variable != height }
        
        return suggested + [(width, Strength.WEAK, Double(size.width)), (height, Strength.STRONG, Double(size.height))]
    }
    
    // MARK: Initializers
    
    /// Initialize with the given NSAttributedString
    public init(attributedString: NSAttributedString) {
        self.attributedString = attributedString
        
        super.init(frame: .zero)
    }
    
    /// Initialize with the given String and a dictionary of attributes
    public convenience init(string: String, attributes: [NSAttributedStringKey: Any]) {
        self.init(attributedString: NSAttributedString(string: string, attributes: attributes))
    }
    
    /// Initialize with a string, font, text color and text alignment
    public convenience init(string: String, font: PDFFont, color: PDFColor, alignment: NSTextAlignment) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment
        
        let attributes: [NSAttributedStringKey: Any] = [
            .font: font as CTFont,
            .foregroundColor: color.cgColor,
            .paragraphStyle: paragraphStyle
        ]
        
        self.init(string: string, attributes: attributes)
    }
    
    /// Initialize with a string, font and text color
    public convenience init(string: String, font: PDFFont, color: PDFColor) {
        let attributes: [NSAttributedStringKey: Any] = [
            .font: font as CTFont,
            .foregroundColor: color.cgColor
        ]
        
        self.init(string: string, attributes: attributes)
    }
    
    /// Initialize with a string and text color
    public convenience init(string: String, color: PDFColor) {
        let attributes: [NSAttributedStringKey: Any] = [
            .foregroundColor: color.cgColor
        ]
        
        self.init(string: string, attributes: attributes)
    }
    
    /// Initialize with a string and font
    public convenience init(string: String, font: PDFFont) {
        let attributes: [NSAttributedStringKey: Any] = [
            .font: font as CTFont
        ]
        
        self.init(string: string, attributes: attributes)
    }
    
    /// Initialize with a string
    public convenience init(string: String) {
        self.init(attributedString: NSAttributedString(string: string))
    }
    
    // MARK: Drawing
    
    /// :nodoc:
    public override func draw(withContext context: CGContext, inRect rect: CGRect) {
        guard let str = attributedString else {
            return
        }
        
        let transformedRect = CGRect(x: rect.origin.x + edgeInsets.left,
                                     y: rect.origin.y + edgeInsets.top,
                                     width: rect.width - edgeInsets.left - edgeInsets.right,
                                     height: rect.height - edgeInsets.top - edgeInsets.bottom)
        let path = CGPath(rect: transformedRect, transform: nil)
        let frameSetter = CTFramesetterCreateWithAttributedString(str as CFAttributedString)
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
        
        context.saveGState()
        
        // Need to do some matrix transforms here, because core text seems to render upside down by default
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -bounds.height + edgeInsets.bottom)
        context.textMatrix = CGAffineTransform.identity
        
        CTFrameDraw(frame, context)
        context.restoreGState()
    }
    
    /// Returns the size of the region when constrained to a certain width
    public func size(constrainedToWidth width: CGFloat) -> CGSize {
        guard let str = attributedString else {
            return .zero
        }
        
        let frameSetter = CTFramesetterCreateWithAttributedString(str as CFAttributedString)
        let suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter,
                                                                         CFRangeMake(0, 0),
                                                                         nil,
                                                                         CGSize(width: width - edgeInsets.left - edgeInsets.right, height: .greatestFiniteMagnitude),
                                                                         nil)
        return CGSize(width: width, height: suggestedSize.height + 10 + edgeInsets.top + edgeInsets.bottom)
    }
    
    /// :nodoc:
    public override func intrinsicContentSize() -> CGSize? {
        if let width = preferredMaxLayoutWidth {
            return size(constrainedToWidth: width)
        }
        
        guard let str = attributedString else {
            return .zero
        }

        let frameSetter = CTFramesetterCreateWithAttributedString(str as CFAttributedString)
        
        var width = (self.width.value > 0) ? CGFloat(self.width.value): CGFloat.greatestFiniteMagnitude
        width -= edgeInsets.left + edgeInsets.right
        
        let maxSize = CGSize(width: width,
                             height: .greatestFiniteMagnitude)
        var suggestedSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter,
                                                                         CFRangeMake(0, 0),
                                                                         nil,
                                                                         maxSize,
                                                                         nil)
        suggestedSize.height += edgeInsets.top + edgeInsets.bottom
        return suggestedSize
    }
}
