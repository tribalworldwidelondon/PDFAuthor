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

func MakeCGContext(_ size: CGSize = CGSize(width: 1000, height: 1000)) -> CGContext {
    let colorspace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    
    let ctx = CGContext(data: nil,
                        width: Int(size.width),
                        height: Int(size.height),
                        bitsPerComponent: 8,
                        bytesPerRow: 0,
                        space:colorspace,
                        bitmapInfo: bitmapInfo.rawValue)
    
    return ctx!
}

class PDFRegionTests: XCTestCase {
    
    func testDefaultInitialization() {
        let region = PDFRegion(frame: CGRect(x: 10, y: 20, width: 30, height: 40))
        
        XCTAssertEqual(region.frame, CGRect(x: 10, y: 20, width: 30, height: 40))
        XCTAssertEqual(region.bounds, CGRect(x: 0, y: 0, width: 30, height: 40))
        XCTAssertNil(region.parent)
        XCTAssertEqual(region.children.count, 0)
    }
    
    
    // MARK: - Children
    
    func testAddChild() {
        let region = PDFRegion(frame: .zero)
        let child = PDFRegion(frame: .zero)
        
        region.addChild(child)
        
        XCTAssertEqual(region.children, [child])
    }
    
    func testAddingSelfAsChildThrowsAssertionAndDoesNotAddChild() {
        let region = PDFRegion(frame: .zero)
        
        // Make sure that adding self as a child throws an assertion
        let exception = catchBadInstruction { region.addChild(region) }
        XCTAssertNotNil(exception, "Should throw an exception")
        XCTAssertEqual(region.children, [])
    }
    
    func testRemoveChild() {
        let region = PDFRegion(frame: .zero)
        let child = PDFRegion(frame: .zero)
        
        region.addChild(child)
        XCTAssertEqual(region.children, [child])
        
        region.removeChild(child)
        XCTAssertEqual(region.children, [])
    }
    
    func testRemoveChildThatIsNotAChild() {
        let region = PDFRegion(frame: .zero)
        let child = PDFRegion(frame: .zero)
        
        let exception = catchBadInstruction { region.removeChild(child) }
        XCTAssertNotNil(exception, "Should throw an exception")
    }
    
    func testRemoveFromParent() {
        let region = PDFRegion(frame: .zero)
        let child = PDFRegion(frame: .zero)
        
        region.addChild(child)
        XCTAssertEqual(region.children, [child])
        
        child.removeFromParent()
        XCTAssertEqual(region.children, [])
    }
    
    // MARK: - drawRecursive
    
    func testDrawRecursiveRecursivelyDrawsAllChildren() {
        
        class TestRegion: PDFRegion {
            var didDraw = false
            
            override func draw(withContext context: CGContext, inRect: CGRect) {
                didDraw = true
            }
        }
        
        let region = TestRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        
        let child1 = TestRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        let child1Child1 = TestRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        child1.addChild(child1Child1)
        region.addChild(child1)
        
        let child2 = TestRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        region.addChild(child2)
        
        var drawnRegions: Set<PDFRegion> = []
        
        region.drawRecursive(withContext: MakeCGContext(), inRect: .zero, drawnRegions: &drawnRegions)
        
        let rendered = [region, child1, child1Child1, child2].map { $0.didDraw }.reduce(true) { $0 == $1 }
        XCTAssert(rendered)
        
        XCTAssertEqual(drawnRegions, Set<PDFRegion>([region, child1, child1Child1, child2]))
    }
    
    func testDrawRecursivelyDoesNotCreateAnInfiniteLoop() {
        let region = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        let child1 = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        
        region.addChild(child1)
        child1.addChild(region)
        
        var drawnRegions: Set<PDFRegion> = []
        let exception = catchBadInstruction {
            region.drawRecursive(withContext: MakeCGContext(), inRect: .zero, drawnRegions: &drawnRegions)
        }
        
        XCTAssertNotNil(exception, "Should throw an exception")
        XCTAssertEqual(drawnRegions, Set<PDFRegion>([region, child1]))
    }
    
    
    // MARK: - RecursiveDescription
    
    func testRecursiveDescription() {
        let region = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        
        let child1 = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        let child1Child1 = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        child1.addChild(child1Child1)
        region.addChild(child1)
        
        let child2 = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        region.addChild(child2)
        
        var expectedString = " <PDFRegion, frame: (0.0, 0.0, 1000.0, 1000.0))>\n"
        expectedString += "\t| <PDFRegion, frame: (0.0, 0.0, 1000.0, 1000.0))>\n"
        expectedString += "\t|\t| <PDFRegion, frame: (0.0, 0.0, 1000.0, 1000.0))>\n"
        expectedString += "\t| <PDFRegion, frame: (0.0, 0.0, 1000.0, 1000.0))>\n"
        
        XCTAssertEqual(region.recursiveDescription(), expectedString)
    }
    
