//
//  ChartAxisXHighLayerDefault.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

class ChartAxisXHighLayerDefault: ChartAxisXLayerDefault {
    
    override var low: Bool {return false}
    
    override var lineP1: CGPoint {
        return CGPoint(x: self.p1.x, y: self.p1.y + self.lineOffset)
    }
    
    override var lineP2: CGPoint {
        return CGPoint(x: self.p2.x, y: self.p2.y + self.lineOffset)
    }
    
    fileprivate lazy var labelsOffset: CGFloat = {
        return self.axisTitleLabelsHeight + self.settings.axisTitleLabelsToLabelsSpacing
    }()
    
    fileprivate lazy var lineOffset: CGFloat = {
        return self.labelsOffset + (self.settings.axisStrokeWidth / 2) + self.settings.labelsToAxisSpacingX + self.labelsTotalHeight
    }()
    
    override func chartViewDrawing(context: CGContextRef, chart: Chart) {
        super.chartViewDrawing(context: context, chart: chart)
    }
    
    override func initDrawers() {
        self.axisTitleLabelDrawers = self.generateAxisTitleLabelsDrawers(offset: 0)
        self.labelDrawers = self.generateLabelDrawers(offset: self.labelsOffset)
        self.lineDrawer = self.generateLineDrawer(offset: self.lineOffset)
    }
}
