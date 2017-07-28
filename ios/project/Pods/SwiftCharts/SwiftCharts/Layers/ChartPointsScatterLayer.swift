//
//  ChartPointsScatterLayer.swift
//  Examples
//
//  Created by ischuetz on 17/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

class ChartPointsScatterLayer<T: ChartPoint>: ChartPointsLayer<T> {

    let itemSize: CGSize
    let itemFillColor: UIColor
    
    required init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor) {
        self.itemSize = itemSize
        self.itemFillColor = itemFillColor
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay)
    }
    
    override func chartViewDrawing(context: CGContextRef, chart: Chart) {
        for chartPointModel in self.chartPointsModels {
            self.drawChartPointModel(context: context, chartPointModel: chartPointModel)
        }
    }
    
    func drawChartPointModel(context: CGContextRef, chartPointModel: ChartPointLayerModel<T>) {
        fatalError("override")
    }
}

open class ChartPointsScatterTrianglesLayer<T: ChartPoint>: ChartPointsScatterLayer<T> {
    
    required public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay, itemSize: itemSize, itemFillColor: itemFillColor)
    }
    
    override func drawChartPointModel(context: CGContextRef, chartPointModel: ChartPointLayerModel<T>) {
        let w = self.itemSize.width
        let h = self.itemSize.height
        
        let path = CGMutablePath()
        CGPathMoveToPoint(path, nil, chartPointModel.screenLoc.x, chartPointModel.screenLoc.y - h / 2)
        CGPathAddLineToPoint(path, nil, chartPointModel.screenLoc.x + w / 2, chartPointModel.screenLoc.y + h / 2)
        CGPathAddLineToPoint(path, nil, chartPointModel.screenLoc.x - w / 2, chartPointModel.screenLoc.y + h / 2)
        path.closeSubpath()
        
        context.setFillColor(self.itemFillColor.cgColor)
        context.addPath(path)
        CGContextFillPath(context)
    }
}

open class ChartPointsScatterSquaresLayer<T: ChartPoint>: ChartPointsScatterLayer<T> {
    
    required public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay, itemSize: itemSize, itemFillColor: itemFillColor)
    }
    
    override func drawChartPointModel(context: CGContextRef, chartPointModel: ChartPointLayerModel<T>) {
        let w = self.itemSize.width
        let h = self.itemSize.height
        
        context.setFillColor(self.itemFillColor.cgColor)
        context.fill(CGRect(x: chartPointModel.screenLoc.x - w / 2, y: chartPointModel.screenLoc.y - h / 2, width: w, height: h))
    }
}

open class ChartPointsScatterCirclesLayer<T: ChartPoint>: ChartPointsScatterLayer<T> {
    
    required public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor) {
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay, itemSize: itemSize, itemFillColor: itemFillColor)
    }
    
    override func drawChartPointModel(context: CGContextRef, chartPointModel: ChartPointLayerModel<T>) {
        let w = self.itemSize.width
        let h = self.itemSize.height
        
        context.setFillColor(self.itemFillColor.cgColor)
        context.fillEllipse(in: CGRect(x: chartPointModel.screenLoc.x - w / 2, y: chartPointModel.screenLoc.y - h / 2, width: w, height: h))
    }
}

open class ChartPointsScatterCrossesLayer<T: ChartPoint>: ChartPointsScatterLayer<T> {
    
    fileprivate let strokeWidth: CGFloat
    
    required public init(xAxis: ChartAxisLayer, yAxis: ChartAxisLayer, innerFrame: CGRect, chartPoints: [T], displayDelay: Float = 0, itemSize: CGSize, itemFillColor: UIColor, strokeWidth: CGFloat = 2) {
        self.strokeWidth = strokeWidth
        super.init(xAxis: xAxis, yAxis: yAxis, innerFrame: innerFrame, chartPoints: chartPoints, displayDelay: displayDelay, itemSize: itemSize, itemFillColor: itemFillColor)
    }
    
    override func drawChartPointModel(context: CGContextRef, chartPointModel: ChartPointLayerModel<T>) {
        let w = self.itemSize.width
        let h = self.itemSize.height
        
        func drawLine(_ p1X: CGFloat, p1Y: CGFloat, p2X: CGFloat, p2Y: CGFloat) {
            context.setStrokeColor(self.itemFillColor.cgColor)
            context.setLineWidth(self.strokeWidth)
            context.move(to: CGPoint(x: p1X, y: p1Y))
            context.addLine(to: CGPoint(x: p2X, y: p2Y))
            context.strokePath()
        }

        drawLine(chartPointModel.screenLoc.x - w / 2, p1Y: chartPointModel.screenLoc.y - h / 2, p2X: chartPointModel.screenLoc.x + w / 2, p2Y: chartPointModel.screenLoc.y + h / 2)
        drawLine(chartPointModel.screenLoc.x + w / 2, p1Y: chartPointModel.screenLoc.y - h / 2, p2X: chartPointModel.screenLoc.x - w / 2, p2Y: chartPointModel.screenLoc.y + h / 2)
    }
}
