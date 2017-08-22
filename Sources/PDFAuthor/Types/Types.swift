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


// MARK: PDFOutlinable

protocol PDFOutlinable {
    // If this is set, an entry will be added to the document outline on supported platforms
    var outlineTitle: String? { get set }
}

// MARK: - PDFPageSize

/// A structure representing the size of a PDF Page
public struct PDFPageSize {
    /// A0 page size
    public static let A0  =    PDFPageSize(width: 2384, height: 3370)
    
    /// A1 page size
    public static let A1  =    PDFPageSize(width: 1684, height: 2384)
    
    /// A2 page size
    public static let A2  =    PDFPageSize(width: 1191, height: 1684)
    
    /// A3 page size
    public static let A3  =    PDFPageSize(width: 842,  height: 1191)
    
    /// A4 page size
    public static let A4  =    PDFPageSize(width: 595,  height: 842)
    
    /// A5 page size
    public static let A5  =    PDFPageSize(width: 420,  height: 595)
    
    /// A6 page size
    public static let A6  =    PDFPageSize(width: 298,  height: 420)
    
    /// A7 page size
    public static let A7  =    PDFPageSize(width: 210,  height: 298)
    
    /// A8 page size
    public static let A8  =    PDFPageSize(width: 147,  height: 210)
    
    /// A9 page size
    public static let A9  =    PDFPageSize(width: 105,  height: 147)
    
    /// A10 page size
    public static let A10 =    PDFPageSize(width: 74,   height: 105)
    
    /// Letter page size
    public static let letter = PDFPageSize(width: 612,  height: 792)
    
    /// A0 landscape page size
    public static let A0Landscape     = landscape(A0)
    
    /// A1 landscape page size
    public static let A1Landscape     = landscape(A1)
    
    /// A2 landscape page size
    public static let A2Landscape     = landscape(A2)
    
    /// A3 landscape page size
    public static let A3Landscape     = landscape(A3)
    
    /// A4 landscape page size
    public static let A4Landscape     = landscape(A4)
    
    /// A5 landscape page size
    public static let A5Landscape     = landscape(A5)
    
    /// A6 landscape page size
    public static let A6Landscape     = landscape(A6)
    
    /// A7 landscape page size
    public static let A7Landscape     = landscape(A7)
    
    /// A8 landscape page size
    public static let A8Landscape     = landscape(A8)
    
    /// A9 landscape page size
    public static let A9Landscape     = landscape(A9)
    
    /// A10 landscape page size
    public static let A10Landscape    = landscape(A10)
    
    /// Letter landscape page size
    public static let letterLandscape = landscape(letter)
    
    internal static func landscape(_ portraitSize: PDFPageSize) -> PDFPageSize {
        return PDFPageSize(width: portraitSize.height, height: portraitSize.width)
    }
    
    /// The width of the page in points
    public let width: CGFloat
    
    /// The height of the page in points
    public let height: CGFloat
    
    /// The size of the page represented as a CGSize
    public var cgSize: CGSize {
        return CGSize(width: width, height: height)
    }
    
    /// Initialize a page size with the given width and height
    public init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
    }
}


// MARK: PDFEdgeInsets

/// A structure representing the edge insets of a PDF Region or Page
public struct PDFEdgeInsets {
    /// The top edge inset
    public var top: CGFloat
    
    /// The left edge inset
    public var left: CGFloat
    
    /// The bottom edge inset
    public var bottom: CGFloat
    
    /// The right edge inset
    public var right: CGFloat
    
    /// Edge insets initialized to (0, 0, 0, 0)
    public static let zero = PDFEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    /// Initialize edge insets with the given top, left, bottom and right values
    public init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
}


// MARK: PDFPageSpecifications

/// A structure holding the specifications of a PDF page
public struct PDFPageSpecifications {
    /// The background insets of the page
    public var backgroundInsets: PDFEdgeInsets
    
    /// The content insets of the page
    public var contentInsets: PDFEdgeInsets
    
    /// The size of the page
    public var size: PDFPageSize
    
    /// Initialize with the given size
    public init(size: PDFPageSize) {
        backgroundInsets = .zero
        contentInsets = .zero
        self.size = size
    }
}


// MARK: - PDFColor

#if os(OSX)
    import AppKit
    
    public typealias PDFColor = NSColor
#elseif os(iOS)
    import UIKit
    
    public typealias PDFColor = UIColor
#endif


// MARK: - PDFAutoresizing

/// An OptionSet representing the autoresizingmask of a PDF region
public struct PDFAutoresizing: OptionSet {
    public let rawValue: Int
    
    /// Resizing performed by expanding or shrinking a region's width.
    public static let flexibleWidth = PDFAutoresizing(rawValue: 1 << 0)
    
    /// Resizing performed by expanding or shrinking a region's height.
    public static let flexibleHeight = PDFAutoresizing(rawValue: 1 << 1)
    
    /// Initialize with a raw value.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}


// MARK: - PDFLayoutPriority

/// Layout priority.
public enum PDFLayoutPriority {
    /// Required priority/
    case required
    
    /// High priority.
    case high
    
    /// Low priority.
    case low
    
    /// Generates a Cassowary constraint strength from layout priority.
    public var constraintStrength: Double {
        switch self {
        case .required: return Strength.REQUIRED
        case .high: return Strength.STRONG
        case .low: return Strength.WEAK
        }
    }
}


/// The type of mask used by a PDFRegion.
public enum PDFMaskType {
    /// A mask that clips to the bounds of the region.
    case bounds
    
    /// A rectangle mask, with coordinates relative to the region's coordinate space.
    case rect(CGRect)
    
    /// A mask made up of an array of rectangles, with coordinates relative to the region's coordinate space.
    case rects([CGRect])
    
    /// A mask using an image, using coordinates specified by the rect, relative to the region's coordinate space.
    case image(PDFImage, CGRect)
    
    /// A mask using a CGPath
    case path(CGPath)
}
