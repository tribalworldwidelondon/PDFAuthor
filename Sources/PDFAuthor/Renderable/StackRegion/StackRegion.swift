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

/// A PDF region that arranges its subregions in a vertical or horizontal stack
public class StackRegion: PDFRegion {

    /// The layout of arranged regions perpendicular to the stack region's axis
    public var alignment:       StackRegionAlignment    = .fill

    /// The axis along which the arranged regions are laid out.
    public var axis:            StackRegionAxis         = .vertical

    /// The distribution of the arranged regions along the stack region's axis.
    public var distribution:    StackRegionDistribution = .fill

    /// The spacing between each laid out region.
    public var spacing:         CGFloat                 = 0.0

    /// The arranged regions of the stack region.
    public var arrangedRegions: [PDFRegion]             = []

    /// :nodoc:
    public override var constraints: [Constraint] {
        get {
            return super.constraints + constraintsForArrangedRegions()
        }

        set {
            translatesAutoresizingMaskIntoConstraints = false
            _constraints = newValue
        }
    }

    // MARK: Initializers
    
    /// Default initializer
    public override init() {
        super.init(frame: .zero)
    }
    
    /// Initialize with a set of arranged regions
    public init(arrangedRegions: [PDFRegion]) {
        super.init(frame: .zero)
        addArrangedRegions(arrangedRegions)
    }

    // MARK: Managing Arranged Regions

    /// Add a region to the end of the arrangedRegions array.
    public func addArrangedRegion(_ region: PDFRegion) {
        arrangedRegions.append(region)
        addChild(region)
    }

    /// Adds regions to the end of the arrangedRegions array.
    public func addArrangedRegions(_ regions: [PDFRegion]) {
        for region in regions {
            addArrangedRegion(region)
        }
    }

    /// Adds regions to the end of the arrangedRegions array.
    public func addArrangedRegions(_ regions: PDFRegion...) {
        addArrangedRegions(regions)
    }

    /**
     Inserts a region into the arrangedRegions array at the given index.
     - parameters:
         - region: The region to add.
         - index: The index at which to add the region.
     */
    public func insertArrangedRegion(_ region: PDFRegion, at index: Int) {
        assert(index >= arrangedRegions.startIndex && index <= arrangedRegions.endIndex, "Index out of bounds!")
        arrangedRegions.insert(region, at: index)
    }

    /// Removes a region from the arrangedRegions array.
    public func removeArrangedRegion(_ region: PDFRegion) {
        guard let index = arrangedRegions.index(of: region) else {
            assertionFailure("Region is not in the arrangedRegions array.")
            return
        }

        arrangedRegions.remove(at: index)
        region.removeFromParent()
    }

    // MARK: Constraints

    internal func constraintsForArrangedRegions() -> [Constraint] {
        switch axis {
            case .horizontal:
                return constraintsForHorizontalAxis()
            case .vertical:
                return constraintsForVerticalAxis()
        }
    }

