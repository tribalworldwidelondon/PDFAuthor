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
import PDFAuthor
import Cassowary

import AppKit

let start = Date()

var pageSpecifications = PDFPageSpecifications(size: .A4)
pageSpecifications.contentInsets = PDFEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)
pageSpecifications.backgroundInsets = PDFEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

let document = PDFAuthorDocument().with {
    $0.addChapter(TitleChapter(pageSpecifications: pageSpecifications))
    $0.addChapter(MaskChapter(pageSpecifications: pageSpecifications))
    $0.addChapter(PhoneBillChapter(pageSpecifications: pageSpecifications))
    $0.addChapter(TextColumnsChapter(pageSpecifications: pageSpecifications))
}

try document.generate(to: URL(fileURLWithPath: ("~/Desktop/test1.pdf" as NSString).expandingTildeInPath)) { progress in
    print ("Progress : \(Int(progress * 100))%")
}

let elapsed = Date().timeIntervalSince(start)
print("Demo document produced in \(elapsed) seconds.")
