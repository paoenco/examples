//
//  CarRecognizer.swift
//  Carzam
//
//  Created by Agustinus Nalwan on 4/10/17.
//  Copyright © 2017 carsales. All rights reserved.
//

import Foundation
import UIKit

class CarSpec
{
    var make: String?
    var model: String?
    var body: String?
    var series: String?
    var badge: String?
    var confScore: Float?
    var badgeConfScore: Float?
    
    init(json: [String: Any])
    {
        guard let classifyOutput = json["classifyOutput"] as? [String: Any],
              let categories = classifyOutput["categories"] as? [[String: Any]] else
        {
            return
        }
        if categories.count > 0
        {
            let firstEntry = categories[0]
            guard let make = firstEntry["make"] as? String,
                  let model = firstEntry["model"] as? String,
                  let body = firstEntry["body"] as? String,
                  let series = firstEntry["series"] as? String,
                  let badge = firstEntry["badge"] as? String,
                  let confScore = firstEntry["makeModelBodySeriesConfScore"] as? Float? else
            {
                return
            }
            self.make = make
            self.model = model
            self.body = body
            self.badge = badge
            self.series = series
            self.confScore = confScore
            if let badgeConfScore = firstEntry["badgeConfScore"] as? Float?
            {
                self.badgeConfScore = badgeConfScore
            } else
            {
                self.badgeConfScore = 0
            }
        }
    }
}

class CarRecognizer
{
    let CarZamUrl = "https://carzam.prod.ai.csnglobal.net/v1/carzam"
//    let CarZamUrl = "http://10.1.57.246:8080/v1/carzam"
    
    private var imageUploader = ImageUploader()

    func recognize(_ image: UIImage, success: @escaping (_ carSpec: CarSpec) -> Void,
                   failed: @escaping () -> Void) -> Bool
    {
        let newRect = image.rectToFit(containerRect:CGRect(origin:CGPoint(x: 0, y: 0), size:CGSize(width:640, height:640)), allowResizeUp: false, resizeMode: .ScaleToFit)
        guard let resizedImage = image.resize(targetSize:CGSize(width: newRect.size.width, height: newRect.size.height)) else
        {
            return false
        }
        
        let parameters = ["showBadge" : "true"]
        
        if (self.imageUploader.upload(resizedImage, url:self.CarZamUrl, imageName:"image", parameters: parameters, success:
        { (jsonResponse) in
            let carSpec = CarSpec(json: jsonResponse)
            success(carSpec)
        }, failed:
        {
            failed()
        }))
        {
            return true
        }
        return false
    }
}
