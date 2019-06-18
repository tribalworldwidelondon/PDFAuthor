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

/// A structure representing an index into a table
public struct PDFIndexPath {
    /// The table section
    public var section: Int

    /// The row in the given section
    public var row: Int

    /// The column in the given row, in the given section
    public var column: Int
}

protocol TableChapterDelegate {

}

/// A PDF chapter that generates a table
open class TableChapter: PDFChapter {

    /// The datasource object for the Table Chapter
    public weak var dataSource: TableChapterDataSource?

    // MARK: Current page variables

    private var currentY: CGFloat = 0
    private var currentPageNum: Int {
        return pages.count - 1
    }

    private var footerHeight: CGFloat = 0

    private var remainingSpace: CGFloat {
        return currentPage.specifications.size.height
                - currentY
                - footerHeight
                - currentPage.specifications.contentInsets.bottom
    }

    private var currentPage: PDFPage {
        if pages.count == 0 {
            return newTablePage()
        }

        return pages.last!
    }

    /// Default background color for pages. Can be overridden by the delegate method
    public var pageBackgroundColor: PDFColor?

    public var contentWidth: CGFloat {
        return self.pageSpecifications.size.width - self.pageSpecifications.contentInsets.left - self.pageSpecifications.contentInsets.right
    }

    // MARK: Dynamic Generation

    open override func generate() {
        guard dataSource != nil else {
            return
        }

        let sectionInfo = getSectionInfo()

        for (offset:section, element:element) in sectionInfo.enumerated() {
            let (numRows: numRows, numCols: numCols, columnWeights: columnWeights, columnSpacing: columnSpacing) = element

            let sectionRows = rows(forSection: section,
                    numRows: numRows,
                    numColumns: numCols,
                    columnWeights: columnWeights,
                    columnSpacing: columnSpacing)

            renderRows(sectionRows: sectionRows, forSection: section, renderHeader: true)
        }
    }

    internal func renderRows(sectionRows: [PDFRegion], forSection section: Int, renderHeader: Bool) {
        if (renderHeader) {
            if let header = dataSource!.tableChapter(self, headerRegionForSection: section) {
                renderSectionHeader(header, forSection: section)
            } else {
                let sectionInsets = dataSource!.tableChapter(self, insetsForSection: section)
                currentY += sectionInsets.top
            }
        }

        let sectionInsets = dataSource!.tableChapter(self, insetsForSection: section)

        for (offset:idx, element:row) in sectionRows.enumerated() {
            // If there is not enough space left for the row, start a new page
            if remainingSpace < CGFloat(row.height.value) && idx > 0 {
                newTablePage()

                let remainingRows = Array(sectionRows.dropFirst(idx))

                // Recursively call, but don't render the header, since we've already done that.
                renderRows(sectionRows: remainingRows, forSection: section, renderHeader: false)
                return
            }

            row.addConstraints(row.left == currentPage.leftInset + sectionInsets.left, row.top == currentY)
            currentPage.addChild(row)
            currentY += CGFloat(row.frame.size.height)
        }

        if let footer = dataSource!.tableChapter(self, footerRegionForSection: section) {
            footer.addConstraints(footer.width == currentPage.contentWidth)
            footer.updateConstraints()
            let footerHeight = CGFloat(footer.height.value)

            if remainingSpace < footerHeight {
                newTablePage()
            }

            currentPage.addChild(footer)

            footer.addConstraints(footer.top == currentY,
                                  footer.left == currentPage.leftInset)
            currentY += footerHeight
        }

    }

    internal func renderSectionHeader(_ header: PDFRegion, forSection section: Int) {
        currentPage.addChild(header)

        let sectionInsets = dataSource!.tableChapter(self, insetsForSection: section)
        let sectionWidth = widthForSection(section)


        header.addConstraints(header.left == currentPage.leftInset + sectionInsets.left,
                header.top == currentY + sectionInsets.top,
                header.width == sectionWidth)

        header.updateConstraints()

        let headerHeight = CGFloat(header.height.value)

        if headerHeight > remainingSpace {
            newTablePage()
        }

        currentY += headerHeight + sectionInsets.top
    }

    @discardableResult
    internal func newTablePage() -> PDFPage {

        return withNewPage {
            if let backgroundRegion = self.dataSource?.tableChapter(self,
                                                                     backgroundRegionForPage: self.currentPageNum) {
                $0.addChild(backgroundRegion)
                backgroundRegion.addConstraints(backgroundRegion.top == $0.topBackgroundInset,
                                                backgroundRegion.bottom == $0.bottomBackgroundInset,
                                                backgroundRegion.left == $0.leftBackgroundInset,
                                                backgroundRegion.right == $0.rightBackgroundInset)
            }
            
            if let color = self.dataSource?.tableChapter(self, backgroundColorForPage: self.currentPageNum) {
                $0.backgroundColor = color
            } else if let color = self.pageBackgroundColor {
                $0.backgroundColor = color
            }

            self.currentY = currentPage.edgeInsets.top

            guard let ds = self.dataSource else {
                return
            }

            if let pageHeader: PDFRegion = ds.tableChapter(self, headerRegionForPage: currentPageNum) {
                let headerWidth = currentPage.specifications.size.width
                        - currentPage.edgeInsets.left
                        - currentPage.edgeInsets.right

                $0.addChild(pageHeader)
                pageHeader.addConstraints(pageHeader.left == currentPage.leftInset,
                        pageHeader.top == currentPage.topInset,
                        pageHeader.width == headerWidth)

                pageHeader.calculateConstraints()
                pageHeader.recursivelyUpdateFrames(transform: .zero)

                currentY += CGFloat(pageHeader.height.value)
            }

            if let pageFooter: PDFRegion = ds.tableChapter(self, footerRegionForPage: currentPageNum) {
                let footerWidth = currentPage.specifications.size.width
                        - currentPage.edgeInsets.left
                        - currentPage.edgeInsets.right

                $0.addChild(pageFooter)

                pageFooter.addConstraints(pageFooter.left == currentPage.leftInset,
                        pageFooter.bottom == currentPage.bottomInset,
                        pageFooter.width == footerWidth)

                pageFooter.calculateConstraints()
                pageFooter.recursivelyUpdateFrames(transform: .zero)
                footerHeight = CGFloat(pageFooter.height.value)

                pageFooter.addConstraint(pageFooter.height == footerHeight)
            } else {
                footerHeight = 0
            }
        }
    }

