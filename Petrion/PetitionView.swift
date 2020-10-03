//
//  PetitionView.swift
//  p3mobile
//

import SwiftUI

struct PetitionView: View {
  @State var count = Int.random(in: 2..<20)
  var body: some View {
    ZStack {
      Color(UIColor.systemPink)
        .opacity(0.3)
        .edgesIgnoringSafeArea(.all)
      VStack {
        VStack(alignment: .leading) {
          Text("Very Long Petition Title")
            .bold()
            .font(.title)
            .padding()
          
          Text("Very Long Petition description")
            .font(.caption)
            .padding()
        }.background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding([.top, .horizontal])
        
        HStack {
          HStack {
            Text("Уже присоеденились: ")
              .font(.subheadline)
            Text("\(count)")
              .bold()
              .font(.subheadline)
          }
          Spacer()
          Button(action: {
            self.count += 1
          }) {
            Image(systemName: "plus")
              .padding(8)
              .foregroundColor(.white)
          }.background(Color.gray)
          .cornerRadius(12)
        }.padding()
      }
    }.cornerRadius(6)
    .padding()
    .shadow(radius: 8)
  }
}

struct PetitionView_Previews: PreviewProvider {
  static var previews: some View {
    PetitionView()
  }
}
