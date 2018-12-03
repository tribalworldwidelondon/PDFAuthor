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

struct PhoneCall: Comparable {
    static func <(lhs: PhoneCall, rhs: PhoneCall) -> Bool {
        return lhs.date < rhs.date
    }
    
    static func ==(lhs: PhoneCall, rhs: PhoneCall) -> Bool {
        return lhs.date == rhs.date
    }
    
    let number:   String
    let date:     Date
    let duration: TimeInterval

    var price: NSNumber {
        return duration * 0.2 as NSNumber
    }

    var priceString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: price)!
    }

    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter.string(from: date)
    }

    var time: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: date)
    }
}

func generateRandomCalls(_ number: Int = 100) -> [PhoneCall] {
    var calls: [PhoneCall] = []

    for _ in 0..<number {
        // Generate random phone number
        var phoneNumber = "+44 "
        for n in 0..<13 {
            if n == 4 || n == 8 {
                phoneNumber += " "
            } else {
                phoneNumber += "\(arc4random_uniform(10))"
            }
        }

        // Random date in the past 100 days
        let date = Date(timeIntervalSinceNow: TimeInterval(arc4random_uniform(60 * 60 * 24 * 100)))

        // Random length of call, up to an hour
        let duration = TimeInterval(arc4random_uniform(60 * 60))

        let call = PhoneCall(number: phoneNumber,
                             date: date,
                             duration: duration)
        calls.append(call)
    }

    return calls
}

class PhoneBillChapter: TableChapter, TableChapterDataSource {
    
    let phoneCalls = generateRandomCalls(30)
    
    override init(pageSpecifications: PDFPageSpecifications) {
        super.init(pageSpecifications: pageSpecifications)
        self.outlineTitle = "Phone Bill Example"
        self.dataSource = self
    }

    func numberOfSections(in: TableChapter) -> UInt {
        return 1
    }
    
    func tableChapter(_ tableChapter: TableChapter, numberOfColumnsInSection: Int) -> Int {
        return 5
    }
    
    func tableChapter(_ tableChapter: TableChapter, numberOfRowsInSection: Int) -> Int {
        return phoneCalls.count
    }
    
    func tableChapter(_ tableChapter: TableChapter, spacingForColumnsInSection: Int) -> Double {
        return 5.0
    }
    
    func tableChapter(_ tableChapter: TableChapter, backgroundColorForRowAtIndexPath indexPath: PDFIndexPath) -> PDFColor? {
        return indexPath.row % 2 == 0 ? .clear : PDFColor(white: 0.9, alpha: 1.0)
    }
    
    func tableChapter(_ tableChapter: TableChapter, headerRegionForPage page: Int) -> PDFRegion? {
        let mainStack = StackRegion()
        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.distribution = .fill
        
        let components = Calendar.current.dateComponents([.month, .year], from: Date())
        let month = Calendar.current.monthSymbols[components.month! - 1]

        var titleText = "Bill Details for \(month) \(components.year!)"
        
        if page > 0 {
            titleText += " (continued)"
        }
        
        let titleRegion = StringRegion(string: titleText, font: PDFFont.systemFont(ofSize: 20))
        titleRegion.edgeInsets.bottom = 16
        mainStack.addArrangedRegion(titleRegion)
        
        if page == 0 {
            let detailsStack = StackRegion()
            detailsStack.axis = .horizontal
            detailsStack.distribution = .fillEqually
            detailsStack.alignment = .fill
            
            detailsStack.addArrangedRegion(StringRegion(string: "Account Number: 123456"))
            detailsStack.addArrangedRegion(StringRegion(string: "Bill Number: 654321"))
            
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            detailsStack.addArrangedRegion(StringRegion(string: "Bill Date: \(formatter.string(from: Date()))"))
            
            mainStack.addArrangedRegion(detailsStack)
            
            let spacer = PDFRegion(frame: .zero)
            spacer.addConstraint(spacer.height == 32.0)
            mainStack.addArrangedRegion(spacer)
        }
        
        return mainStack
    }
    
    func tableChapter(_ tableChapter: TableChapter, headerRegionForSection section: Int) -> PDFRegion? {
        let region = StackRegion(arrangedRegions: [
            StringRegion(string: "Phone Number", color: .white),
            StringRegion(string: "Date", color: .white),
            StringRegion(string: "Time", color: .white),
            StringRegion(string: "Duration", color: .white),
            StringRegion(string: "Price (£)", color: .white)
        ])
        
        region.backgroundColor = .gray
        region.axis = .horizontal
        region.distribution = .fillEqually
        region.alignment = .center
        
        region.edgeInsets = PDFEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return region
    }
    
    func tableChapter(_ tableChapter: TableChapter, regionFor indexPath: PDFIndexPath) -> PDFRegion {
        let call = phoneCalls[indexPath.row]
        
        switch indexPath.column {
        case 0:
            let region = StringRegion(string: call.number)
            region.outlineTitle = call.number
            return region
        case 1:
            return StringRegion(string: call.dateString)
        case 2:
            return StringRegion(string: call.time)
        case 3:
            return StringRegion(string: "\(call.duration)")
        case 4:
            let r = StringRegion(string: call.priceString)
            r.addConstraints(r.height == 40.0)
            return r
        default:
            return PDFRegion(frame: .zero)
        }
    }
    
    func tableChapter(_ tableChapter: TableChapter, insetsForRowAtIndexPath indexPath: PDFIndexPath) -> PDFEdgeInsets {
        return PDFEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
}
