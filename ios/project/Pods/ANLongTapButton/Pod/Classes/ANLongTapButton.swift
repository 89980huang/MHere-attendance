//
//  ANLongTapButton.swift
//
//  Created by Sergey Demchenko on 11/5/15.
//  Copyright © 2015 antrix1989. All rights reserved.
//

import UIKit

@IBDesignable
open class ANLongTapButton: UIButton
{
    @IBInspectable open var barWidth: CGFloat = 10
    @IBInspectable open var barColor: UIColor = UIColor.yellow
    @IBInspectable open var barTrackColor: UIColor = UIColor.gray
    @IBInspectable open var bgCircleColor: UIColor = UIColor.blue
    @IBInspectable open var startAngle: CGFloat = -90
    @IBInspectable open var timePeriod: TimeInterval = 3
    
    open var didTimePeriodElapseBlock : (() -> Void) = { () -> Void in }
    
    var timePeriodTimer: Timer?
    var circleLayer: CAShapeLayer?
    
    open override func prepareForInterfaceBuilder()
    {
        let center = self.center()
        let radius = self.radius()
        
        if let context = UIGraphicsGetCurrentContext() {
            drawBackground(context, center: center, radius: radius)
            drawBackgroundCircle(context, center: center, radius: radius)
            drawTrackBar(context, center: center, radius: radius)
            drawProgressBar(context, center: center, radius: radius)
        }
    }
    
    open override func awakeFromNib()
    {
        super.awakeFromNib()
        
        addTarget(self, action: Selector("start:forEvent:"), for: .touchDown)
        addTarget(self, action: Selector("cancel:forEvent:"), for: .touchUpInside)
        addTarget(self, action: Selector("cancel:forEvent:"), for: .touchCancel)
        addTarget(self, action: Selector("cancel:forEvent:"), for: .touchDragExit)
        addTarget(self, action: Selector("cancel:forEvent:"), for: .touchDragOutside)
    }
    
    open override func draw(_ rect: CGRect)
    {
        super.draw(rect)
        
        let center = self.center()
        let radius = self.radius()
        
        if let context = UIGraphicsGetCurrentContext() {
            context.clear(rect)
            drawBackground(context, center: center, radius: radius)
            drawBackgroundCircle(context, center: center, radius: radius)
            drawTrackBar(context, center: center, radius: radius)
        }
    }
    
    // MARK: - Internal
    
    func start(_ sender: AnyObject, forEvent event: UIEvent)
    {
        reset()
        
        timePeriodTimer = Timer.schedule(delay: timePeriod) { [weak self] (timer) -> Void in
            self?.timePeriodTimer?.invalidate()
            self?.timePeriodTimer = nil
            
            self?.didTimePeriodElapseBlock()
        }
        
        let center = self.center()
        var radius = self.radius()
        radius = radius - (barWidth / 2)
        
        circleLayer = CAShapeLayer()
        circleLayer!.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: degreesToRadians(startAngle), endAngle: degreesToRadians(startAngle + 360), clockwise: true).cgPath
        circleLayer!.fillColor = UIColor.clear.cgColor
        circleLayer!.strokeColor = barColor.cgColor
        circleLayer!.lineWidth = barWidth
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = timePeriod
        animation.isRemovedOnCompletion = true
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        circleLayer!.add(animation, forKey: "drawCircleAnimation")
        self.layer.addSublayer(circleLayer!)
    }
    
    func cancel(_ sender: AnyObject, forEvent event: UIEvent)
    {
        reset()
    }
    
    func reset()
    {
        timePeriodTimer?.invalidate()
        timePeriodTimer = nil
        circleLayer?.removeAllAnimations()
        circleLayer?.removeFromSuperlayer()
        circleLayer = nil
    }
    
    func drawBackground(_ context: CGContext, center: CGPoint, radius: CGFloat)
    {
        if let backgroundColor = self.backgroundColor {
            context.setFillColor(backgroundColor.cgColor);
            context.fill(bounds)
        }
    }
    
    func drawBackgroundCircle(_ context: CGContext, center: CGPoint, radius: CGFloat)
    {
        context.setFillColor(bgCircleColor.cgColor)
        context.beginPath()
        addArc(context, center.x, center.y, radius, 0, 360, 0)
        context.closePath()
        context.fillPath()
    }
    
    func drawTrackBar(_ context: CGContext, center: CGPoint, radius: CGFloat)
    {
        if (barWidth > radius) {
            barWidth = radius;
        }
        
        context.setFillColor(barTrackColor.cgColor)
        context.beginPath()
        CGContextAddArc(context, center.x, center.y, radius, degreesToRadians(startAngle), degreesToRadians(startAngle + 360), 0);
        CGContextAddArc(context, center.x, center.y, radius - barWidth, degreesToRadians(startAngle + 360), degreesToRadians(startAngle), 1);
        context.closePath()
        CGContext.fillPath(context)
    }
    
    func drawProgressBar(_ context: CGContext, center: CGPoint, radius: CGFloat)
    {
        if (barWidth > radius) {
            barWidth = radius;
        }
        
        context.setFillColor(barColor.cgColor)
        context.beginPath()
        CGContextAddArc(context, center.x, center.y, radius, degreesToRadians(startAngle), degreesToRadians(startAngle + 90), 0);
        CGContextAddArc(context, center.x, center.y, radius - barWidth, degreesToRadians(startAngle + 90), degreesToRadians(startAngle), 1);
        context.closePath()
        CGContextFillPath(context)
    }
    
    // MARK: - Private
    
    fileprivate func center() -> CGPoint
    {
        return CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
    }
    
    fileprivate func radius() -> CGFloat
    {
        let center = self.center()
        
        return min(center.x, center.y)
    }
    
    fileprivate func degreesToRadians (_ value: CGFloat) -> CGFloat { return value * CGFloat(M_PI) / CGFloat(180.0) }
}
