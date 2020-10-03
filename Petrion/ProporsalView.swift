//
//  ProporsalView.swift
//  Petrion
//

import SwiftUI

enum URLs {
  static let gis2 = "https://2gis.ru/tomsk/search/%D0%9E%D1%82%D0%B4%D0%B5%D0%BB%D0%B5%D0%BD%D0%B8%D1%8F%20%D0%BF%D0%BE%D0%BB%D0%B8%D1%86%D0%B8%D0%B8"
  static let pdf = "http://www.files.rechitsa.by/rovd/rovd_obraz_zayvlenie.pdf"
}

enum Status {
  static let accept = "chevron.down.circle"
  static let wait = "clock"
  static let deny = "exclamationmark.circle"
}

class StatusAsset {
  let rnd = Int.random(in: 0..<3)
  
  var imageName: String {
    switch rnd {
    case 0:
      return Status.accept
    case 1:
      return Status.wait
    case 2:
      return Status.deny
    default:
      return Status.wait
    }
  }
  var color: UIColor {
    switch rnd {
    case 0:
      return .green
    case 1:
      return .orange
    case 2:
      return .red
    default:
      return .orange
    }
  }
  
  var name: String {
    switch rnd {
    case 0:
      return "Принято"
    case 1:
      return "Обрабатывается"
    case 2:
      return "Отклонено"
    default:
      return "В ожидании"
    }
  }
}

struct ProporsalView: View {
  @State var moreInfo = false
  @State var proporsal: Proporsal
  var statusAsset = StatusAsset()
  var body: some View {
    ZStack {
      Color(UIColor.systemTeal)
        .opacity(0.3)
        .edgesIgnoringSafeArea(.all)
      VStack {
        VStack(alignment: .leading) {
          Text(proporsal.description)
            .bold()
            .font(.title)
            .padding()
          
          HStack {
//            Text(proporsal.description)
//              .font(.caption)
//              .padding()
            Spacer()
            Image(systemName: statusAsset.imageName)
              .font(.system(size: 24))
              .foregroundColor(Color(statusAsset.color))
              .padding()
              .shadow(radius: 8)
          }
        }.background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding([.top, .horizontal])
        HStack {
          if moreInfo {
            Text("Статус: \(statusAsset.name)")
              .bold()
              .padding(.horizontal)
          }
          Spacer()
          Button(action: {
            withAnimation {
              self.moreInfo.toggle()
            }
          }) {
            HStack {
              Image(systemName: moreInfo ? "chevron.up" : "chevron.down")
              Text("Подробнее")
            }
            .padding()
            .foregroundColor(.gray)
          }
        }
        if moreInfo {
          VStack(alignment: .leading) {
//            ScrollView(.horizontal, showsIndicators: false) {
//              HStack {
//                ForEach(0..<10) { image in
//                  Rectangle()
//                    .frame(width: 70, height: 70)
//                    .background(Color.orange)
//                    .padding(.horizontal, 5)
//                    .padding(.bottom)
//                }
//              }.padding(.horizontal)
//            }
            Button {
              openInSafari(url: URLs.pdf)
            } label: {
              HStack {
                Text("Посмотреть заявление")
                Image(systemName: "doc.text")
              }
            }.padding([.horizontal, .bottom])
            .foregroundColor(.gray)
            
            Button {
              openInSafari(url: URLs.gis2)
            } label: {
              HStack {
                Text("Отделения полиции")
                Image(systemName: "mappin.and.ellipse")
              }
            }.padding([.horizontal, .bottom])
            .foregroundColor(.gray)
          }
        }
      }
      
    }.cornerRadius(6)
    .padding()
    .shadow(radius: 8)
  }
  
  func openInSafari(url: String) {
    UIApplication.shared.open(URL(string: url)!)
  }
}
