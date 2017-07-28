//
//  ChartContextDrawer.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartContextDrawer {
    
    var hidden: Bool = false
    
    final func triggerDraw(context: CGContextRef, chart: Chart) {
        if !hidden {
            self.draw(context: context, chart: chart)
        }
    }
    
    func draw(context: CGContextRef, chart: Chart) {}
}
