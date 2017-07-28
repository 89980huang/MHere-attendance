//
//  ChartAxisValuesGenerator.swift
//  swift_charts
//
//  Created by ischuetz on 12/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

public typealias ChartAxisValueGenerator = (Double) -> ChartAxisValue

// Dynamic axis values generation
public struct ChartAxisValuesGenerator {
    
    public static func generateXAxisValuesWithChartPoints(_ chartPoints: [ChartPoint], minSegmentCount: Double, maxSegmentCount: Double, multiple: Double = 10, axisValueGenerator: ChartAxisValueGenerator, addPaddingSegmentIfEdge: Bool) -> [ChartAxisValue] {
        return self.generateAxisValuesWithChartPoints(chartPoints, minSegmentCount: minSegmentCount, maxSegmentCount: maxSegmentCount, multiple: multiple, axisValueGenerator: axisValueGenerator, addPaddingSegmentIfEdge: addPaddingSegmentIfEdge, axisPicker: {$0.x})
    }
    
    public static func generateYAxisValuesWithChartPoints(_ chartPoints: [ChartPoint], minSegmentCount: Double, maxSegmentCount: Double, multiple: Double = 10, axisValueGenerator: ChartAxisValueGenerator, addPaddingSegmentIfEdge: Bool) -> [ChartAxisValue] {
        return self.generateAxisValuesWithChartPoints(chartPoints, minSegmentCount: minSegmentCount, maxSegmentCount: maxSegmentCount, multiple: multiple, axisValueGenerator: axisValueGenerator, addPaddingSegmentIfEdge: addPaddingSegmentIfEdge, axisPicker: {$0.y})
    }
    
    fileprivate static func generateAxisValuesWithChartPoints(_ chartPoints: [ChartPoint], minSegmentCount: Double, maxSegmentCount: Double, multiple: Double = 10, axisValueGenerator: ChartAxisValueGenerator, addPaddingSegmentIfEdge: Bool, axisPicker: (ChartPoint) -> ChartAxisValue) -> [ChartAxisValue] {
        
        let sortedChartPoints = chartPoints.sorted {(obj1, obj2) in
            return axisPicker(obj1).scalar < axisPicker(obj2).scalar
        }
        
        if let first = sortedChartPoints.first, let last = sortedChartPoints.last {
            return self.generateAxisValuesWithChartPoints(axisPicker(first).scalar, last: axisPicker(last).scalar, minSegmentCount: minSegmentCount, maxSegmentCount: maxSegmentCount, multiple: multiple, axisValueGenerator: axisValueGenerator, addPaddingSegmentIfEdge: addPaddingSegmentIfEdge)
            
        } else {
            print("Trying to generate Y axis without datapoints, returning empty array")
            return []
        }
    }
    
    fileprivate static func generateAxisValuesWithChartPoints(_ first: Double, last: Double, minSegmentCount: Double, maxSegmentCount: Double, multiple: Double, axisValueGenerator:ChartAxisValueGenerator, addPaddingSegmentIfEdge: Bool) -> [ChartAxisValue] {
        
        if last < first {
            fatalError("Invalid range generating axis values")
        } else if last == first {
            return []
        }
        
        var firstValue = first - (first.truncatingRemainder(dividingBy: multiple))
        var lastValue = last + (abs(multiple - last).truncatingRemainder(dividingBy: multiple))
        var segmentSize = multiple
        
        if firstValue == first && addPaddingSegmentIfEdge {
            firstValue = firstValue - segmentSize
        }
        if lastValue == last && addPaddingSegmentIfEdge {
            lastValue = lastValue + segmentSize
        }
        
        let distance = lastValue - firstValue
        var currentMultiple = multiple
        var segmentCount = distance / currentMultiple
        while segmentCount > maxSegmentCount {
            currentMultiple *= 2
            segmentCount = distance / currentMultiple
        }
        segmentCount = ceil(segmentCount)
        while segmentCount < minSegmentCount {
            segmentCount++
        }
        segmentSize = currentMultiple
        
        let offset = firstValue
        return (0...Int(segmentCount)).map {segment in
            let scalar = offset + (Double(segment) * segmentSize)
            return axisValueGenerator(scalar)
        }
    }
    
}
