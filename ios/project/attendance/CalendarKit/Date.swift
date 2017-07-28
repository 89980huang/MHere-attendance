//
//  Date.swift
//  CalendarLogic
//
//  Created by Lancy on 01/06/15.
//  Copyright (c) 2015 Lancy. All rights reserved.
//

import Foundation

class Date: CustomStringConvertible, Equatable {
    
    var day: Int
    var month: Int
    var year: Int
    
    var isToday: Bool {
        let today = Date(date: Foundation.Date())
        return (isEqual(today) == .orderedSame)
    }
    
    func isEqual(_ date: Date) -> ComparisonResult {
        let selfComposite = (year * 10000) + (month * 100) + day
        let otherComposite = (date.year * 10000) + (date.month * 100) + date.day
        
        if selfComposite < otherComposite {
            return .orderedAscending
        } else if selfComposite == otherComposite {
            return .orderedSame
        } else {
            return .orderedDescending
        }
    }
    
    init(day: Int, month: Int, year: Int) {
        self.day = day
        self.month = month
        self.year = year
    }
    
    init(date: Foundation.Date) {
        let part = date.monthDayAndYearComponents
        
        self.day = part.day
        self.month = part.month
        self.year = part.year
    }
    
    var nsdate: Foundation.Date {
        return Foundation.Date.date(day, month: month, year: year)
    }
    
    var description: String {
        return "\(day)-\(month)-\(year)"
    }
}

func ==(lhs: Date, rhs: Date) -> Bool {
    return ((lhs.day == rhs.day) && (lhs.month == rhs.month) && (lhs.year == rhs.year))
}
