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
@testable import PDFAuthor

class ImageRegionTests: XCTestCase {
    
    func testContentModeFrameScaleToFill() {
        let frame = ImageRegion.frameForContentMode(.scaleToFill,
                                                    bounds: CGRect(x: 0, y: 0, width: 100, height: 100),
                                                    imageSize: .zero)
        
        assertIsCloseTo(frame, CGRect(x: 0, y: 0, width: 100, height: 100))
    }
    
    func testContentModeFrameAspectFit() {
        let frame = ImageRegion.frameForContentMode(.scaleAspectFit,
                                                    bounds: CGRect(x: 0, y: 0, width: 100, height: 100),
                                                    imageSize: CGSize(width: 100,
                                                                      height: 200))
        
        assertIsCloseTo(frame, CGRect(x: 25, y: 0, width: 50, height: 100))
        
        let frame2 = ImageRegion.frameForContentMode(.scaleAspectFit,
                                                    bounds: CGRect(x: 0, y: 0, width: 100, height: 100),
                                                    imageSize: CGSize(width: 200,
                                                                      height: 100))
        
        assertIsCloseTo(frame2, CGRect(x: 0, y: 25, width: 100, height: 50))
    }
    
    func testContentModeFrameScaleAspectFill() {
        let frame = ImageRegion.frameForContentMode(.scaleAspectFill,
                                                    bounds: CGRect(x: 0, y: 0, width: 100, height: 100),
                                                    imageSize: CGSize(width: 100,
                                                                      height: 200))
        
        assertIsCloseTo(frame, CGRect(x: 0, y: -50, width: 100, height: 200))
        
        let frame2 = ImageRegion.frameForContentMode(.scaleAspectFill,
                                                    bounds: CGRect(x: 0, y: 0, width: 100, height: 100),
                                                    imageSize: CGSize(width: 200,
                                                                      height: 100))
        
        assertIsCloseTo(frame2, CGRect(x: -50, y: 0, width: 200, height: 100))
    }
    
    func testContentModeFrameCenter() {
        let frame = ImageRegion.frameForContentMode(.center,
                                                    bounds: CGRect(x: 0, y: 0, width: 100, height: 100),
                                                    imageSize: CGSize(width: 200,
                                                                      height: 200))
        
        assertIsCloseTo(frame, CGRect(x: -50, y: -50, width: 200, height: 200))
    }
    
    func testContentModeFrameTop() {
        let frame = ImageRegion.frameForContentMode(.top,
                                                    bounds: CGRect(x: 0, y: 0, width: 100, height: 100),
                                                    imageSize: CGSize(width: 200,
                                                                      height: 200))
        
        assertIsCloseTo(frame, CGRect(x: -50, y: 0, width: 200, height: 200))
    }
    
    func testContentModeFrameBottom() {
        let frame = ImageRegion.frameForContentMode(.bottom,
                                                    bounds: CGRect(x: 0, y: 0, width: 100, height: 100),
                                                    imageSize: CGSize(width: 200,
                                                                      height: 200))
        
        assertIsCloseTo(frame, CGRect(x: -50, y: -100, width: 200, height: 200))
    }
    
    func testContentModeFrameLeft() {
        let frame = ImageRegion.frameForContentMode(.left,
                                                    bounds: CGRect(x: 0, y: 0, width: 100, height: 100),
                                                    imageSize: CGSize(width: 200,
                                                                      height: 200))
        
        assertIsCloseTo(frame, CGRect(x: 0, y: -50, width: 200, height: 200))
    }
    
    func testContentModeFrameRight() {
        let frame = ImageRegion.frameForContentMode(.right,
                                                    bounds: CGRect(x: 0, y: 0, width: 100, height: 100),
                                                    imageSize: CGSize(width: 200,
                                                                      height: 200))
        
        assertIsCloseTo(frame, CGRect(x: -100, y: -50, width: 200, height: 200))
    }
    
    func testContentModeFrameTopLeft() {
        let frame = ImageRegion.frameForContentMode(.topLeft,
                                                    bounds: CGRect(x: 0, y: 0, width: 100, height: 100),
                                                    imageSize: CGSize(width: 200,
                                                                      height: 200))
        
        assertIsCloseTo(frame, CGRect(x: 0, y: 0, width: 200, height: 200))
    }
    
    func testContentModeFrameTopRight() {
        let frame = ImageRegion.frameForContentMode(.topRight,
                                                    bounds: CGRect(x: 0, y: 0, width: 100, height: 100),
                                                    imageSize: CGSize(width: 200,
                                                                      height: 200))
        
        assertIsCloseTo(frame, CGRect(x: -100, y: 0, width: 200, height: 200))
    }
    
    func testContentModeFrameBottomLeft() {
        let frame = ImageRegion.frameForContentMode(.bottomLeft,
                                                    bounds: CGRect(x: 0, y: 0, width: 100, height: 100),
                                                    imageSize: CGSize(width: 200,
                                                                      height: 200))
        
        assertIsCloseTo(frame, CGRect(x: 0, y: -100, width: 200, height: 200))
    }
    
    func testContentModeFrameBottomRight() {
        let frame = ImageRegion.frameForContentMode(.bottomRight,
                                                    bounds: CGRect(x: 0, y: 0, width: 100, height: 100),
                                                    imageSize: CGSize(width: 200,
                                                                      height: 200))
        
        assertIsCloseTo(frame, CGRect(x: -100, y: -100, width: 200, height: 200))
    }
    
}
