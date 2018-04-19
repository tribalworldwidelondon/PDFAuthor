/*
 MIT License

 Copyright (c) 2018 Tribal Worldwide London

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

class TextColumnsChapter: PDFChapter {

    let testString = """
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis dignissim dictum justo volutpat fermentum. Aenean et dolor id sapien ullamcorper sollicitudin sit amet vel mauris. Morbi diam ligula, feugiat posuere ante sit amet, mollis molestie velit. Etiam vitae arcu massa. Quisque eget tortor nec diam sollicitudin ultrices id id risus. Praesent varius porta elementum. Ut facilisis augue sed rhoncus finibus. Quisque rutrum ut nunc sit amet rhoncus. Sed sodales pharetra diam in tempus.

    Sed in varius enim. Vestibulum finibus metus imperdiet orci porta, at rhoncus ante rhoncus. Phasellus aliquam massa massa, ut maximus ipsum pretium mollis. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nunc vel augue at urna commodo vehicula. Sed facilisis risus non nulla vestibulum vulputate. Maecenas elit sapien, vestibulum vitae congue vel, maximus a justo. Donec rhoncus tellus odio, eu ullamcorper diam maximus eget. Nulla id sapien gravida sem tempus interdum a quis arcu. Vestibulum neque tellus, tincidunt et suscipit at, rutrum sed lorem. Proin quis augue quis est tempor elementum. Donec urna velit, tincidunt eu leo eu, scelerisque gravida orci. Aliquam dignissim est eget metus dictum, sit amet tempor justo convallis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Maecenas id risus eget libero scelerisque semper quis at enim. Donec aliquam nisl vitae nunc posuere finibus.

    Integer sit amet condimentum nisl. Nam sed eros quis lorem consectetur iaculis vehicula eu lacus. Proin id efficitur ante. Etiam nec sagittis lectus, vitae aliquam arcu. Praesent ex odio, posuere ac diam venenatis, dictum ullamcorper odio. Aenean vel ligula sapien. Vestibulum et diam laoreet, luctus elit in, placerat lectus. Donec at tellus vitae magna vehicula luctus vitae euismod augue. Nunc sit amet massa nisl.

    Ut semper accumsan nisl non laoreet. Pellentesque dolor nibh, rhoncus ut tincidunt vel, ultrices id ante. Etiam tempus ac ex ultricies vulputate. Cras non nunc sit amet tellus vestibulum laoreet quis in nulla. Donec ac felis vel nibh eleifend sagittis id ut ante. Donec pulvinar a magna non aliquet. Nulla facilisi. Vestibulum condimentum arcu felis, et mattis orci feugiat eu. Praesent pulvinar risus sit amet velit egestas ullamcorper.

    Fusce volutpat, lacus sodales venenatis gravida, ipsum lectus varius risus, nec iaculis quam justo ut ipsum. Sed tincidunt neque velit, eu placerat sem eleifend ut. Nulla facilisi. Pellentesque dignissim, orci quis interdum pharetra, ante quam interdum justo, non egestas tortor purus eget turpis. Donec eu eleifend nibh. Proin mauris enim, pharetra ut ante sed, fermentum tempor sem. Ut ultrices blandit erat, nec tincidunt mauris venenatis nec. Mauris rhoncus, lorem non blandit aliquam, libero eros placerat mi, eget semper elit enim et est. Suspendisse nec nunc pharetra, efficitur ex quis, pharetra massa.
    """

    override init(pageSpecifications: PDFPageSpecifications) {
        super.init(pageSpecifications: pageSpecifications)
    }

    override func generate() {
        withNewPage {
            $0.backgroundColor = PDFColor(white: 0.95, alpha: 1.0)

            let r = MultiColumnStringRegion(string: testString,
                    font: .systemFont(ofSize: 10),
                    color: PDFColor(white: 0, alpha: 1.0),
                    alignment: .left,
                    numColumns: 3)

            r.preferredMaxLayoutWidth = $0.contentWidth

            $0.addChild(r)

            r.addConstraints(
                    r.left == $0.leftInset,
                    r.right == $0.rightInset,
                    r.top == $0.topInset)
        }
    }
}
