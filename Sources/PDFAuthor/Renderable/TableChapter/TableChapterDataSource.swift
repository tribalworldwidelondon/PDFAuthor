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

/**
 `TableChapterDataSource` is a protocol that is adopted by an object that provides the data model for a `TableChapter`.
 */
public protocol TableChapterDataSource: class {

	// MARK: Configuring a Table Chapter

	/**
	 Asks the data source for a region to insert at a particular location in the table.
	 */
	func tableChapter(_ tableChapter: TableChapter, regionFor indexPath: PDFIndexPath) -> PDFRegion

	/// Asks the data source for the number of sections in the table.
	func numberOfSections(in: TableChapter) -> UInt

	/// Asks the data source for the number of rows in a particular section in the table.
	func tableChapter(_ tableChapter: TableChapter, numberOfRowsInSection section: Int) -> Int

	/// Asks the data source for the number of columns in a particular section in the table.
	func tableChapter(_ tableChapter: TableChapter, numberOfColumnsInSection section: Int) -> Int

	// MARK: Row Formatting

	/// Asks the data source for the background color of a row in the table
	func tableChapter(_ tableChapter: TableChapter, backgroundColorForRowAtIndexPath indexPath: PDFIndexPath) -> PDFColor?

	/**
	 Asks the data source for the background color of the page at the given index.
	 When not nil, this overrides the global page color.
	 */
	func tableChapter(_ tableChapter: TableChapter, backgroundColorForPage page: Int) -> PDFColor?

	/**
	 Asks the data source for a background region to add to the page at the given index.
	 When not nil, the region is added as a child of the page, with the constraints making
	 the edges equal to the background insets of the page.
	 */
	func tableChapter(_ tableChapter: TableChapter, backgroundRegionForPage page: Int) -> PDFRegion?

	// MARK: Column Formatting

	/**
	 Asks the data source for the width weights of a particular column in a table section.

	 You should return an array of Doubles with one value for each column in the section.
	 Each value is the width of the column as a percentage of the total.

	 e.g. `[1.0, 1.0, 2.0, 1.0]` will cause the 3rd column to be twice as wide as the rest.
	 */
	func tableChapter(_ tableChapter: TableChapter, columnWidthWeightsForSection section: Int) -> [Double]?

	/// Asks the data source for the inter-column spacing in the given section.
	func tableChapter(_ tableChapter: TableChapter, spacingForColumnsInSection section: Int) -> Double

	/// Asks the data source for the insets for the given section.
	func tableChapter(_ tableChapter: TableChapter, insetsForSection section: Int) -> PDFEdgeInsets

	/// Asks the data source for the insets for the given row.
	func tableChapter(_ tableChapter: TableChapter, insetsForRowAtIndexPath indexPath: PDFIndexPath) -> PDFEdgeInsets

	// MARK: Headers and Footers

	/// Asks the data source for the header region for the given page.
	func tableChapter(_ tableChapter: TableChapter, headerRegionForPage page: Int) -> PDFRegion?

	/// Asks the data source for the footer region for the given page.
	func tableChapter(_ tableChapter: TableChapter, footerRegionForPage page: Int) -> PDFRegion?

	/// Asks the data source for the header region for the given section.
	func tableChapter(_ tableChapter: TableChapter, headerRegionForSection section: Int) -> PDFRegion?

	/// Asks the data source for the footer region for the given section.
	func tableChapter(_ tableChapter: TableChapter, footerRegionForSection section: Int) -> PDFRegion?

	// MARK: PDF Outline

	/**
	 Asks the data source for the outline title for the given section in the PDF.
	 Returning nil will mean that the section does not appear in the outline.
	 */
	func tableChapter(_ tableChapter: TableChapter, outlineTitleForSection: Int) -> String?
}

// Provide default implementations of all optional methods

public extension TableChapterDataSource {

	func tableChapter(_ tableChapter: TableChapter, backgroundColorForRowAtIndexPath indexPath: PDFIndexPath) -> PDFColor? {
		return nil
	}

	func tableChapter(_ tableChapter: TableChapter, backgroundColorForPage page: Int) -> PDFColor? {
		return nil
	}

	func tableChapter(_ tableChapter: TableChapter, backgroundRegionForPage page: Int) -> PDFRegion? {
		return nil
	}

	func tableChapter(_ tableChapter: TableChapter, columnWidthWeightsForSection section: Int) -> [Double]? {
		return nil
	}

	func tableChapter(_ tableChapter: TableChapter, spacingForColumnsInSection section: Int) -> Double {
		return 0.0
	}

	func tableChapter(_ tableChapter: TableChapter, headerRegionForPage page: Int) -> PDFRegion? {
		return nil
	}

	func tableChapter(_ tableChapter: TableChapter, footerRegionForPage page: Int) -> PDFRegion? {
		return nil
	}

	func tableChapter(_ tableChapter: TableChapter, headerRegionForSection section: Int) -> PDFRegion? {
		return nil
	}

	func tableChapter(_ tableChapter: TableChapter, footerRegionForSection section: Int) -> PDFRegion? {
		return nil
	}

	func tableChapter(_ tableChapter: TableChapter, outlineTitleForSection section: Int) -> String? {
		return nil
	}

	func tableChapter(_ tableChapter: TableChapter, insetsForSection section: Int) -> PDFEdgeInsets {
		return .zero
	}

	func tableChapter(_ tableChapter: TableChapter, insetsForRowAtIndexPath indexPath: PDFIndexPath) -> PDFEdgeInsets {
		return .zero
	}
}
