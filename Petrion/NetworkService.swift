//
//  NetworkService.swift
//  p3mobile
//

import Foundation
import SwiftUI
import Alamofire
import SwiftyJSON

class NetworkService: ObservableObject {  
  func uploadImage(image: UIImage?, fileName: String, key: String, completion: @escaping() -> Void) {
    guard let image = image else { return }
    AF.upload(
      multipartFormData: { multipartFormData in
        multipartFormData.append(image.jpegData(compressionQuality: 0.5)!, withName: "upload_data" , fileName: "\(fileName).jpeg", mimeType: "image/jpeg")
      },
      to: "https://p3project.herokuapp.com/api/upload?key=\(key)&filename=\(fileName).jpeg", method: .post)
      .response { response in
        switch response.result {
        case.success(let data):
          completion()
        case.failure(let error):
          fatalError(error.localizedDescription)
        }
      }
  }
}
