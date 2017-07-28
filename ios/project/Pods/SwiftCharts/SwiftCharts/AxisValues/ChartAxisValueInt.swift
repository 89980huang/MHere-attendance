//
//  ChartAxisValueInt.swift
//  SwiftCharts
//
//  Created by ischuetz on 04/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartAxisValueInt: ChartAxisValue {

    open let int: Int
    fileprivate let labelSettings: ChartLabelSettings
    
    override open var text: String {
        return "\(self.int)"
    }
    
    public init(_ int: Int, labelSettings: ChartLabelSettings = ChartLabelSettings()) {
        self.int = int
        self.labelSettings = labelSettings
        super.init(scalar: Double(int))
    }
    
    override open var labels:[ChartAxisLabel] {
        let axisLabel = ChartAxisLabel(text: self.text, settings: self.labelSettings)
        return [axisLabel]
    }
    
    override open func copy(_ scalar: Double) -> ChartAxisValueInt {
        return ChartAxisValueInt(self.int, labelSettings: self.labelSettings)
    }
}
