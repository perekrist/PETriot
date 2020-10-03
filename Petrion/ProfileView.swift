//
//  ProfileView.swift
//  Petrion
//

import SwiftUI

struct ProfileView: View {
  var body: some View {
    VStack {
      Text("Ваш уровень - хомяк! Ведите более активную деятельность и повышайте свой уровень!")
        .bold()
        .font(.title)
        .padding()
        .multilineTextAlignment(.center)
      Image("hum")
        .resizable()
        .frame(width: 160, height: 160)
      HStack {
        Image("hum")
          .resizable()
          .frame(width: 60, height: 60)
        Image("turtle")
          .resizable()
          .frame(width: 65, height: 65)
        Image("cat")
          .resizable()
          .frame(width: 68, height: 68)
        Image("dog")
          .resizable()
          .frame(width: 73, height: 73)
        Image("horse")
          .resizable()
          .frame(width: 80, height: 80)
      }
    }
  }
}

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    ProfileView()
  }
}
