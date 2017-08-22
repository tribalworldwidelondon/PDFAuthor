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

let loremIpsum = """
Integer gravida dui ut luctus sagittis. Duis at purus erat. Mauris pharetra mi arcu, id congue dui malesuada convallis. Etiam at tristique orci. Sed scelerisque, arcu sed pellentesque convallis, enim velit vehicula mi, quis fringilla neque ipsum in diam. Fusce vitae leo facilisis, tincidunt nisl sit amet, porta odio. Sed mattis sagittis neque, sed tempus magna placerat vel. Vestibulum feugiat lacus et pellentesque fermentum. Vivamus ut ullamcorper felis. Integer id laoreet nulla. Nam quis dui et lacus consectetur interdum eu sit amet nisi. Sed id faucibus enim. Quisque ullamcorper, turpis sit amet ultrices semper, nulla lorem condimentum turpis, pulvinar aliquam nisl diam a eros. Aenean accumsan quis lorem eget ultricies. Nam odio nisi, lacinia at elit eget, congue venenatis erat. Vivamus euismod laoreet elit sed imperdiet.
"""

class MaskChapter: PDFChapter {
    
    let pageBackgroundColor = PDFColor(white: 0.95, alpha: 1.0)
    let maskedRegionBackgroundColor = PDFColor(hue: 0.0, saturation: 0.3, brightness: 1.0, alpha: 1.0)
    let textColor = PDFColor(white: 0.15, alpha: 1.0)
    
    override init(pageSpecifications: PDFPageSpecifications) {
        super.init(pageSpecifications: pageSpecifications)
        
        buildChapter()
    }
    
    func buildChapter() {
        let headerRegion = StringRegion(string: "Region Masking",
                                        font: .boldSystemFont(ofSize: 22),
                                        color: textColor)
        
        let introRegion = StringRegion(string: "Some examples of different mask types supported by PDFAuthor",
                                       font: .systemFont(ofSize: 12),
                                       color: textColor)
        
        withNewPage {
            $0.backgroundColor = pageBackgroundColor
            $0.outlineTitle = "Region Masking"
            
            // Create a stack region to hold all of the page elements
            
            let pageStack = StackRegion(arrangedRegions: [
                headerRegion,
                spacerRegion(8),
                introRegion,
                spacerRegion(),
                sectionTitleRegion("Rectangular mask"),
                regionWithRectangularMask(),
                spacerRegion(),
                sectionTitleRegion("Multiple rectangular masks"),
                regionWithMultipleRectangularMasks(),
                spacerRegion(),
                sectionTitleRegion("CGPath mask"),
                regionWithPathMask(),
                spacerRegion(),
                sectionTitleRegion("Image mask"),
                regionWithImageMask()
                ])
            
            pageStack.axis = .vertical
            pageStack.alignment = .fill
            
            $0.addChild(pageStack)
            
            pageStack.addConstraints(
                pageStack.left == $0.leftInset,
                pageStack.right == $0.rightInset,
                pageStack.top == $0.topInset,
                pageStack.bottom <= $0.bottomInset  // Make less than or equal, so the stack region isn't stretched.
            )
        }
    }
    
    func spacerRegion(_ space: CGFloat = 24) -> PDFRegion {
        let region = PDFRegion()
        region.addConstraint(region.height == space)
        return region
    }
    
    func sectionTitleRegion(_ title: String) -> PDFRegion {
        let titleRegion = StringRegion(string: title, font: .boldSystemFont(ofSize: 14), color: textColor)
        // Add the title to the PDF Outline
        titleRegion.outlineTitle = title
        return titleRegion
    }
    
    func regionWithRectangularMask() -> PDFRegion {
        let region = StringRegion(string: loremIpsum)
        region.backgroundColor = maskedRegionBackgroundColor
        region.maskType = .rect(CGRect(x: 16, y: 16, width: 96, height: 96))
        return region
    }
    
    func regionWithMultipleRectangularMasks() -> PDFRegion {
        let region = StringRegion(string: loremIpsum)
        region.backgroundColor = maskedRegionBackgroundColor
        region.maskType = .rects([
            CGRect(x: 16, y: 16, width: 32, height: 32),
            CGRect(x: 48, y: 48, width: 32, height: 32),
            CGRect(x: 16, y: 80, width: 32, height: 32),
            CGRect(x: 80, y: 16, width: 32, height: 32),
            CGRect(x: 80, y: 80, width: 32, height: 32)
            ])
        return region
    }
    
    func regionWithPathMask() -> PDFRegion {
        let region = StringRegion(string: loremIpsum)
        region.backgroundColor = maskedRegionBackgroundColor
        
        let path = CGMutablePath()
        path.addPath(CGPath(ellipseIn: CGRect(x: 16, y: 16, width: 96, height: 96),
                            transform: nil))
        
        path.addPath(CGPath(roundedRect: CGRect(x: 128, y: 16, width: 96, height: 96),
                            cornerWidth: 8,
                            cornerHeight: 8,
                            transform: nil))
        
        region.maskType = .path(path)
        
        return region
    }
    
    func regionWithImageMask() -> PDFRegion {
        let region = StringRegion(string: loremIpsum)
        region.backgroundColor = maskedRegionBackgroundColor
        
        region.maskType = .image(maskImage(), CGRect(x: 16, y: 16, width: 128, height: 128))
        
        return region
    }
    
    func maskImage() -> PDFImage {
        // Create a simple image that can be used as a mask in the example.
        
        let width = 128
        let height = 128
        
        var pixels = [UInt8](repeating: 0x0, count: width * height)
        
        // Produce an interesting texture
        for x in 0..<width {
            for y in 0..<height {
                let val = Int(((cos(CGFloat(x) * 0.1) + sin(CGFloat(y) * 0.1)) + 2.0) * 127)
                pixels[x + (y * width)] = UInt8(val & 0xFF)
            }
        }
        
        let bitsPerComponent = 8
        let bytesPerPixel = 1
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow
        let providerRef = CGDataProvider(data: NSData(bytes: pixels, length: totalBytes))!
        
        let colorSpaceRef = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        
        let image = CGImage(width: width,
                            height: height,
                            bitsPerComponent: bitsPerComponent,
                            bitsPerPixel: bitsPerPixel,
                            bytesPerRow: bytesPerRow,
                            space: colorSpaceRef,
                            bitmapInfo: bitmapInfo,
                            provider: providerRef,
                            decode: nil,
                            shouldInterpolate: false,
                            intent: .defaultIntent)
        
        // Save the image as a png to save space
        let data: NSData = NSMutableData()
        let dest = CGImageDestinationCreateWithData(data as! CFMutableData, kUTTypePNG, 1, nil)!
        CGImageDestinationAddImage(dest, image!, nil)
        CGImageDestinationFinalize(dest)
        
        return PDFImage(data: data as Data)!
    }
}
