//
//  ChartAxisValueDate.swift
//  swift_charts
//
//  Created by ischuetz on 01/03/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartAxisValueDate: ChartAxisValue {
  
    fileprivate let formatter: DateFormatter
    fileprivate let labelSettings: ChartLabelSettings
    
    open var date: Date {
        return ChartAxisValueDate.dateFromScalar(self.scalar)
    }
    
    public init(date: Date, formatter: DateFormatter, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.formatter = formatter
        self.labelSettings = labelSettings
        super.init(scalar: ChartAxisValueDate.scalarFromDate(date))
    }
    
    override open var labels: [ChartAxisLabel] {
        let axisLabel = ChartAxisLabel(text: self.formatter.string(from: self.date), settings: self.labelSettings)
        axisLabel.hidden = self.hidden
        return [axisLabel]
    }
    
    open class func dateFromScalar(_ scalar: Double) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(scalar))
    }
    
    open class func scalarFromDate(_ date: Date) -> Double {
        return Double(date.timeIntervalSince1970)
    }
}

