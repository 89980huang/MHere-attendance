//
//  ChartDrawerFunctions.swift
//  Examples
//
//  Created by ischuetz on 21/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

func ChartDrawLine(context: CGContextRef, p1: CGPoint, p2: CGPoint, width: CGFloat, color: UIColor) {
    context.setStrokeColor(color.cgColor)
    context.setLineWidth(width)
    context.move(to: CGPoint(x: p1.x, y: p1.y))
    context.addLine(to: CGPoint(x: p2.x, y: p2.y))
    context.strokePath()
}

func ChartDrawDottedLine(context: CGContextRef, p1: CGPoint, p2: CGPoint, width: CGFloat, color: UIColor, dotWidth: CGFloat, dotSpacing: CGFloat) {
    context.setStrokeColor(color.cgColor)
    context.setLineWidth(width)
    CGContextSetLineDash(context, 0, [dotWidth, dotSpacing], 2)
    context.move(to: CGPoint(x: p1.x, y: p1.y))
    context.addLine(to: CGPoint(x: p2.x, y: p2.y))
    context.strokePath()
    CGContextSetLineDash(context, 0, nil, 0)
}
