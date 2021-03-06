//
//  ChartPointsBubbleLayer.swift
//  Examples
//
//  Created by ischuetz on 16/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartPointsBubbleLayer<T: ChartPointBubble>: ChartPointsLayer<T> {
    
    fileprivate let diameterFactor: Double
    
    public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0, maxBubbleDiameter: Double = 30, minBubbleDiameter: Double = 2) {
        
        let (minDiameterScalar, maxDiameterScalar): (Double, Double) = chartPoints.reduce((min: 0, max: 0)) {tuple, chartPoint in
            (min: min(tuple.min, chartPoint.diameterScalar), max: max(tuple.max, chartPoint.diameterScalar))
        }
        
        self.diameterFactor = (maxBubbleDiameter - minBubbleDiameter) / (maxDiameterScalar - minDiameterScalar)

        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay)
    }
    
    override open func chartViewDrawing(context: CGContextRef, chart: Chart) {

        for chartPointModel in self.chartPointsModels {

            context.setLineWidth(1.0)
            context.setStrokeColor(chartPointModel.chartPoint.borderColor.cgColor)
            context.setFillColor(chartPointModel.chartPoint.bgColor.cgColor)
            
            let diameter = CGFloat(chartPointModel.chartPoint.diameterScalar * diameterFactor)
            let circleRect = (CGRect(x: chartPointModel.screenLoc.x - diameter / 2, y: chartPointModel.screenLoc.y - diameter / 2, width: diameter, height: diameter))
            
            context.fillEllipse(in: circleRect)
            context.strokeEllipse(in: circleRect)
        }
    }
}
