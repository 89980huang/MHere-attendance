//
//  Chart.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartSettings {
    open var leading: CGFloat = 0
    open var top: CGFloat = 0
    open var trailing: CGFloat = 0
    open var bottom: CGFloat = 0
    open var labelsSpacing: CGFloat = 5
    open var labelsToAxisSpacingX: CGFloat = 5
    open var labelsToAxisSpacingY: CGFloat = 5
    open var spacingBetweenAxesX: CGFloat = 15
    open var spacingBetweenAxesY: CGFloat = 15
    open var axisTitleLabelsToLabelsSpacing: CGFloat = 5
    open var axisStrokeWidth: CGFloat = 1.0
    
    public init() {}
}

open class Chart {
    
    open let view: ChartBaseView

    fileprivate let layers: [ChartLayer]

    convenience public init(frame: CGRect, layers: [ChartLayer]) {
        self.init(view: ChartBaseView(frame: frame), layers: layers)
    }
    
    public init(view: ChartBaseView, layers: [ChartLayer]) {

        self.layers = layers
        
        self.view = view
        self.view.chart = self
        
        for layer in self.layers {
            layer.chartInitialized(chart: self)
        }
        
        self.view.setNeedsDisplay()
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func addSubview(_ view: UIView) {
        self.view.addSubview(view)
    }
    
    open var frame: CGRect {
        return self.view.frame
    }
    
    open var bounds: CGRect {
        return self.view.bounds
    }
    
    open func clearView() {
        self.view.removeFromSuperview()
    }
    
    fileprivate func drawRect(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        for layer in self.layers {
            layer.chartViewDrawing(context: context!, chart: self)
        }
    }
}

open class ChartBaseView: UIView {
    
    weak var chart: Chart?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }
    
    func sharedInit() {
        self.backgroundColor = UIColor.clear
    }
    
    override open func draw(_ rect: CGRect) {
        self.chart?.drawRect(rect)
    }
}
