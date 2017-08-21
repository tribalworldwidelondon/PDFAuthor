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
import CoreGraphics

#if os(OSX)
    import Quartz
#endif

public class PDFAuthorDocument {
    
    private var _chapters: [PDFChapter] = []
    public var chapters: [PDFChapter] {
        return _chapters
    }
    
    public init() {
        
    }
    
    public func generate(to url: URL) throws {
        guard let pdfContext = CGContext(url as CFURL, mediaBox: nil, nil) else {
            throw PDFError.cannotCreateDocument
        }
        
        for chapter in chapters {
            chapter.generate()
            
            for page in chapter.pages {
                page.render(toContext: pdfContext)
            }
        }
        
        pdfContext.flush()
        pdfContext.closePDF()
        
        // Generate document outline on supported platforms
        if #available(OSX 10.4, *), #available(iOS 11, *) {
            guard let doc = PDFDocument(url: url) else {
                print("Unable to generate document outline!")
                return
            }
            
            let o = generateOutlineObject(forDocument: doc)
            doc.outlineRoot = o
            doc.write(to: url)
        }
    }
    
    @available(iOS 11, *)
    @available(OSX 10.4, *)
    private func generateOutlineObject(forDocument document: PDFDocument) -> PDFOutline? {
        let outlineDict = generateDocumentOutline()
        
        return recursiveOutlineObject(outlineDict: outlineDict, document: document)
    }
    
    @available(iOS 11, *)
    @available(OSX 10.4, *)
    public final func recursiveOutlineObject(outlineDict: [String: Any], document: PDFDocument) -> PDFOutline? {
        let o = PDFOutline()
        
        if let title = outlineDict["Title"] as? String,
            let destination = outlineDict["Destination"] as? Int,
            let destinationRect = outlineDict["DestinationRect"] as? [String: CGFloat],
            let dX = destinationRect["X"], let dY = destinationRect["Y"] {
            o.label = title
            let page = document.page(at: destination - 1)!
            let bounds = page.bounds(for: PDFDisplayBox.mediaBox)
            // Coordinate system is reversed
            o.destination = PDFDestination(page: page, at: CGPoint(x: dX, y: bounds.height - dY))
            
        }
        
        if let children = outlineDict["Children"] as? [[String: Any]] {
            let outlineChildren = children.map { recursiveOutlineObject(outlineDict: $0, document: document)}
            
            for c in outlineChildren {
                if c != nil {
                    o.insertChild(c!, at: o.numberOfChildren )
                }
            }
        }
        
        return o
    }
    
    public func generateDocumentOutline() -> [String: Any] {
        var pageNum = 1
        var outlines: [[String: Any]] = []
        
        for chapter in chapters {
            let(numPages, outline) = chapter.outline(withStartingPage: pageNum)
            outlines.append(contentsOf: outline)
            pageNum += numPages
        }
        
        let outline = [
            "Children": outlines
        ]
        
        return outline
    }
    
    // MARK: Chapter Management
    
    public func addChapter(_ chapter: PDFChapter) {
        _chapters.append(chapter)
    }
    
    @discardableResult
    public func with(_ withFunc: (inout PDFAuthorDocument) -> Void) -> PDFAuthorDocument {
        var this = self
        withFunc(&this)
        return self
    }
}

// MARK: - Equatable
extension PDFAuthorDocument: Equatable {
    public static func ==(lhs: PDFAuthorDocument, rhs: PDFAuthorDocument) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

// MARK: - Hashable
extension PDFAuthorDocument: Hashable {
    public var hashValue: Int {
        // Return a hash 'unique' to this object
        return ObjectIdentifier(self).hashValue
    }
}
