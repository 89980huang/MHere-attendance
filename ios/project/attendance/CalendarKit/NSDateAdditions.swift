//
//  Additions.swift
//  CalendarLogic
//
//  Created by Lancy on 01/06/15.
//  Copyright (c) 2015 Lancy. All rights reserved.
//

import Foundation

extension Foundation.Date {
    
    class func date(_ day: Int, month: Int, year: Int) -> Foundation.Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let dayString = String(format: "%02d", day)
        let monthString = String(format: "%02d", month)
        let yearString = String(format: "%04d", year)
        
        return dateFormatter.date(from: dayString + "/" + monthString + "/" + yearString)!
    }
   
    var startOfDay: Foundation.Date {
        let components = self.components
        
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        return Calendar.current.date(from: components)!
    }
    
    var endOfTheDay: Foundation.Date {
        let components = self.components
        
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        return Calendar.current.date(from: components)!
    }

    var firstDayOfTheMonth: Foundation.Date {
        var date: Foundation.Date?
        (Calendar.current as NSCalendar).range(of: .month, start:&date , interval: nil, for: self)
        return date!
    }

    var firstDayOfPreviousMonth: Foundation.Date {
        return firstDay(false)
    }
    
    var firstDayOfFollowingMonth: Foundation.Date {
        return firstDay(true)
    }
    
    var monthDayAndYearComponents: DateComponents {
        let components: NSCalendar.Unit = [.year, .month, .day]
        return (Calendar.current as NSCalendar).components(components, from: self)
    }
    
    var weekDay: Int {
        return components.weekday
    }
    
    var numberOfDaysInMonth: Int {
        return (Calendar.current as NSCalendar).range(of: .day, in: .month, for: self).length
    }
    
    var day: Int {
        return components.day
    }
    
    var month: Int {
        return components.month
    }
    
    var year: Int {
        return components.year
    }
    
    var minute: Int {
        return components.minute
    }
    
    var second: Int {
        return components.second
    }
    
    var hour: Int {
        return components.hour
    }
        
    func isSameDay(_ date: Foundation.Date) -> Bool {
        return !(self.year != date.year || self.month != date.month || self.day != date.day)
    }
    
    //MARK: Private variable and methods.
    
    fileprivate var components: DateComponents {
        let calendarUnit = NSCalendar.Unit(rawValue: UInt.max)
        let components = (Calendar.current as NSCalendar).components(calendarUnit, from: self)
        return components
    }
    
    fileprivate func firstDay(_ followingMonth: Bool) -> Foundation.Date {
        let dateComponent = DateComponents()
        dateComponent.month = followingMonth ? 1: -1
        
        let date = (Calendar.current as NSCalendar).date(byAdding: dateComponent, to: self, options: NSCalendar.Options(rawValue: 0))
        return date!.firstDayOfTheMonth
    }
}