    func testRecursiveDescriptionDoesNotCreateAnInfiniteLoop() {
        let region = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        let child1 = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        
        region.addChild(child1)
        child1.addChild(region)
        
        let exception = catchBadInstruction {
            _ = region.recursiveDescription()
        }
        
        XCTAssertNotNil(exception, "Should throw an exception")
    }
    
    // MARK: Hierarchy
    
    func testRegionHierarchy() {
        let region1 = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        let region2 = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        let region3 = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        let region4 = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        
        region1.addChild(region2)
        region2.addChild(region3)
        region3.addChild(region4)
        
        let hierarchy = region4.regionHierarchy()
        
        XCTAssertEqual(hierarchy, [region3, region2, region1])
    }
    
    func testCommonParentRegion() {
        let region1 = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        let region2 = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        let region2a = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        let region3 = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        let region4 = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        
        region1.addChild(region2)
        region2.addChild(region3)
        region3.addChild(region4)
        region2.addChild(region2a)
        
        let commonParent = region4.commonParentRegion(region2a)
        
        XCTAssertEqual(commonParent, region2)
        
        let regionOrphan = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        
        XCTAssertNil(region4.commonParentRegion(regionOrphan))
    }
    
    func testPointInRegion() {
        let region1 = PDFRegion(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let region2 = PDFRegion(frame: CGRect(x: 100, y: 0, width: 1000, height: 1000))
        let region3 = PDFRegion(frame: CGRect(x: 0, y: 100, width: 1000, height: 1000))
        let region4 = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        
        region1.addChild(region2)
        region2.addChild(region3)
        region3.addChild(region4)
        
        let region2a = PDFRegion(frame: CGRect(x: 50, y: 50, width: 1000, height: 1000))
        
        region2.addChild(region2a)
        
        let testPoint = CGPoint(x: 50, y: 50)
        
        // Test getting point in parent
        XCTAssertEqual(region2a.point(testPoint, in: region1), CGPoint(x: 200, y: 100))
        
        // Test getting point in sibling
        XCTAssertEqual(region2a.point(testPoint, in: region4), CGPoint(x: 100, y: 0))
        
        // Test region not in hierarchy throws assert
        let orphanRegion = PDFRegion(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let exception = catchBadInstruction {
            let point = region2a.point(testPoint, in: orphanRegion)
            XCTAssertEqual(point, CGPoint.zero)
        }
        
        XCTAssertNotNil(exception, "Should throw an exception")
    }
    
    // MARK: Outline

    func testOutline() {
        let region = PDFRegion(frame: CGRect(x: 50, y: 50, width: 100, height: 100))
        
        XCTAssertNil(region.outline(origin: .zero, pageNum: 0))
        
        region.outlineTitle = "Test"
        
        let expectedOutline: [String: Any] = [
            "Destination": 0,
            "DestinationRect": [
                "Width": 100,
                "Height": 100,
                "X": 50,
                "Y": 50
            ],
            "Title": "Test"
        ]
        
        let outline = region.outline(origin: .zero, pageNum: 0)
        XCTAssertNotNil(outline)
        XCTAssert(outline! == expectedOutline)
    }
    
    func testRecursiveOutline() {
        let region1 = PDFRegion(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let region2 = PDFRegion(frame: CGRect(x: 100, y: 0, width: 1000, height: 1000))
        region2.outlineTitle = "Region 2"
        let region3 = PDFRegion(frame: CGRect(x: 0, y: 100, width: 1000, height: 1000))
        let region4 = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        region4.outlineTitle = "Region 4"
        let region5 = PDFRegion(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        
        region1.addChild(region2)
        region2.addChild(region3)
        region3.addChild(region4)
        region4.addChild(region5)
        
        let region2a = PDFRegion(frame: CGRect(x: 50, y: 50, width: 1000, height: 1000))
        region2a.outlineTitle = "Region 2a"
        
        region2.addChild(region2a)
        
        let outline = region1.recursiveOutline(origin: .zero, pageNum: 0)
        
        let expectedOutline: [String: Any] = [
            "Title": "Region 2",
            "Destination": 0,
            "DestinationRect": [
                "Width": 1000,
                "Height": 1000,
                "X": 100,
                "Y": 0
            ],
            "Children": [
                [
                    "Destination": 0,
                    "DestinationRect": [
                        "Width": 1000,
                        "Height": 1000,
                        "X": 150,
                        "Y": 50
                    ],
                    "Title": "Region 2a"
                ],
                [
                    "Destination": 0,
                    "DestinationRect": [
                        "Width": 1000,
                        "Height": 1000,
                        "X": 100,
                        "Y": 100
                    ],
                 "Title": "Region 4"
                ]
            ]
        ]
        
        XCTAssertNotNil(outline)
        XCTAssert(outline! == expectedOutline)
    }
    
    
    /*static var allTests = [
        //("testExample", testExample),
        ]*/
}

func == <K, V>(left: [K:V], right: [K:V]) -> Bool {
    return NSDictionary(dictionary: left).isEqual(to: right)
}

