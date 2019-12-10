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

/// The axis along which to align the arrange regions.
public enum StackRegionAxis {
	/// Aligns regions horizontally.
	case horizontal

	/// Aligns regions vertically.
	case vertical
}

/// The layout of arranged regions perpendicular to the stack region's axis.
public enum StackRegionAlignment {
	/// Fill all available space
	case fill

	/// For vertical stacks: aligns the leading edges of the arranged regions along its leading edge.
	case leading

	/// For horizontal stacks: aligns the top edges of the arranged regions along its top edge.
	case top

	/// For horizontal stacks: aligns the arranged regions based on their first baseline.
	case firstBaseline

	/// Aligns the center of its arranged regions with its center along the axis.
	case center

	/// For vertical stacks: aligns the trailing edges of the arranged regions along its trailing edge.
	case trailing

	/// For horizontal stacks: aligns the bottom edges of the arranged regions along its bottom edge.
	case bottom

	/// For horizontal stacks: aligns the arranged regions based on their last baseline.
	case lastBaseline
}

/// Defines the size and position of the arranged views along the stack regions's axis
public enum StackRegionDistribution {
	/// A layout where the arranged regions fill the available space along the stack region's axis.
	case fill

	/// A layout where the arranged regions fill the available space along the stack region's axis, where each
	/// arranged region has an equal size along the stack region's axis.
	case fillEqually

	/// A layout where the arranged regions fill the available space along the axis. Views are resized proportionally
	/// according to their intrinsic content size.
	case fillProportionally

	/// A layout where the arranged regions are padded equally where they do not fill the space.
	case equalSpacing

	/// A layout that attempts to make sure that each arranged region has equal center to center spacing.
	case equalCentering
}
