//
//  FolderView.swift
//  Petrion
//

import SwiftUI

struct FolderView: View {
  var service = NetworkService()
  @State var proporsals: [Id] = []
    var body: some View {
      ScrollView(.vertical, showsIndicators: false) {
        VStack {
          ForEach(proporsals.reversed(), id: \.self) { id in
            ProporsalView(id: id.id)
          }
        }.onAppear {
          service.getProporsals { (result) in
            switch result {
            case.success(let proporsals):
              self.proporsals = proporsals.result
            case .failure(_):
              print("error")
            }
            
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
