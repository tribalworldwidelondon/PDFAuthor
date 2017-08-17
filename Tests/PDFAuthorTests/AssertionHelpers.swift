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
@testable import Cassowary

extension Double {
    static let epsilon: Double = 1.0e-8
}

extension CGFloat {
    static let epsilon: CGFloat = CGFloat(Double.epsilon)
}

func assertIsCloseTo(_ v1: Variable, _ v2: Variable, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(v1.value, v2.value, accuracy: Double.epsilon, file: file, line: line)
}

func assertIsCloseTo(_ v1: Variable, _ v2: Double, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(v1.value, v2, accuracy: Double.epsilon, file: file, line: line)
}

func assertIsCloseTo(_ v1: Double, _ v2: Variable, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(v1, v2.value, accuracy: Double.epsilon, file: file, line: line)
}

func assertIsCloseTo(_ v1: Double, _ v2: Double, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(v1, v2, accuracy: Double.epsilon, file: file, line: line)
}

func assertIsCloseTo(_ rect1: CGRect, _ rect2: CGRect, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(rect1.origin.x, rect2.origin.x, accuracy: .epsilon, file: file, line: line)
    XCTAssertEqual(rect1.origin.y, rect2.origin.y, accuracy: .epsilon, file: file, line: line)
    XCTAssertEqual(rect1.size.width, rect2.size.width, accuracy: .epsilon, file: file, line: line)
    XCTAssertEqual(rect1.size.height, rect2.size.height, accuracy: .epsilon, file: file, line: line)
}
