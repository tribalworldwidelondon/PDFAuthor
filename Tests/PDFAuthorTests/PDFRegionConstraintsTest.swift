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
import Cassowary
@testable import PDFAuthor

class PDFRegionConstraintsTests: XCTestCase {
    
    func testAddConstraints() {
        let region = PDFRegion(frame: .zero)
        
        region.addConstraint(region.width == 100)
        XCTAssertEqual(region.constraints.count, 1)
        
        region.addConstraints([region.height == 200])
        XCTAssertEqual(region.constraints.count, 2)
    }
    
    func testBasicConstraints() {
        let root = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        
        let centered = PDFRegion(frame: .zero)
        root.addChild(centered)
        centered.addConstraints(centered.width   == root.width / 2.0,
                                centered.height  == root.height / 2.0,
                                centered.centerX == root.centerX,
                                centered.centerY == root.centerY)
        
        root.calculateConstraints()
        root.recursivelyUpdateFrames()
        
        assertIsCloseTo(root.frame, CGRect(x: 0, y: 0, width: 1000, height: 1000))
        assertIsCloseTo(centered.frame, CGRect(x: 250, y: 250, width: 500, height: 500))
    }
    
    func testUnsatisfiableConstraintDoesNotGetAdded() {
        let region = PDFRegion(frame: .zero)
        
        region.addConstraints(
            region.width == 100,
            region.width == 200,
            region.height == 100
        )
        
        let solver = Solver()
        
        // This should work fine
        region.solveConstraints(solver, silenceError: true)
    }
    
    func testAutoResizingMaskConstraints() {
        let region = PDFRegion(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let childRegion = PDFRegion(frame: .zero)
        region.addChild(childRegion)
        childRegion.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        XCTAssertEqual(childRegion.constraints.count, 2)
    }
    
}
