//
//  ImageUploader.swift
//  Carzam
//
//  Created by Agustinus Nalwan on 4/10/17.
//  Copyright © 2017 carsales. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class ImageUploader
{
    func upload(_ image: UIImage, url: String, imageName: String, parameters: [String:String]?, success: @escaping (_ response: [String: Any]) -> Void, failed: @escaping () -> Void) -> Bool
    {
        let data = image.jpegData(compressionQuality: 0.9)!
        Alamofire.upload(
            multipartFormData: { multipartFormData in

                multipartFormData.append(data,
                                         withName: "image",
                                         fileName: "image.jpg",
                                         mimeType: "image/jpeg")
                if let parameters = parameters
                {
                    for (key, value) in parameters
                    {
                        multipartFormData.append(value.data(using:. utf8)!, withName: key)
                    }
                }
                                },
            to: url,
            headers: ["API-Key": "xxx"],
            encodingCompletion: { encodingResult in
                switch encodingResult
                {
                case .success(let upload, _, _):
                    upload.uploadProgress { progress in
                    }
                    upload.validate()
                    upload.responseJSON { response in
                        guard response.result.isSuccess else {
                            failed()
                            return
                        }
                        
                        // 2.
                        guard let responseJSON = response.result.value as? [String: Any] else
                        {
                            failed()
                            return
                        }
                        success(responseJSON)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                    failed()
                }
            }
        )
        return true
    }
}
