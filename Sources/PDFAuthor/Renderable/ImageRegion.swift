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


#if os(OSX)
    import AppKit
    
    public typealias PDFImage = NSImage
#elseif os(iOS)
    import UIKit
    
    public typealias PDFImage = UIImage
#endif

public enum ImageContentMode {
    case scaleToFill
    case scaleAspectFit
    case scaleAspectFill
    case center
    case top
    case bottom
    case left
    case right
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

public class ImageRegion: PDFRegion {
    
    public var contentMode: ImageContentMode = .center
    public var image: PDFImage?
    
    private var cgImage: CGImage? {
        #if os(iOS)
            return image?.cgImage
        #elseif os(OSX)
            return image?.cgImage(forProposedRect: nil, context: nil, hints: nil)
        #endif
    }
    
    override public func draw(withContext context: CGContext, inRect rect: CGRect) {
        guard bounds.width > 0, bounds.height > 0 else {
            return
        }
        
        guard let img = cgImage else {
            return
        }
        
        let imageSize = CGSize(width: CGFloat(img.width),
                               height: CGFloat(img.height))
        
        guard imageSize.width > 0, imageSize.height > 0 else {
            return
        }
        
        // TODO: Possibly move the clipping to a clipsToBounds property on PDFRegion?
        context.saveGState()
        context.clip(to: bounds)
        context.draw(img, in: ImageRegion.frameForContentMode(self.contentMode,
                                                              bounds: self.bounds,
                                                              imageSize: imageSize))
        context.restoreGState()
    }
    
    internal static func frameForContentMode(_ contentMode: ImageContentMode,
                                             bounds: CGRect,
                                             imageSize: CGSize) -> CGRect {
        switch contentMode {
        case .scaleToFill:
            return bounds
        case .scaleAspectFit:
            return aspectFitFrame(bounds: bounds, imageSize: imageSize)
        case .scaleAspectFill:
            return aspectFillFrame(bounds: bounds, imageSize: imageSize)
        case .center:
            return CGRect(x: (bounds.width - imageSize.width) / 2.0,
                          y: (bounds.height - imageSize.height) / 2.0,
                          width: imageSize.width,
                          height: imageSize.height)
        case .top:
            return CGRect(x: (bounds.width - imageSize.width) / 2.0,
                          y: 0,
                          width: imageSize.width,
                          height: imageSize.height)
        case .bottom:
            return CGRect(x: (bounds.width - imageSize.width) / 2.0,
                          y: bounds.height - imageSize.height,
                          width: imageSize.width,
                          height: imageSize.height)
        case .left:
            return CGRect(x: 0,
                          y: (bounds.height - imageSize.height) / 2.0,
                          width: imageSize.width,
                          height: imageSize.height)
        case .right:
            return CGRect(x: bounds.width - imageSize.width,
                          y: (bounds.height - imageSize.height) / 2.0,
                          width: imageSize.width,
                          height: imageSize.height)
        case .topLeft:
            return CGRect(x: 0,
                          y: 0,
                          width: imageSize.width,
                          height: imageSize.height)
        case .topRight:
            return CGRect(x: bounds.width - imageSize.width,
                          y: 0,
                          width: imageSize.width,
                          height: imageSize.height)
        case .bottomLeft:
            return CGRect(x: 0,
                          y: bounds.height - imageSize.height,
                          width: imageSize.width,
                          height: imageSize.height)
        case .bottomRight:
            return CGRect(x: bounds.width - imageSize.width,
                          y: bounds.height - imageSize.height,
                          width: imageSize.width,
                          height: imageSize.height)
        }
    }
    
    internal static func aspectFitFrame(bounds: CGRect, imageSize: CGSize) -> CGRect {
        assert(bounds.width > 0 && bounds.height > 0, "Cannot create frame with zero width/height!")
        
        let horizontalScaleFactor = imageSize.width / bounds.width
        let verticalScaleFactor = imageSize.height / bounds.height
        
        let scaleFactor = max(horizontalScaleFactor, verticalScaleFactor)
        
        let width = imageSize.width / scaleFactor
        let height = imageSize.height / scaleFactor
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        if width > height {
            y = (bounds.height - height) / 2.0
        } else if height > width {
            x = (bounds.width - width) / 2.0
        }
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    internal static func aspectFillFrame(bounds: CGRect, imageSize: CGSize) -> CGRect {
        let aspect = imageSize.width / imageSize.height
        
        if bounds.width / aspect > bounds.height {
            let height = bounds.width / aspect
            return CGRect(x: 0,
                          y: (bounds.height - height) / 2.0,
                          width: bounds.width,
                          height: height)
        }
        
        let width = bounds.height * aspect
        return CGRect(x: (bounds.width - width) / 2.0,
                      y: 0,
                      width: width,
                      height: bounds.height)
    }
}
