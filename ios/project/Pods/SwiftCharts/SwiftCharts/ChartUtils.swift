//
//  ChartUtils.swift
//  swift_charts
//
//  Created by ischuetz on 10/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit

open class ChartUtils {

    open class func textSize(_ text: String, font: UIFont) -> CGSize {
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: font]).size()
    }
    
    open class func rotatedTextBounds(_ text: String, font: UIFont, angle: CGFloat) -> CGRect {
        let labelSize = ChartUtils.textSize(text, font: font)
        let radians = angle * CGFloat(M_PI) / CGFloat(180)
        return boundingRectAfterRotatingRect(CGRect(x: 0, y: 0, width: labelSize.width, height: labelSize.height), radians: radians)
    }
    
    // src: http://stackoverflow.com/a/9168238/930450
    open class func boundingRectAfterRotatingRect(_ rect: CGRect, radians: CGFloat) -> CGRect {
        let xfrm = CGAffineTransform(rotationAngle: radians)
        return rect.applying(xfrm)
    }
    
    open class func toDispatchTime(_ secs: Float) -> DispatchTime {
        return DispatchTime.now() + Double(Int64(Double(secs) * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    }
}
