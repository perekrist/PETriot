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
  
  func getProporsals(completion: @escaping (Swift.Result<ProporsalResponse, Error>) -> Void) {
    let headers: HTTPHeaders = ["Authorization": "0"]
    AF.request("https://p3project.herokuapp.com/api/proposal", method: .get, headers: headers).responseData { response in
      switch response.result {
      case.success(let data):
        let decoder = JSONDecoder()
        do {
          let decodedData = try decoder.decode(ProporsalResponse.self, from: data)
          completion(Swift.Result.success(decodedData))
        } catch (let error) {
          completion(Swift.Result.failure(error))
          return
        }
      case.failure(let error):
        fatalError(error.localizedDescription)
      }
    }
  }
  
  func getPetitions(completion: @escaping (Swift.Result<PetitionResponse, Error>) -> Void) {
    let headers: HTTPHeaders = ["Authorization": "0"]
    AF.request("https://p3project.herokuapp.com/api/petition", method: .get, headers: headers).responseData { response in
      switch response.result {
      case.success(let data):
        let decoder = JSONDecoder()
        do {
          let decodedData = try decoder.decode(PetitionResponse.self, from: data)
          completion(Swift.Result.success(decodedData))
        } catch (let error) {
          completion(Swift.Result.failure(error))
          return
        }
      case.failure(let error):
        fatalError(error.localizedDescription)
      }
    }
  }
}
struct PetitionResponse: Decodable {
  let result: [Int]
}

struct ProporsalResponse: Decodable {
  let result: [Id]
}

struct Id: Decodable, Hashable {
  let id: Int
}
