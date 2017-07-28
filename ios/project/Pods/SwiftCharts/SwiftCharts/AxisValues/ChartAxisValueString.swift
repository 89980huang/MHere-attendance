//
//  ChartAxisValueString.swift
//  SwiftCharts
//
//  Created by ischuetz on 29/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartAxisValueString: ChartAxisValue {
   
    let string: String
    fileprivate let labelSettings: ChartLabelSettings
    
    public init(_ string: String = "", order: Int, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.string = string
        self.labelSettings = labelSettings
        super.init(scalar: Double(order))
    }
    
    override open var labels: [ChartAxisLabel] {
        let axisLabel = ChartAxisLabel(text: self.string, settings: self.labelSettings)
        return [axisLabel]
    }
}
