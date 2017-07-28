//
//  ChartAxisValueDouble.swift
//  SwiftCharts
//
//  Created by ischuetz on 30/08/15.
//  Copyright © 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartAxisValueDouble: ChartAxisValue {
    
    open let formatter: NumberFormatter
    let labelSettings: ChartLabelSettings
    
    override open var text: String {
        return self.formatter.string(from: self.scalar)!
    }

    public convenience init(_ int: Int, formatter: NumberFormatter = ChartAxisValueDouble.defaultFormatter, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.init(Double(int), formatter: formatter, labelSettings: labelSettings)
    }
    
    public init(_ double: Double, formatter: NumberFormatter = ChartAxisValueDouble.defaultFormatter, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.formatter = formatter
        self.labelSettings = labelSettings
        super.init(scalar: double)
    }
    
    override open var labels: [ChartAxisLabel] {
        let axisLabel = ChartAxisLabel(text: self.text, settings: self.labelSettings)
        return [axisLabel]
    }
    
    
    override open func copy(_ scalar: Double) -> ChartAxisValueDouble {
        return ChartAxisValueDouble(scalar, formatter: self.formatter, labelSettings: self.labelSettings)
    }
    
    static var defaultFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}
