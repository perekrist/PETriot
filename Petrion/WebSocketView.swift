//
//  WebSocketView.swift
//  p3mobile
//

import SwiftUI
import MapKit

struct WebSocketView: View {
  @ObservedObject var service = WebsocketService()
  @ObservedObject var netService = NetworkService()
  @State private var showingImagePicker = false
  @State private var inputImage: UIImage?
  @State var annotation: [MKPointAnnotation] = []
  @State var select = 0
  var body: some View {
    VStack {
      if service.response != nil {
        Text(service.response?.question ?? "")
          .font(.title)
          .bold()
          .padding()
        if service.response?.answer != nil {
          Picker(selection: self.$select, label: Text("Picker")){
            ForEach(0..<(service.response?.answer ?? []).count) { i in
              Text(service.response?.answer?[i] ?? "").tag(i)
            }
          }
        }
        if service.response?.type == "file" {
          if inputImage != nil {
            Image(uiImage: inputImage!)
              .resizable()
              .frame(width: 200, height: 200)
              .aspectRatio(contentMode: .fill)
              .padding(.horizontal, 5)
              .padding(.bottom)
          }
          Button(action: {
            self.showingImagePicker = true
          }) {
            Image(systemName: "plus")
              .padding()
          }
        }
        if service.response?.type == "location" {
          MapView(annotations: annotation)
            .frame(width: 400, height: 400)
            .onTapGesture {
              self.annotation.removeAll()
              self.annotation.append(MKPointAnnotation())
              let ann = MKPointAnnotation()
              ann.coordinate = CLLocationCoordinate2D(latitude: 56.29, longitude: 84.56)
              annotation.append(ann)
            }
        }
        Button {
          if self.service.response?.type == "choice" {
            self.service.writeStringInt(text: "[\(select)]")
          }
          self.select = 0
          if self.service.response?.type == "file" {
            loadImage()
          }
          if self.service.response?.type == "location" {
            if annotation.count > 0 {
              self.service.writeLocation(lat: Float(annotation[0].coordinate.latitude), lng: Float(annotation[0].coordinate.longitude))
            }
          }
        } label: {
          Text("Продолжить")
        }.padding()
      } else {
        Text("Нажмите начать, чтобы приступить к заполнению заявления")
          .padding()
          .multilineTextAlignment(.center)
        Button {
          self.service.connect()
        } label: {
          Text("Начать")
        }
      }
    }.sheet(isPresented: $showingImagePicker) {
      ImagePicker(image: self.$inputImage)
    }
  }
  
  func loadImage() {
    let imageName = randomString(length: 8)
    guard let inputImage = inputImage else { return }
    self.service.writeFile(fileName: imageName)
    self.netService.uploadImage(image: inputImage, fileName: imageName, key: self.service.response?.key ?? "") {
      print("upload")
      self.service.writeUploaded()
    }
  }
  
  func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map{ _ in letters.randomElement()! })
  }
}

struct WebSocketView_Previews: PreviewProvider {
  static var previews: some View {
    WebSocketView()
  }
}
