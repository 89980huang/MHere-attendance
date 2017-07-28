//
//  ChartAxisValueFloatScreenLoc.swift
//  SwiftCharts
//
//  Created by ischuetz on 30/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

@available(*, deprecated: 0.2.5, message: "use ChartAxisValueDoubleScreenLoc instead")
open class ChartAxisValueFloatScreenLoc: ChartAxisValueFloat {
    
    fileprivate let actualFloat: CGFloat
    
    var screenLocFloat: CGFloat {
        return CGFloat(self.scalar)
    }
    
    override open var text: String {
        return self.formatter.string(from: self.actualFloat)!
    }

    // screenLocFloat: model value which will be used to calculate screen position
    // actualFloat: scalar which this axis value really represents
    public init(screenLocFloat: CGFloat, actualFloat: CGFloat, formatter: NumberFormatter = ChartAxisValueFloat.defaultFormatter, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.actualFloat = actualFloat
        super.init(screenLocFloat, formatter: formatter, labelSettings: labelSettings)
    }
    
    override open var labels: [ChartAxisLabel] {
        let axisLabel = ChartAxisLabel(text: self.text, settings: self.labelSettings)
        return [axisLabel]
    }
}
