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

open class PDFChapter {
    var pageSpecifications: PDFPageSpecifications
    var outlineTitle: String?
    internal var pages: [PDFPage]
    
    public init(pageSpecifications: PDFPageSpecifications) {
        self.pageSpecifications = pageSpecifications
        pages = []
    }
    
    // MARK: Page Management
    
    public func addPage(_ page: PDFPage) {
        pages.append(page)
    }
    
    public func addNewPage() -> PDFPage {
        let page = PDFPage(specifications: pageSpecifications)
        addPage(page)
        return page
    }
    
    @discardableResult
    public func withNewPage(pageFunc: (PDFPage)->(Void)) -> PDFPage {
        let page = addNewPage()
        pageFunc(page)
        return page
    }
    
    // MARK: Rendering
    
    internal func outline(withStartingPage pageNum: Int) -> (numPages: Int, outline: [[String: Any]]) {
        var outlines: [[String: Any]] = []
        var currentPage = pageNum
        
        for page in pages {
            if let outline = page.recursiveOutline(origin: .zero, pageNum: currentPage) {
                outlines.append(outline)
            }
            currentPage += 1
        }
        
        if let title = outlineTitle {
            let outline = [
                "Destination": pageNum,
                "DestinationRect": [
                    "Width": 100,
                    "Height": 100,
                    "X": 0,
                    "Y": 0
                ],
                "Title": title as Any,
                "Children": outlines
            ]
            return (numPages: currentPage - pageNum, outline: [outline])
        }
        
        return (numPages: currentPage - pageNum, outline: outlines)
    }
    
    // MARK: Dynamic Generation
    
    /**
     Override this function if the chapter needs to dynamically generate pages
     */
    public func generate() {
        
    }
}
