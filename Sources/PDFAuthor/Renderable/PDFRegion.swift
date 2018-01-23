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
import Cassowary


/// The base class representing a rectangular region in the PDF Document.
open class PDFRegion {
    
    /// The frame rectangle, which describes the region's location in its parent's coordinate system.
    public var frame: CGRect
    
    /// The bounds rectangle, which describes the region's location in its own coordinate system.
    public var bounds: CGRect {
        return CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
    /// The edge insets of the region
    public var edgeInsets: PDFEdgeInsets = .zero
    
    /// The background color of the region. Defaults to .clear
    public var backgroundColor: PDFColor = .clear
    
    /// An enum representing the different border styles
    public enum BorderStyle {
        
        /// No border
        case none
        
        /// A solid border
        case solid(width: CGFloat, color: PDFColor)
        
        /// A dashed border
        case dashed(width: CGFloat, color: PDFColor, phase: CGFloat, lengths: [CGFloat])
    }
    
    /// The border style of this region
    public var borderStyle: BorderStyle = .none
    
    private weak var _parent: PDFRegion?
    /// The parent region, or nil if it does not have one.
    public var parent: PDFRegion? { return _parent }
    
    private var _children: [PDFRegion] = []
    /// The region's immediate children.
    var children: [PDFRegion] { return _children }
    
    /// The title for this element in the PDF outline. If nil, it will not appear in the outline.
    public var outlineTitle: String?
    
    /// If set, determines the mask for this region and all of its subregions
    public var maskType: PDFMaskType?
    
    // MARK: Constraints variables
    
    /*
    public var contentCompressionResistanceVertical: PDFLayoutPriority?
    public var contentCompressionResistanceHorizontal: PDFLayoutPriority?
    
    public var contentHuggingPriorityVertical: PDFLayoutPriority?
    public var contentHuggingPriorityHorizontal: PDFLayoutPriority?
     */
    
    internal var suggestedVariableValues: [(variable: Variable, strength: Double, value: Double)] {
        return [
            (variable: edgeInsetTop, strength: Strength.STRONG, value: Double(edgeInsets.top)),
            (variable: edgeInsetBottom, strength: Strength.STRONG, value: Double(edgeInsets.bottom)),
            (variable: edgeInsetLeft, strength: Strength.STRONG, value: Double(edgeInsets.left)),
            (variable: edgeInsetRight, strength: Strength.STRONG, value: Double(edgeInsets.right)),
            (variable: width, strength: Strength.WEAK, value: Double(bounds.width)),
            (variable: height, strength: Strength.WEAK, value: Double(bounds.height))
        ]
    }
    
    internal var _constraints: [Constraint] = []
    
    /// The Cassowary constraints on this region.
    public var constraints: [Constraint] {
        get {
            var c: [Constraint] = []
            
            if translatesAutoresizingMaskIntoConstraints, let p = parent {
                if autoresizingMask.contains(.flexibleWidth) {
                    c.append(width == p.width)
                }
                
                if autoresizingMask.contains(.flexibleHeight) {
                    c.append(height == p.height)
                }
            }
            
            // Automatically add constraints for compression resistance and content hugging
            /*if let intrinsicSize = intrinsicContentSize() {
                if let verticalCompressionResistance = contentCompressionResistanceVertical {
                    c.append((height >= Double(intrinsicSize.height)).setStrength(verticalCompressionResistance.constraintStrength))
                }
                
                if let horizontalCompressionResistance = contentCompressionResistanceHorizontal {
                    c.append((width >= Double(intrinsicSize.width)).setStrength(horizontalCompressionResistance.constraintStrength))
                }
                
                if let verticalHugging = contentHuggingPriorityVertical {
                    c.append((height <= Double(intrinsicSize.height)).setStrength(verticalHugging.constraintStrength))
                }
                
                if let horizontalHugging = contentHuggingPriorityHorizontal {
                    c.append((width <= Double(intrinsicSize.width)).setStrength(horizontalHugging.constraintStrength))
                }
            
            }*/
            
            return c + _constraints
        }
        set {
            // If constraints are set, assume that we don't want to use the autoresizing mask.
            translatesAutoresizingMaskIntoConstraints = false
            _constraints = newValue
        }
    }
    
    /// The autoresizing mask of the region.
    public var autoresizingMask: PDFAutoresizing = []
    
    /// Disabling this will prevent any autoreszingmask constraints from being generated for the region.
    public var translatesAutoresizingMaskIntoConstraints: Bool = true
    
    // MARK: Constraints
    
    /// An anchor representing the left edge of the region.
    public lazy var left: Variable = {
        return Variable("left", owner: self)
    }()
    
    /// An anchor representing the top edge of the region.
    public lazy var top: Variable = {
        return Variable("top", owner: self)
    }()
    
    /// A constraint variable representing the width of the region.
    public lazy var width: Variable = {
        return Variable("width", owner: self)
    }()
    
    /// A constraint variable representing the height of the region.
    public lazy var height: Variable = {
        return Variable("height", owner: self)
    }()
    
    /// A constraint variable representing the left edge inset of the region.
    internal lazy var edgeInsetLeft: Variable = {
        return Variable("edgeInsetLeft", owner: self)
    }()
    
    /// A constraint variable representing the right edge inset of the region.
    internal lazy var edgeInsetRight: Variable = {
        return Variable("edgeInsetRight", owner: self)
    }()
    
    /// A constraint variable representing the top edge inset of the region.
    internal lazy var edgeInsetTop: Variable = {
        return Variable("edgeInsetTop", owner: self)
    }()
    
    /// A constraint variable representing the bottom edge inset of the region.
    internal lazy var edgeInsetBottom: Variable = {
        return Variable("edgeInsetBottom", owner: self)
    }()
    
    
    // MARK: Initialization
    
    /**
     Initializes the region with an initial frame of .zero
     */
    public init() {
        self.frame = .zero
    }
    
    /**
     Initializes the region with a given frame
     - parameters:
         - frame: The frame
     */
    public init(frame: CGRect) {
        self.frame = frame
    }
    
    // MARK: Children
    
    /**
     Add a child region
     - parameters:
         - child: The child to add
     */
    public func addChild(_ child: PDFRegion) {
        assert(child != self, "Cannot add self as a child of self!")
        if child != self && !children.contains(child) {
            _children.append(child)
            child._parent = self
        }
    }
    
    /**
     Remove a child
     - parameters:
         - child: The child to remove
     */
    public func removeChild(_ child: PDFRegion) {
        guard let idx = _children.index(of: child) else {
            assertionFailure("Attempted to remove region that is not a child")
            return
        }
        
        _children.remove(at: idx)
    }
    
    /**
     Remove from the parent region
     */
    public func removeFromParent() {
        parent?.removeChild(self)
    }
    
    // MARK: Rendering

    /**
     Recursively draw self then all children, transforming the coordinate space appropriately.
     - parameters:
         - context: The CGContext to draw into
         - rect: A rect providing bounds in which to draw
         - drawnRegions: A set with all of the regions that have already been drawn
     */
    public final func drawRecursive(withContext context: CGContext, inRect rect: CGRect, drawnRegions: inout Set<PDFRegion>) {
        drawnRegions.insert(self)
        
        context.saveGState()
        applyMask(toContext: context)
        drawInternal(withContext: context, inRect: rect)
        
        for child in _children {
            // Make sure that a region hasn't been added as a child of one of its children
            // so that we don't end up with infinite recursion
            assert(!drawnRegions.contains(child), "Error, recursion in drawing tree")

            if !drawnRegions.contains(child) {
                // Push the current coordinate system, translate to the child's coordinate system,
                // draw it, then pop the coordinate system
                context.saveGState()
                context.translateBy(x: child.frame.origin.x, y: child.frame.origin.y)
                child.drawRecursive(withContext: context, inRect: child.bounds, drawnRegions: &drawnRegions)
                context.restoreGState()
            }
        }
        context.restoreGState()
    }
    
    /**
     Override this function to provide your own drawing routine.
     - parameters:
         - context: The CGContext to draw into
         - rect: A rect providing bounds in which to draw
     */
    public func draw(withContext context: CGContext, inRect rect: CGRect) {
    }
    
    internal func borderPaths(inRect rect: CGRect) -> [CGPath] {
        guard let maskType = self.maskType else {
            return [CGPath(rect: rect, transform: nil)]
        }
        
        switch maskType {
        case .path(let path):
            return [path]
        case .rect(let maskRect):
            return [CGPath(rect: maskRect, transform: nil)]
        case .rects(let rects):
            return rects.map { CGPath(rect: $0, transform: nil) }
        default:
            return [CGPath(rect: rect, transform: nil)]
        }
    }
    
    /**
     Internal function that handles drawing the background
     - parameters:
         - context: The CGContext to draw into
         - rect: A rect providing bounds in which to draw
     */
    internal func drawInternal(withContext context: CGContext, inRect rect: CGRect) {
        // Draw background color
        if !rect.isEmpty {
            context.saveGState()
            context.setFillColor(backgroundColor.cgColor)
            context.fill(rect)
           
            switch borderStyle {
            case .solid(width: let width, color: let color):
                context.setLineWidth(width)
                context.setStrokeColor(color.cgColor)
                for path in self.borderPaths(inRect: rect) {
                    context .addPath(path)
                }
                context.strokePath()
                break
                
            case .dashed(width: let width, color: let color, phase: let phase, lengths: let lengths):
                context.setLineWidth(width)
                context.setStrokeColor(color.cgColor)
                context.setLineDash(phase: phase, lengths: lengths)
                for path in self.borderPaths(inRect: rect) {
                    context .addPath(path)
                }
                context.strokePath()
                break

            default: break
            }
            
            context.restoreGState()
            
        }
            
        draw(withContext: context, inRect: rect)
    }
    
    func applyMask(toContext context: CGContext) {
        guard let mask = maskType else {
            return
        }
        
        switch mask {
        case .bounds:
            context.clip(to: self.bounds)
        case .rect(let rect):
            context.clip(to: rect)
        case .rects(let rects):
            context.clip(to: rects)
        case .image(let image, let rect):
            #if os(iOS)
                let cgImage = image.cgImage
            #elseif os(OSX)
                let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
            #endif
            
            guard let i = cgImage else {
                assertionFailure("Invalid CGImage!")
                return
            }
            
            context.clip(to: rect, mask: i)
        case .path(let path):
            context.addPath(path)
            context.clip()
        }
    }
    
    // MARK: Geometry
    
    /**
     Returns an array of all parent regions
     */
    internal final func regionHierarchy() -> [PDFRegion] {
        // Returns an array of all containing regions
        
        var hierarchy = [PDFRegion]()
        
        var parentRegion: PDFRegion? = self.parent
        
        while parentRegion != nil {
            hierarchy.append(parentRegion!)
            parentRegion = parentRegion!.parent
        }
        
        return hierarchy
    }
    
    /**
     Finds the common parent of self and the region passed as an argument
     - parameters:
         - region: The region to find the common parent with
     */
    internal final func commonParentRegion(_ region: PDFRegion) -> PDFRegion? {
        // Returns the common parent of self and the region passed in the argument, if any
        
        let hierarchy = region.regionHierarchy()
        
        // Iterate backwards through the superviews
        for r in regionHierarchy() {
            if hierarchy.contains(r) {
                return r
            }
        }
        
        return nil
    }
    
    /**
     Converts a point from the local coordinate system to that of a specified region
     - parameters:
         - point: A point specified in the local coordinate system
         - region: The region into whose coordinate system point is to be converted
     */
    public final func point(_ point: CGPoint, in region: PDFRegion) -> CGPoint {
        let commonParent: PDFRegion
        
        if regionHierarchy().contains(region) {
            commonParent = region
        } else {
            let commonParentOptional = commonParentRegion(region)
            assert(commonParentOptional != nil, "Attempted to get frame in region that isn't in the same hierarchy")
            
            guard let p = commonParentOptional else {
                return .zero
            }
            commonParent = p
        }
        
        var selfPointInCommonParent = point
        selfPointInCommonParent.x += self.frame.origin.x
        selfPointInCommonParent.y += self.frame.origin.y
        
        var r: PDFRegion? = self.parent
        
        while r != nil && r != commonParent {
            selfPointInCommonParent.x += r!.frame.origin.x
            selfPointInCommonParent.y += r!.frame.origin.y
            
            r = r!.parent
        }
        
        // Get the origin of the region in the common parent
        var regionOriginInCommonParent: CGPoint = region.frame.origin
        
        if commonParent == region {
            regionOriginInCommonParent = .zero
        } else {
            var regionParent = region.parent
            
            while regionParent != commonParent {
                regionOriginInCommonParent.x += regionParent!.frame.origin.x
                regionOriginInCommonParent.y += regionParent!.frame.origin.y
                regionParent = regionParent!.parent
            }
        }
        
        var pointInRegionCoordinateSystem: CGPoint = selfPointInCommonParent
        pointInRegionCoordinateSystem.x -= regionOriginInCommonParent.x
        pointInRegionCoordinateSystem.y -= regionOriginInCommonParent.y
        
        return pointInRegionCoordinateSystem
    }
    
    // MARK: Debug
    
    /// Provides a recursive description of this region and children
    public final func recursiveDescription() -> String {
        var describedRegions: Set<PDFRegion> = []
        return recursiveDescription(0, describedRegions: &describedRegions)
    }
    
    private func recursiveDescription(_ indentLevel: Int, describedRegions: inout Set<PDFRegion>) -> String {
        var str = ""
        for _ in 0..<indentLevel {
            str += "\t|"
        }
        
        str += " \(String(describing: self))\n"
        describedRegions.insert(self)
        
        for child in _children {
            assert(!describedRegions.contains(child), "Error, recursion in drawing tree")
            if !describedRegions.contains(child) {
                str += child.recursiveDescription(indentLevel + 1, describedRegions: &describedRegions)
            }
        }
        
        return str
    }
    
    // MARK: Outline
    
    /**
     Returns the outline
     - parameters:
         - origin: The origin of the parent coordinate system
         - pageNum: The page number to use in the outline
     */
    public final func outline(origin: CGPoint, pageNum: Int) -> [String: Any]? {
        if self.outlineTitle != nil {
            var rect = self.frame
            rect.origin.x += origin.x
            rect.origin.y += origin.y
            
            return [
                "Destination": pageNum,
                "DestinationRect": [
                    "Width": rect.width,
                    "Height": rect.height,
                    "X": rect.origin.x,
                    "Y": rect.origin.y
                ],
                "Title": self.outlineTitle as Any
            ]
        }
        
        return nil
    }
    
    /**
     Returns the outline of self and all children recursively
     - parameters:
     - pageNum: The page number to use in the outline
     */
    public final func recursiveOutline(origin: CGPoint, pageNum: Int) -> [String: Any]? {
        var outlines: [[String: Any]] = []
        
        var hasOutline = false
        if let o = outline(origin: origin, pageNum: pageNum) {
            outlines.append(o)
            hasOutline = true
        }
        
        for child in children {
            var newOrigin = origin
            newOrigin.x += self.frame.origin.x
            newOrigin.y += self.frame.origin.y
            
            if let o = child.recursiveOutline(origin: newOrigin, pageNum: pageNum) {
                if o["Title"] == nil {
                    if let children = o["Children"] as? [[String: Any]] {
                        outlines.append(contentsOf: children)
                    } else {
                        outlines.append(o)
                    }
                } else {
                    outlines.append(o)
                }
            }
        }
        
        if outlines.count == 1 {
            return outlines[0]
        } else if hasOutline {
            var parentOutline = outlines[0]
            
            // Sort children by Y position
            parentOutline["Children"] = Array(outlines.dropFirst()).sorted {
                let destRect1 = $0["DestinationRect"] as! [String: Any]
                let y1 = destRect1["Y"] as! CGFloat
                
                let destRect2 = $1["DestinationRect"] as! [String: Any]
                let y2 = destRect2["Y"] as! CGFloat
                
                return y1 < y2
            }
            
            return parentOutline
        } else if outlines.count > 0 {
            return ["Children": outlines]
        }
        
        return nil
    }
    
    /// A returns the intrinsicContentSize of the region. Override this to provide your own value.
    public func intrinsicContentSize() -> CGSize? {
        return nil
    }
}

// MARK: - Equatable
extension PDFRegion: Equatable {
    /// :nodoc:
    public static func ==(lhs: PDFRegion, rhs: PDFRegion) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

// MARK: - Hashable
extension PDFRegion: Hashable {
    /// :nodoc:
    public var hashValue: Int {
        // Return a hash 'unique' to this object
        return ObjectIdentifier(self).hashValue
    }
}

// MARK: - CustomStringConvertible
extension PDFRegion: CustomStringConvertible {
    /// :nodoc:
    public var description: String {
        return "<\(type(of: self)), frame: \(frame))>"
    }
}
