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

class DemoChapter: PDFChapter {
    override init(pageSpecifications: PDFPageSpecifications) {
        super.init(pageSpecifications: pageSpecifications)
    }
    
    override func generate() {
        withNewPage {
            $0.backgroundColor = PDFColor(white: 0.95, alpha: 1.0)
            
            let titleRegion = StringRegion(string: "Stack Region Demo",
                                           font: PDFFont.boldSystemFont(ofSize: 24),
                                           color: PDFColor(white: 0.1, alpha: 1.0))
            
            $0.addChild(titleRegion)
            
            let distributions: [StackRegionDistribution] = [
                .fill,
                .fillEqually,
                .fillProportionally,
                .equalCentering,
                .equalSpacing
            ]
            
            $0.addConstraints(titleRegion.top == $0.topInset,
                              titleRegion.left == $0.leftInset,
                              titleRegion.right == $0.rightInset)
            
            var lastRegion: PDFRegion = titleRegion
            
            for d in distributions {
                let title = StringRegion(string: String(describing: d))
                $0.addChild(title)
                
                title.addConstraints(title.left == $0.leftInset,
                                     title.right == $0.rightInset,
                                     title.top == lastRegion.bottom + 20)
                
                let sr = testStackRegion()
                sr.alignment = .center
                sr.axis = .horizontal
                sr.distribution = d
                sr.backgroundColor = PDFColor(white: 0.8, alpha: 1.0)
                sr.addConstraint(sr.height == 50)
                
                sr.addConstraints(sr.left == $0.leftInset,
                                  sr.right == $0.rightInset,
                                  sr.top == title.bottom)
                
                $0.addChild(sr)
                
                lastRegion = sr
            }
            
            $0.addConstraint(lastRegion.bottom <= $0.bottom)
        }
    }
    
    func testRegions() -> [PDFRegion] {
        let r1 = PDFRegion()
        r1.backgroundColor = .red
        r1.addConstraints((r1.width == 50).setStrength(Strength.WEAK))
        
        let r2 = PDFRegion()
        r2.backgroundColor = .green
        r2.addConstraints((r2.width == 70).setStrength(Strength.WEAK))
        
        let r3 = PDFRegion()
        r3.backgroundColor = .blue
        r3.addConstraints((r3.width == 30).setStrength(Strength.WEAK))
        
        let r4 = PDFRegion()
        r4.backgroundColor = .purple
        r4.addConstraints((r4.width == 80).setStrength(Strength.WEAK))
        
        return [r1, r2, r3, r4]
    }
    
    func testStackRegion() -> StackRegion {
        return StackRegion(arrangedRegions: self.testRegions())
    }
}

func main() {
    var pageSpecifications = PDFPageSpecifications(size: .A4)
    pageSpecifications.contentInsets = PDFEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)
    pageSpecifications.backgroundInsets = PDFEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    let document = PDFAuthorDocument()
    document.addChapter(DemoChapter(pageSpecifications: pageSpecifications))
    
    do {
        try document.generate(to: URL(fileURLWithPath: "/Users/andybest/Desktop/stackTest.pdf")) {
            print("Progress: \($0 * 100)%")
        }
    } catch {
        print(error)
    }
}

main()