    internal func widthForSection(_ section: Int) -> CGFloat {
        let sectionInsets = dataSource!.tableChapter(self, insetsForSection: section)
        return currentPage.specifications.size.width
                - currentPage.edgeInsets.left
                - currentPage.edgeInsets.right
                - sectionInsets.left
                - sectionInsets.right
    }

    internal func getSectionInfo() -> [(numRows: Int, numCols: Int, columnWeights: [Double], columnSpacing: Double)] {
        let numSections = dataSource!.numberOfSections(in: self)

        var sectionInfo: [(numRows: Int, numCols: Int, columnWeights: [Double], columnSpacing: Double)] = []

        for section in 0..<numSections {
            let numRows = dataSource!.tableChapter(self, numberOfRowsInSection: Int(section))
            let numCols = dataSource!.tableChapter(self, numberOfColumnsInSection: Int(section))
            let columnWeights = dataSource!.tableChapter(self,
                    columnWidthWeightsForSection: Int(section))
                    ?? [Double](repeating: 1.0 / Double(numCols), count: numCols)
            let columnSpacing = dataSource!.tableChapter(self, spacingForColumnsInSection: Int(section))

            assert(columnWeights.count == numCols, "Number of width weights provided is not equal to the number of columns!")

            sectionInfo.append((numRows: numRows,
                    numCols: numCols,
                    columnWeights: columnWeights,
                    columnSpacing: columnSpacing))
        }

        return sectionInfo
    }

    internal func columns(forRow row: Int, inSection section: Int, numColumns: Int) -> [PDFRegion] {
        var columns: [PDFRegion] = []

        for column in 0..<numColumns {
            let newIndex = PDFIndexPath(section: section, row: row, column: column)
            columns.append(dataSource!.tableChapter(self, regionFor: newIndex))
        }

        return columns
    }

    /// Generates a region containing all column regions for a row, and sets up the constraints accordingly
    internal func regionForRow(columns: [PDFRegion], weights: [Double], spacing: Double, insets: PDFEdgeInsets, rowWidth: Double) -> PDFRegion {
        let row = PDFRegion(frame: .zero)
        row.edgeInsets = insets

        for column in columns {
            row.addChild(column)

            // Add constraints for the top and bottom
            column.addConstraints(column.top == row.topInset, column.bottom <= row.bottomInset)
        }

        // Constrain the first and last column to the edges of the row
        let firstCol = columns.first!
        let lastCol = columns.last!

        firstCol.addConstraints(firstCol.left == row.leftInset)
        lastCol.addConstraints(lastCol.right == row.rightInset)

        // Set up the constraints between the columns

        for i in 0..<columns.count {
            let col = columns[i]

            // Add width constraint
            let space = (spacing * Double(columns.count - 1))
            let columnWidth = ((rowWidth - Double(row.edgeInsets.left - row.edgeInsets.right) - space) * weights[i])
            col.addConstraints((col.width == columnWidth).setStrength(Strength.STRONG))

            if i < 1 {
                continue
            }

            let lastCol = columns[i - 1]
            col.addConstraints(col.left == lastCol.right + spacing)
        }

        return row
    }

    internal func rows(forSection section: Int, numRows: Int, numColumns: Int, columnWeights: [Double], columnSpacing: Double) -> [PDFRegion] {
        var rows: [PDFRegion] = []

        let sectionWidth = widthForSection(section)

        for rowNum in 0..<numRows {
            let rowColumns = columns(forRow: rowNum, inSection: section, numColumns: numColumns)
            let rowInsets = dataSource!.tableChapter(self, insetsForRowAtIndexPath: PDFIndexPath(section: section, row: rowNum, column: 0))
            let row = regionForRow(columns: rowColumns, weights: columnWeights, spacing: columnSpacing, insets: rowInsets, rowWidth: Double(sectionWidth))

            row.addConstraints(row.width == sectionWidth)

            // Calculate the constraints for the row and update the frames so that the section
            // height can be calculated.
            row.updateConstraints()

            if let color = dataSource!.tableChapter(self, backgroundColorForRowAtIndexPath: PDFIndexPath(section: section, row: rowNum, column: 0)) {
                row.backgroundColor = color
            }

            rows.append(row)
        }

        return rows
    }

    internal func height(forRows rows: [PDFRegion]) -> CGFloat {
        return rows.reduce(0.0) {
            return $0 + $1.frame.size.height
        }
    }
}
