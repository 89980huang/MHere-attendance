//
//  Utility.swift
//  Attendance Tracker
//
//  Created by Yifeng on 10/25/15.
//  Copyright © 2015 the Pioneers. All rights reserved.
//

import UIKit
import DBAlertController
import ActionSheetPicker_3_0
import PKHUD

// format time and date
extension Foundation.Date {
    func dateFromString(_ date: String, format: String) -> Foundation.Date {
        
        let formatter = DateFormatter()
        let locale = Locale(localeIdentifier: "en_US_POSIX")
        
        formatter.locale = locale
        formatter.dateFormat = format
        
        return formatter.date(from: date)!
    }
    
    func stringFromDate(_ date: Foundation.Date, format: String? = "MMM d, yyyy H:mm a") -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: date)
        
    }
}

// make NSDate comparable
public func ==(lhs: Foundation.Date, rhs: Foundation.Date) -> Bool {
    return lhs === rhs || lhs.compare(rhs) == .orderedSame
}

public func <(lhs: Foundation.Date, rhs: Foundation.Date) -> Bool {
    return lhs.compare(rhs) == .orderedAscending
}

extension Foundation.Date: Comparable { }

extension String {
    func formatDateStringForServer(fromFormat format: String) -> String {

        let date = Foundation.Date().dateFromString(self, format: format)
        
        return Foundation.Date().stringFromDate(date, format: Config.dateFormatInServer)
    }
    
    func formatDateStringFromString(fromFormat: String? = Config.dateFormatInServer, toFormat: String) -> String {
        
        let date = Foundation.Date().dateFromString(self, format: fromFormat!)
        
        return Foundation.Date().stringFromDate(date, format: toFormat)
    }
}

class Utils {
    
    /// Display an alert view
    static func alert(_ title: String, message: String,
        okAction: String? = "OK",
        cancelAction: String? = nil,
        deleteAction: String? = nil,
        okCallback: ((_ action: UIAlertAction!) -> Void)? = nil,
        cancelCallback: ((_ action: UIAlertAction!) -> Void)? = nil,
        deleteCallback: ((_ action: UIAlertAction!) -> Void)? = nil ) {
        
        let alertController = DBAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        if let okAction = okAction {
            alertController.addAction(UIAlertAction(title: okAction, style: .default, handler: okCallback))
        }
            
        if let cancelAction = cancelAction {
            alertController.addAction(UIAlertAction(title: cancelAction, style: .cancel, handler: cancelCallback))
        }
        
        if let deleteAction = deleteAction {
            alertController.addAction(UIAlertAction(title: deleteAction, style: .destructive, handler: deleteCallback))
        }
        
        alertController.show()
    }
//    
//    static func textHUD(text: String) {
//        PKHUD.sharedHUD.contentView = PKHUDTextView(text: text)
//    }
//    
//    static func hideHUD(duration: Double? = nil) {
//        if let duration = duration {
//            PKHUD.sharedHUD.hide(afterDelay: duration)
//        } else {
//            PKHUD.sharedHUD.hide()
//        }
//    }
//    
//    static func showHUD() {
//        PKHUD.sharedHUD.show()
//    }
    
    static func beginHUD(withText text:String? = nil) {
        if let text = text {
            
            PKHUD.sharedHUD.contentView = PKHUDTextView(text: text)
            PKHUD.sharedHUD.show()
        } else {
            
            PKHUD.sharedHUD.contentView = PKHUDProgressView()
            PKHUD.sharedHUD.show()
        }
    }
    
    static func endHUD(_ isSuccess: Bool? = true) {
        if let isSuccess = isSuccess {
            switch isSuccess {
            case true:
                PKHUD.sharedHUD.contentView = PKHUDSuccessView()
                PKHUD.sharedHUD.hide(afterDelay: 1.0)
            case false:
                PKHUD.sharedHUD.contentView = PKHUDErrorView()
                PKHUD.sharedHUD.hide(afterDelay: 1.0)
            }
        }
    }
    
    static func log(_ title:String, printBody: () -> Void ) {
        
        if Config.debug == true {
            
            print("\n\n -------", Foundation.Date(), "---------\n", "======= \(title) ======\n")
            
            printBody()
            
            print("------ *** ------\n\n")
            
            
        }
    }
}

// A Regex operator
infix operator =~ {}

func =~(string:String, regex:String) -> Bool {

    return string.range(of: regex, options: .regularExpression) != nil
}


extension UIImage {
    //  RBResizer.swift Created by Hampton Catlin on 6/20/14.
    //  Copyright (c) 2014 rarebit. All rights reserved.
    func RBSquareImageTo(_ image: UIImage, size: CGSize) -> UIImage {
        
        Utils.alert("Test Crop Image", message: "Crop", okAction: "Good")
        
        return RBResizeImage(RBSquareImage(image), targetSize: size)
    }
    
    func RBSquareImage(_ image: UIImage) -> UIImage {
        let originalWidth  = image.size.width
        let originalHeight = image.size.height
        
        let cropSquare = CGRect(x: (originalHeight - originalWidth)/2, y: 0.0, width: originalWidth, height: originalWidth)
        let imageRef = image.cgImage.cropping(to: cropSquare);
        
        return UIImage(cgImage: imageRef!, scale: UIScreen.main.scale, orientation: image.imageOrientation)
    }
    
    func RBResizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

}

class Env {
    
    static var iPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}

extension Array {
    
    public func mapWithIndex<T> (_ f: (Int, Element) -> T) -> [T] {
        return zip((self.indices), self).map(f)
    }
}
