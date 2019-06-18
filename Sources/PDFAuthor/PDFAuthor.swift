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
#elseif os(iOS)
import PDFKit
#endif

/// A class representing a PDF document holding a number of chapters
public final class PDFAuthorDocument {
    
    /// An enum specifying the way in which documents get generated
    public enum GenerationMethod {
        /// Generate the document on one thread, using a single CGContext
        case serial
        
        /// Generate the document in parallel on multiple threads, using multiple CGContexts,
        /// stitching the pages together afterwards.
        case parallel
    }
    
    private(set) var chapters: [PDFChapter] = []
    
    /// Initialize a new document
    public init() {
        
    }
    
    private func generateSerially(to url: URL, auxiliaryDict: CFDictionary? = nil, progressCallback: ((Double) -> Void)? = nil) throws {
        // Chapter generation is 0%-50% progress
        let chapterProgressStep = 0.5 / Double(chapters.count)
        
        var progress = 0.0
        
        for chapter in chapters {
            chapter.generate()
            progress += chapterProgressStep
            if progressCallback != nil {
                progressCallback!(progress)
            }
        }
        
        let numPages = chapters.reduce(0) {
            $0 + $1.pages.count
        }
        
        // Page rendering is 50%-100% of progress
        let pageProgressStep = 0.5 / Double(numPages)
        
        guard let context = CGContext(url as CFURL, mediaBox: nil, auxiliaryDict) else {
            return
        }
        
        for chapter in chapters {
            for page in chapter.pages {
                page.render(toContext: context)
                
                progress += pageProgressStep
                if let cb = progressCallback {
                    cb(progress)
                }
            }
        }
        
        context.flush()
        context.closePDF()
        
        // Generate document outline on supported platforms
        if #available(OSX 10.4, iOS 11, *) {
            guard let doc = PDFDocument(url: url) else {
                print("Unable to generate document outline!")
                return
            }
            
            let o = generateOutlineObject(forDocument: doc)
            doc.outlineRoot = o
            doc.write(to: url)
        }
    }
    
    /**
     Generate the PDF document and save it to the given URL.
     - parameters:
     - url: The URL at which to save the generated document
     - progressCallback: A callback that takes a Double argument, which is the progress of the PDF
     generation represented by a value between 0 and 1.
     */
    public func generate(to url: URL, auxiliaryDict: CFDictionary? = nil, method: GenerationMethod = .parallel, progressCallback: ((Double) -> Void)? = nil) throws {
        if method == .serial {
            try generateSerially(to: url, auxiliaryDict: auxiliaryDict, progressCallback: progressCallback)
            return
        }
        
        // Chapter generation is 0%-50% progress
        let chapterProgressStep = 0.5 / Double(chapters.count)
        
        var progress = 0.0
        
        for chapter in chapters {
            chapter.generate()
            progress += chapterProgressStep
            if progressCallback != nil {
                progressCallback!(progress)
            }
        }
        
        let numPages = chapters.reduce(0) {
            $0 + $1.pages.count
        }
        
        // Page rendering is 50%-100% of progress
        let pageProgressStep = 0.5 / Double(numPages)
        
        var renderOperations: [Operation] = []
        var pageURLs: [URL] = []
        
        let semaphore = DispatchSemaphore(value: 1)
        
        for (chapterIdx, chapter) in chapters.enumerated() {
            for (pageIdx, page) in chapter.pages.enumerated() {
                let tempURL: URL
                
                if #available(iOS 10, OSX 10.12, *) {
                    tempURL = FileManager.default.temporaryDirectory
                } else {
                    tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
                }
                
                let pageURL = tempURL.appendingPathComponent("brochure_\(chapterIdx)_\(pageIdx)")
                    .appendingPathExtension("pdf")
                
                pageURLs.append(pageURL)
                
                let operation = BlockOperation {
                    guard let pageContext = CGContext(pageURL as CFURL, mediaBox: nil, auxiliaryDict) else {
                        return
                    }
                    
                    page.render(toContext: pageContext)
                    
                    pageContext.flush()
                    pageContext.closePDF()
                    
                    semaphore.wait()
                    progress += pageProgressStep
                    if let cb = progressCallback {
                        cb(progress)
                    }
                    semaphore.signal()
                }
                
                renderOperations.append(operation)
            }
        }
        
        // Generate pages in parallel
        let queue = OperationQueue()
        queue.addOperations(renderOperations, waitUntilFinished: true)
        
        guard let pdfContext = CGContext(url as CFURL, mediaBox: nil, auxiliaryDict) else {
            throw PDFError.cannotCreateDocument
        }
        
        // Merge pages into one PDF
        for pageURL in pageURLs {
            guard let doc = CGPDFDocument(pageURL as CFURL) else {
                print("Unable to load PDF page at \(pageURL)")
                throw PDFError.cannotCreateDocument
            }
            
            for pageIdx in 1...doc.numberOfPages {
                guard let sourcePage = doc.page(at: pageIdx) else {
                    throw PDFError.cannotCreateDocument
                }
                
                var sourceMediaBox = sourcePage.getBoxRect(CGPDFBox.mediaBox)
                pdfContext.beginPage(mediaBox: &sourceMediaBox)
                pdfContext.drawPDFPage(sourcePage)
                pdfContext.endPage()
            }
        }
        
        pdfContext.flush()
        pdfContext.closePDF()
        
        
        // Delete temp files
        
        for pageURL in pageURLs {
            try? FileManager.default.removeItem(at: pageURL)
        }
        
        // Generate document outline on supported platforms
        if #available(OSX 10.4, iOS 11, *) {
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
    private final func recursiveOutlineObject(outlineDict: [String: Any], document: PDFDocument) -> PDFOutline? {
        let o = PDFOutline()
        
        if let title = outlineDict["Title"] as? String,
            let destination = outlineDict["Destination"] as? Int,
            let destinationRect = outlineDict["DestinationRect"] as? [String: Any],
            let dX = destinationRect["X"] as? CGFloat, let dY = destinationRect["Y"] as? CGFloat {
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
    
    internal func generateDocumentOutline() -> [String: Any] {
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
    
    /// Add a chapter to the document
    public func addChapter(_ chapter: PDFChapter) {
        chapters.append(chapter)
    }
    
    /// Calls the given closure with the document as an argument
    @discardableResult
    public func with(_ withFunc: (inout PDFAuthorDocument) -> Void) -> PDFAuthorDocument {
        var this = self
        withFunc(&this)
        return self
    }
}

// MARK: - Equatable
extension PDFAuthorDocument: Equatable {
    /// :nodoc:
    public static func ==(lhs: PDFAuthorDocument, rhs: PDFAuthorDocument) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

// MARK: - Hashable
extension PDFAuthorDocument: Hashable {
    /// :nodoc:
    public var hashValue: Int {
        // Return a hash 'unique' to this object
        return ObjectIdentifier(self).hashValue
    }
}
