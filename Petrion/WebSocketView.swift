//
//  WebSocketView.swift
//  p3mobile
//

import SwiftUI
import MapKit

struct WebSocketView: View {
  @State var imageName = randomString(length: 8)
  @ObservedObject var service = WebsocketService()
  @ObservedObject var netService = NetworkService()
  @State private var showingImagePicker = false
  @State private var inputImage: UIImage?
  @State var annotation: [MKPointAnnotation] = []
  @State var select = ""
  var body: some View {
    VStack {
      if service.response != nil {
        Text(service.response?.question ?? "")
          .font(.title)
          .bold()
          .multilineTextAlignment(.center)
          .padding()
        if service.response?.answers != nil {
          Picker(selection: self.$select, label: Text("Picker")){
            ForEach(service.response?.answers ?? [], id: \.self) { i in
              Text(i).tag(i)
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
              ann.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(Float(56.29)), longitude: CLLocationDegrees(Float(84.56)))
              annotation.append(ann)
              print(annotation.first!.coordinate)
            }
        }
        Button {
          if self.service.response?.type == "choice" {
            var id = 0
            for i in 0..<(self.service.response?.answers?.count ?? 0) {
              if self.service.response?.answers?[i] == select {
                id = i
              }
            }
            self.service.writeStringInt(text: "[\(id)]")
          }
          self.select = ""
          if self.service.response?.type == "file" {
            loadImage()
          }
          if self.service.response?.type == "location" {
            if annotation.count > 0 {
              print(annotation[0].coordinate.latitude, Float(annotation[0].coordinate.longitude))
              self.service.writeLocation(lat: Float(annotation[0].coordinate.latitude), lng: Float(annotation[0].coordinate.longitude))
            }
          }
        } label: {
          Text("Продолжить")
        }.padding()
      } else {
        Text("Нажмите начать, чтобы приступить к заполнению заявления")
          .font(.title)
          .bold()
          .multilineTextAlignment(.center)
          .padding()
        Button {
          self.service.connect()
        } label: {
          Text("Начать")
        }
      }
    }
    .onAppear {
      self.service.writeFile(fileName: imageName)
    }
    .sheet(isPresented: $showingImagePicker) {
      ImagePicker(image: self.$inputImage)
    }
  }
  
  func loadImage() {
    guard let inputImage = inputImage else { return }
    self.netService.uploadImage(image: inputImage, fileName: imageName, key: self.service.response?.key ?? "815D0FD8D157") {
      print("upload")
      self.service.writeUploaded()
      
    }
  }
}

func randomString(length: Int) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0..<length).map{ _ in letters.randomElement()! })
}


struct WebSocketView_Previews: PreviewProvider {
  static var previews: some View {
    WebSocketView()
  }
}
