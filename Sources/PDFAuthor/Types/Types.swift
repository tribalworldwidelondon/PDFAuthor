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


// MARK: PDFSizable

protocol PDFSizable {
    func sizeThatFits(size: CGSize) -> CGSize
    func sizeThatFits(width: CGFloat) -> CGSize
}


// MARK: - PDFPageSize

public struct PDFPageSize {
    public static let A0  =    PDFPageSize(width: 2384, height: 3370)
    public static let A1  =    PDFPageSize(width: 1684, height: 2384)
    public static let A2  =    PDFPageSize(width: 1191, height: 1684)
    public static let A3  =    PDFPageSize(width: 842,  height: 1191)
    public static let A4  =    PDFPageSize(width: 595,  height: 842)
    public static let A5  =    PDFPageSize(width: 420,  height: 595)
    public static let A6  =    PDFPageSize(width: 298,  height: 420)
    public static let A7  =    PDFPageSize(width: 210,  height: 298)
    public static let A8  =    PDFPageSize(width: 147,  height: 210)
    public static let A9  =    PDFPageSize(width: 105,  height: 147)
    public static let A10 =    PDFPageSize(width: 74,   height: 105)
    public static let letter = PDFPageSize(width: 612,  height: 792)
    
    public static let A0Landscape     = landscape(A0)
    public static let A1Landscape     = landscape(A1)
    public static let A2Landscape     = landscape(A2)
    public static let A3Landscape     = landscape(A3)
    public static let A4Landscape     = landscape(A4)
    public static let A5Landscape     = landscape(A5)
    public static let A6Landscape     = landscape(A6)
    public static let A7Landscape     = landscape(A7)
    public static let A8Landscape     = landscape(A8)
    public static let A9Landscape     = landscape(A9)
    public static let A10Landscape    = landscape(A10)
    public static let letterLandscape = landscape(letter)
    
    internal static func landscape(_ portraitSize: PDFPageSize) -> PDFPageSize {
        return PDFPageSize(width: portraitSize.height, height: portraitSize.width)
    }
    
    public let width: CGFloat
    public let height: CGFloat
    
    public var cgSize: CGSize {
        return CGSize(width: width, height: height)
    }
    
    public init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
    }
}


// MARK: PDFEdgeInsets

public struct PDFEdgeInsets {
    public var top: CGFloat
    public var left: CGFloat
    public var bottom: CGFloat
    public var right: CGFloat
    
    public static let zero = PDFEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    public init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
}


// MARK: PDFPageSpecifications

public struct PDFPageSpecifications {
    public var backgroundInsets: PDFEdgeInsets
    public var contentInsets: PDFEdgeInsets
    public var size: PDFPageSize
    
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

public struct PDFAutoresizing: OptionSet {
    public let rawValue: Int
    
    public static let flexibleWidth = PDFAutoresizing(rawValue: 1 << 0)
    public static let flexibleHeight = PDFAutoresizing(rawValue: 1 << 1)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}


// MARK: - PDFLayoutPriority

public enum PDFLayoutPriority {
    case required
    case high
    case low
    
    public var constraintStrength: Double {
        switch self {
        case .required: return Strength.REQUIRED
        case .high: return Strength.STRONG
        case .low: return Strength.WEAK
        }
    }
}
