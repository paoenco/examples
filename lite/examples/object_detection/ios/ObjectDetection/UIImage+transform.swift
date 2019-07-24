//
//  UIImage+transform.swift
//  VinOCR
//
//  Created by Agustinus Nalwan on 9/9/17.
//  Copyright © 2017 carsales. All rights reserved.
//

import Foundation
import UIKit

extension UIImage
{
    enum ResizeMode
    {
        case ScaleToFit
        case CropToFit
        case Stretch
    }
    func resize(targetSize: CGSize) -> UIImage?
    {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    func crop( rect: CGRect) -> UIImage?
    {
        var rect = rect
        rect.origin.x *= self.scale
        rect.origin.y *= self.scale
        rect.size.width *= self.scale
        rect.size.height *= self.scale
        
        if let cgImg = self.cgImage
        {
            guard let imageRef = cgImg.cropping(to: rect) else
            {
                return nil
            }
            return UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        }
        return nil
    }
    func rectToFit(containerRect: CGRect, allowResizeUp: Bool, resizeMode: ResizeMode) -> CGRect
    {
        var sX = self.size.width / containerRect.size.width;
        var sY = self.size.height / containerRect.size.height;
        
        var scale = 1.0
        
        switch (resizeMode)
        {
            case .ScaleToFit:
                scale = Double(sX > sY ? sX : sY)
                break
            case .CropToFit:
                scale = Double(sX < sY ? sX : sY)
                break
            case .Stretch:
                if (!allowResizeUp)
                {
                    if (sX < 1.0)
                    {
                        sX = 1.0;
                    }
                    if (sY < 1.0)
                    {
                        sY = 1.0;
                    }
                }
                let newWidth = self.size.width / sX;
                let newHeight = self.size.height / sY;
                return CGRect(x: (containerRect.size.width - newWidth) / 2 + containerRect.origin.x, y: (containerRect.size.height - newHeight) / 2 + containerRect.origin.y, width: newWidth, height: newHeight)
        }
        
        if (!allowResizeUp)
        {
            if (scale < 1.0)
            {
                scale = 1.0;
            }
        }
        let newWidth = self.size.width / CGFloat(scale)
        let newHeight = self.size.height / CGFloat(scale)
        
        return CGRect(x: (containerRect.size.width - newWidth) / 2 + containerRect.origin.x, y: (containerRect.size.height - newHeight) / 2 + containerRect.origin.y, width: newWidth, height: newHeight)
    }
}
