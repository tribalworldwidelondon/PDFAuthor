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

import XCTest
import CwlPreconditionTesting
import CoreGraphics

@testable import PDFAuthor

class PDFDocumentTests: XCTestCase {
    
    func testPDFBasicDocumentGeneration() throws {
        let document = PDFAuthorDocument()
        let pageSpecifications = PDFPageSpecifications(size: .A4)
        
        let a4Chapter = PDFChapter(pageSpecifications: pageSpecifications)
        document.addChapter(a4Chapter)
        
        // Add 3 blank pages with different background colors
        let colors: [PDFColor] = [ .red, .green, .blue ]
        for color in colors {
            a4Chapter.withNewPage {
                $0.backgroundColor = color
            }
        }
        
        let pdfName = String(describing: CFUUIDCreateString(nil, CFUUIDCreate(nil)!)!)
        let pdfPath = "/tmp/\(pdfName).pdf"
        try document.generate(to: URL(fileURLWithPath: pdfPath))
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: pdfPath), "PDF file cannot be found!")
        
        try FileManager.default.removeItem(atPath: pdfPath)
    }
    
    func testGeneratingDocumentWithInvalidURLThrowsError() {
        let document = PDFAuthorDocument()
        let invalidURL = URL(fileURLWithPath: "")
        
        XCTAssertThrowsError(try document.generate(to: invalidURL))
    }
    
    func testWith() {
        let document = PDFAuthorDocument()
        
        document.with {
            XCTAssertEqual(document, $0)
        }
    }
    
    func testGenerateDocumentOutline() {
        let document = PDFAuthorDocument()
        let pageSpecifications = PDFPageSpecifications(size: .A4)
        
        let chapter1 = PDFChapter(pageSpecifications: pageSpecifications)
        chapter1.outlineTitle = "Chapter 1"
        chapter1.withNewPage {
            $0.outlineTitle = "C1P1"
        }
        
        let chapter2 = PDFChapter(pageSpecifications: pageSpecifications)
        chapter2.outlineTitle = "Chapter 2"
        chapter2.withNewPage {
            $0.outlineTitle = "C2P1"
        }
        
        document.addChapter(chapter1)
        document.addChapter(chapter2)
        
        let outline = document.generateDocumentOutline()
        
        let expectedOutline: [String: Any] = [
            "Children": [
                ["Title": "Chapter 1",
                 "Destination": 1,
                 "DestinationRect": [
                    "X": 0,
                    "Y": 0,
                    "Width": 100,
                    "Height": 100
                    ],
                 "Children":[
                    ["Title": "C1P1",
                     "Destination": 1,
                     "DestinationRect": [
                        "X": 0,
                        "Y": 0,
                        "Width": 595,
                        "Height": 842
                        ]
                    ]
                    ],
                 ],
                ["Title": "Chapter 2",
                 "Destination": 2,
                 "DestinationRect": [
                    "X": 0,
                    "Y": 0,
                    "Width": 100,
                    "Height": 100
                    ],
                 "Children":[
                    ["Title": "C2P1",
                     "Destination": 2,
                     "DestinationRect": [
                        "X": 0,
                        "Y": 0,
                        "Width": 595,
                        "Height": 842
                        ]
                    ]
                    ],
                 ]
            ]
        ]
        XCTAssert(outline == expectedOutline)
    }
    
}