    internal func constraintsForVerticalAxis() -> [Constraint] {
        let perpendicularConstraints: [Constraint] = perpendicularConstraintsForVerticalAxis(alignment)

        var axisConstraints: [Constraint] = []

        let intrinsicContentSizes = arrangedRegions.map { $0.intrinsicContentSize() }
        let totalHeight = intrinsicContentSizes.map { $0?.height ?? 1.0 }.reduce(0.0) { $0 + $1 }
        let heightProportions = intrinsicContentSizes.map { $0?.height ?? 0.0 / totalHeight }

        for (index, region) in arrangedRegions.enumerated() {
            switch distribution {
                case .fill:
                    if index == 0 {
                        axisConstraints.append(region.top == self.topInset)
                        if(arrangedRegions.count == 1) {
                            axisConstraints.append(region.bottom == self.bottomInset)
                        }
                    } else if index == arrangedRegions.count - 1 {
                        let constraint = region.top == arrangedRegions[index - 1].bottom + spacing
                        axisConstraints.append(constraint)
                        axisConstraints.append(region.bottom == self.bottomInset)
                    } else {
                        let constraint = region.top == arrangedRegions[index - 1].bottom + spacing
                        axisConstraints.append(constraint)
                    }

                case .fillEqually:
                    if index == 0 {
                        axisConstraints.append(region.top == self.topInset)
                        if(arrangedRegions.count == 1) {
                            axisConstraints.append(region.bottom == self.bottomInset)
                        }
                    } else if index == arrangedRegions.count - 1 {
                        let constraint = region.top == arrangedRegions[index - 1].bottom + spacing
                        axisConstraints.append(constraint)
                        axisConstraints.append(region.bottom == self.bottomInset)
                        axisConstraints.append(region.height == arrangedRegions[index - 1].height)
                    } else {
                        let constraint = region.top == arrangedRegions[index - 1].bottom + spacing
                        axisConstraints.append(constraint)
                        axisConstraints.append(region.height == arrangedRegions[index - 1].height)
                    }

                case .fillProportionally:
                    if index == 0 {
                        axisConstraints.append(region.top == self.topInset)
                        if(arrangedRegions.count == 1) {
                            axisConstraints.append(region.bottom == self.bottomInset)
                        }
                    } else if index == arrangedRegions.count - 1 {
                        let constraint = region.top == arrangedRegions[index - 1].bottom + spacing
                        axisConstraints.append(constraint)
                        axisConstraints.append(region.bottom == self.bottomInset)
                        axisConstraints.append(region.height == self.height * heightProportions[index])
                    } else {
                        let constraint = region.top == arrangedRegions[index - 1].bottom + spacing
                        axisConstraints.append(constraint)
                    }

                case .equalSpacing:
                    // TODO: Implement
                    if index == 0 {
                        axisConstraints.append(region.top == self.topInset)
                        if(arrangedRegions.count == 1) {
                            axisConstraints.append(region.bottom == self.bottomInset)
                        }
                    } else if index == arrangedRegions.count - 1 {
                        let constraint = region.top == arrangedRegions[index - 1].bottom + spacing
                        axisConstraints.append(constraint)
                        axisConstraints.append(region.bottom == self.bottomInset)
                    } else {
                        let constraint = region.top == arrangedRegions[index - 1].bottom + spacing
                        axisConstraints.append(constraint)
                    }

                case .equalCentering:
                    // TODO: Implement
                    if index == 0 {
                        axisConstraints.append(region.top == self.topInset)
                        if(arrangedRegions.count == 1) {
                            axisConstraints.append(region.bottom == self.bottomInset)
                        }
                    } else if index == arrangedRegions.count - 1 {
                        let constraint = region.top == arrangedRegions[index - 1].bottom + spacing
                        axisConstraints.append(constraint)
                        axisConstraints.append(region.bottom == self.bottomInset)
                    } else {
                        let constraint = region.top == arrangedRegions[index - 1].bottom + spacing
                        axisConstraints.append(constraint)
                    }
                }
            }

            return perpendicularConstraints + axisConstraints
        }

        internal func perpendicularConstraintsForVerticalAxis(_ alignment: StackRegionAlignment) -> [Constraint] {
            var constraints: [Constraint] = []

            for region in arrangedRegions {
                switch alignment {
                    case .fill:
                        constraints += [
                            region.left == self.leftInset,
                            region.right == self.rightInset
                        ]
                    case .leading:
                        constraints += [
                            region.leading == self.leading,
                            self.width >= region.width
                        ]
                    case .center:
                        constraints += [
                            region.centerX == self.centerX,
                            self.width >= region.width
                        ]

                    default:
                        // If the alignment doesn't make sense for this axis, just return .fill constraints instead.
                        print("Alignment \(alignment) doesn't make sense for Vertical axis! Using .fill instead.")
                        constraints += perpendicularConstraintsForVerticalAxis(.fill)
                }
            }

            return constraints
        }

