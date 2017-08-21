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

#if os(OSX)
    import AppKit
#elseif os(iOS)
    import UIKit
#endif

/// A class representing a page in a PDF document.
public class PDFPage: PDFRegion {
    
    internal var specifications: PDFPageSpecifications
    internal var backgroundInsets: PDFEdgeInsets
    
    // MARK: Initialization
    
    /// Initialize the page with the given specifications.
    init(specifications: PDFPageSpecifications) {
        self.specifications = specifications
        self.backgroundInsets = specifications.backgroundInsets
        super.init(frame: CGRect(x: 0,
                                 y: 0,
                                 width: specifications.size.width,
                                 height: specifications.size.height))
        self.edgeInsets = specifications.contentInsets
    }
    
    // MARK: Drawing
    
    internal func render(toContext context: CGContext) {
        // This is the root, so we need to constrain the edges
        self.addConstraints(self.left == Double(frame.origin.x),
                            self.top == Double(frame.origin.y),
                            self.width == Double(frame.width),
                            self.height == Double(frame.height))
        
        var mediaBox = self.bounds
        let boxData = Data(bytes: &mediaBox, count: MemoryLayout.size(ofValue: mediaBox))
        let pageInfo = [ kCGPDFContextMediaBox as String: boxData ]
        context.beginPDFPage(pageInfo as NSDictionary)
        
        // The current context *must* be set so that certain drawing routines work
        // e.g. NSAttributedString.draw
        #if os(OSX)
            let ctx = NSGraphicsContext(cgContext: context, flipped: false)
            NSGraphicsContext.current = ctx
        #elseif os(iOS)
            UIGraphicsPushContext(context)
        #endif
        
        context.saveGState()
        // Flip y, so that 0,0 is at the top left
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0, y: -specifications.size.height)
        
        updateConstraints()
        
        var drawRegions: Set<PDFRegion> = []
        drawRecursive(withContext: context, inRect: self.bounds, drawnRegions: &drawRegions)
        
        context.restoreGState()
        
        #if os(OSX)
            NSGraphicsContext.current = nil
        #elseif os(iOS)
            UIGraphicsPopContext()
        #endif
        
        context.endPDFPage()
    }
}
