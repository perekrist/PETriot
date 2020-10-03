//
//  FolderView.swift
//  Petrion
//

import SwiftUI

struct FolderView: View {
  @State var proporsals: [Proporsal] = [Proporsal(id: 0, latitude: 0, longitude: 0, description: "Убийство кота", tags: [],                                               attachments: []),
                                        Proporsal(id: 1, latitude: 0, longitude: 0, description: "Отравление собаки", tags: [], attachments: []),
                                        Proporsal(id: 2, latitude: 0, longitude: 0, description: "Издевательство над белкой", tags: [], attachments: []),
                                        Proporsal(id: 3, latitude: 0, longitude: 0, description: "Узбиение скота", tags: [], attachments: []),
                                        Proporsal(id: 4, latitude: 0, longitude: 0, description: "Отравлнеие кота", tags: [], attachments: [])]
    var body: some View {
      ScrollView(.vertical, showsIndicators: false) {
        VStack {
          ForEach(proporsals, id: \.self) { proporsal in
            ProporsalView(proporsal: proporsal)
          }
        }
      }
    }
}

struct Proporsal: Hashable {
  let id: Int
  let latitude: Float
  let longitude: Float
  let description: String
  let tags: [Int]
  let attachments: [Int?]
}

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        FolderView()
    }
}