        internal func constraintsForHorizontalAxis() -> [Constraint] {
            let perpendicularConstraints: [Constraint] = perpendicularConstraintsForHorizontalAxis(alignment)

            var axisConstraints: [Constraint] = []

            let intrinsicContentSizes = arrangedRegions.map { $0.intrinsicContentSize() }
            let totalWidth = intrinsicContentSizes.map { $0?.width ?? 1.0 }.reduce(0.0) { $0 + $1 }
            let widthProportions = intrinsicContentSizes.map { $0?.width ?? 0.0 / totalWidth }

            for (index, region) in arrangedRegions.enumerated() {
                switch distribution {
                    case .fill:
                        if index == 0 {
                            axisConstraints.append(region.left == self.leftInset)
                            if(arrangedRegions.count == 1) {
                                axisConstraints.append(region.right == self.rightInset)
                            }
                        } else if index == arrangedRegions.count - 1 {
                            let constraint = region.left == arrangedRegions[index - 1].right + spacing
                            axisConstraints.append(constraint)
                            axisConstraints.append(region.right == self.rightInset)
                        } else {
                            let constraint = region.left == arrangedRegions[index - 1].right + spacing
                            axisConstraints.append(constraint)
                        }

                    case .fillEqually:
                        if index == 0 {
                            axisConstraints.append(region.left == self.leftInset)
                            axisConstraints.append(region.width == self.width / arrangedRegions.count)
                            if(arrangedRegions.count == 1) {
                                axisConstraints.append(region.right == self.rightInset)
                            }
                        } else if index == arrangedRegions.count - 1 {
                            let constraint = region.left == arrangedRegions[index - 1].right + spacing
                            axisConstraints.append(constraint)
                            axisConstraints.append(region.right == self.rightInset)
                            axisConstraints.append(region.width == self.width / arrangedRegions.count)
                        } else {
                            let constraint = region.left == arrangedRegions[index - 1].right + spacing
                            axisConstraints.append(constraint)
                            axisConstraints.append(region.width == self.width / arrangedRegions.count)
                        }

                    case .fillProportionally:
                        if index == 0 {
                            axisConstraints.append(region.left == self.leftInset)
                            if(arrangedRegions.count == 1) {
                                axisConstraints.append(region.right == self.rightInset)
                            }
                        } else if index == arrangedRegions.count - 1 {
                            let constraint = region.right == arrangedRegions[index - 1].right + spacing
                            axisConstraints.append(constraint)
                            axisConstraints.append(region.right == self.rightInset)
                            axisConstraints.append(region.width == self.width * widthProportions[index])
                        } else {
                            let constraint = region.left == arrangedRegions[index - 1].right + spacing
                            axisConstraints.append(constraint)
                        }

                    case .equalSpacing:
                        // TODO: Implement
                        if index == 0 {
                            axisConstraints.append(region.left == self.leftInset)
                            if(arrangedRegions.count == 1) {
                                axisConstraints.append(region.right == self.rightInset)
                            }
                        } else if index == arrangedRegions.count - 1 {
                            let constraint = region.left == arrangedRegions[index - 1].right + spacing
                            axisConstraints.append(constraint)
                            axisConstraints.append(region.right == self.rightInset)
                        } else {
                            let constraint = region.left == arrangedRegions[index - 1].right + spacing
                            axisConstraints.append(constraint)
                        }

                    case .equalCentering:
                        // TODO: Implement
                        if index == 0 {
                            axisConstraints.append(region.left == self.leftInset)
                            if(arrangedRegions.count == 1) {
                                axisConstraints.append(region.right == self.rightInset)
                            }
                        } else if index == arrangedRegions.count - 1 {
                            let constraint = region.left == arrangedRegions[index - 1].right + spacing
                            axisConstraints.append(constraint)
                            axisConstraints.append(region.right == self.rightInset)
                        } else {
                            let constraint = region.left == arrangedRegions[index - 1].right + spacing
                            axisConstraints.append(constraint)
                        }
                }
            }
            
            return perpendicularConstraints + axisConstraints
        }

    internal func perpendicularConstraintsForHorizontalAxis(_ alignment: StackRegionAlignment) -> [Constraint] {
        var constraints: [Constraint] = []

        for region in arrangedRegions {
            switch alignment {
                case .fill:
                    constraints += [
                        region.top == self.topInset,
                        region.bottom == self.bottomInset
                    ]
                case .top:
                    constraints += [
                        region.top == self.topInset,
                        self.height >= region.height
                    ]
                case .firstBaseline:
                    // TODO: Implement firstBaseline, then update
                    constraints += [
                        region.top == self.topInset,
                        self.height >= region.height
                    ]
                case .center:
                    constraints += [
                        region.centerY == self.centerY,
                        self.height >= region.height + self.edgeInsetTop + self.edgeInsetBottom
                    ]
                case .bottom:
                    constraints += [
                        region.bottom == self.bottomInset,
                        self.height >= region.height
                    ]
                case .lastBaseline:
                    constraints += [
                        region.bottom == self.bottomInset,
                        self.height >= region.height
                    ]

                default:
                    // If the alignment doesn't make sense for this axis, just return .fill constraints instead.
                    print("Alignment \(alignment) doesn't make sense for Horizontal axis! Using .fill instead.")
                    constraints += perpendicularConstraintsForVerticalAxis(.fill)
            }
        }

        return constraints
    }
    }
