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

var pageSpecifications = PDFPageSpecifications(size: .A4)
pageSpecifications.contentInsets = PDFEdgeInsets(top: 32, left: 32, bottom: 32, right: 32)
let a4Chapter = PDFChapter(pageSpecifications: pageSpecifications)

let document = PDFAuthorDocument().with {
    //$0.addChapter(a4Chapter)
    $0.addChapter(PhoneBillChapter(pageSpecifications: pageSpecifications))
}

// Add 3 blank pages with different background colors
let colors: [PDFColor] = [ .red, .green, .blue ]
for color in colors {
    a4Chapter.withNewPage {
        $0.backgroundColor = color
        
        let stringRegion = StringRegion(string: """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec at nulla ut libero tempus volutpat interdum mollis tortor.
            In sed enim ligula. Donec ultrices sit amet libero non ornare. Nulla scelerisque arcu elementum sem bibendum, ut hendrerit ex scelerisque. Curabitur eget massa magna. Integer vel ipsum elementum, volutpat eros molestie, fermentum massa. Mauris lacinia sapien ornare tempor accumsan. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc massa elit, convallis sit amet odio et, tincidunt venenatis mi. Donec sed egestas lacus. In venenatis rhoncus nulla, ut imperdiet nibh rhoncus id. Fusce vehicula magna ac lectus placerat facilisis. Suspendisse varius aliquam sollicitudin. Proin faucibus elementum elit viverra aliquam.

            Integer gravida dui ut luctus sagittis. Duis at purus erat. Mauris pharetra mi arcu, id congue dui malesuada convallis. Etiam at tristique orci. Sed scelerisque, arcu sed pellentesque convallis, enim velit vehicula mi, quis fringilla neque ipsum in diam. Fusce vitae leo facilisis, tincidunt nisl sit amet, porta odio. Sed mattis sagittis neque, sed tempus magna placerat vel. Vestibulum feugiat lacus et pellentesque fermentum. Vivamus ut ullamcorper felis. Integer id laoreet nulla. Nam quis dui et lacus consectetur interdum eu sit amet nisi. Sed id faucibus enim. Quisque ullamcorper, turpis sit amet ultrices semper, nulla lorem condimentum turpis, pulvinar aliquam nisl diam a eros. Aenean accumsan quis lorem eget ultricies. Nam odio nisi, lacinia at elit eget, congue venenatis erat. Vivamus euismod laoreet elit sed imperdiet.
        """)
        
        stringRegion.addConstraints(
            stringRegion.left == $0.left + 32,
            stringRegion.right == $0.right - 32,
            stringRegion.top == $0.top + 32
        )
        
        $0.addChild(stringRegion)
    }
}

try document.generate(to: URL(fileURLWithPath: ("~/Desktop/test1.pdf" as NSString).expandingTildeInPath))
