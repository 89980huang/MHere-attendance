//
//  ChartAxisValueFloat.swift
//  swift_charts
//
//  Created by ischuetz on 15/03/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

//@availability(*, deprecated=0.2.5, message="use ChartAxisValueDouble instead")
/**
    DEPRECATED use ChartAxisValueDouble instead
    Above annotation causes warning inside this file and it was not possible to supress (tried http://stackoverflow.com/a/6921972/930450 etc.)
*/
open class ChartAxisValueFloat: ChartAxisValue {
    
    open let formatter: NumberFormatter
    let labelSettings: ChartLabelSettings

    open var float: CGFloat {
        return CGFloat(self.scalar)
    }
  
    override open var text: String {
        return self.formatter.string(from: self.float)!
    }
    
    public init(_ float: CGFloat, formatter: NumberFormatter = ChartAxisValueFloat.defaultFormatter, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.formatter = formatter
        self.labelSettings = labelSettings
        super.init(scalar: Double(float))
    }
   
    override open var labels: [ChartAxisLabel] {
        let axisLabel = ChartAxisLabel(text: self.text, settings: self.labelSettings)
        return [axisLabel]
    }
    
    
    override open func copy(_ scalar: Double) -> ChartAxisValueFloat {
        return ChartAxisValueFloat(CGFloat(scalar), formatter: self.formatter, labelSettings: self.labelSettings)
    }
    
    static var defaultFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
