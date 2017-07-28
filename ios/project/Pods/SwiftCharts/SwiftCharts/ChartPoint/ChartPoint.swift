//
//  ChartPoint.swift
//  swift_charts
//
//  Created by ischuetz on 01/03/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartPoint: Equatable {
    
    open let x: ChartAxisValue
    open let y: ChartAxisValue
    
    required public init(x: ChartAxisValue, y: ChartAxisValue) {
        self.x = x
        self.y = y
    }
    
    open var text: String {
        return "\(self.x.text), \(self.y.text)"
    }
}

public func ==(lhs: ChartPoint, rhs: ChartPoint) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}
