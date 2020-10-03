//
//  HomeView.swift
//  Petrion
//

import SwiftUI

struct Home: View {
  
  @State var txt = ""
  @State var edge = UIApplication.shared.windows.first?.safeAreaInsets
  
  var body: some View{
    
    VStack{
      
      HStack{
        
        VStack(alignment: .leading, spacing: 10) {
          
          Text("Привет, Олег!")
            .font(.title)
            .fontWeight(.bold)
          
          Text("Давай пожертвуем денежки!")
        }
        .foregroundColor(.black)
        
        Spacer(minLength: 0)
        
        NavigationLink(destination: ProfileView()) {
          
          Image("logo")
            .resizable()
            .renderingMode(.original)
            .frame(width: 60, height: 60)
            .aspectRatio(contentMode: .fill)
            .clipShape(Circle())
        }
      }
      .padding()
      
      ScrollView(.vertical, showsIndicators: false) {
        
        VStack{
          
          HStack(spacing: 15){
            
            Image(systemName: "magnifyingglass")
              .foregroundColor(.gray)
            
            TextField("Найти ", text: $txt)
          }
          .padding(.vertical,12)
          .padding(.horizontal)
          .background(Color.white)
          .clipShape(Capsule())
          
          HStack{
            
            Text("Категории")
              .font(.title2)
              .fontWeight(.bold)
            
            Spacer(minLength: 0)
            
            Button(action: {}) {
              
              Text("Все")
            }
          }
          .foregroundColor(.black)
          .padding(.top,25)
          
          LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2),spacing: 20){
            
            ForEach(courses){course in
              
              NavigationLink(destination: DetailView(course: course)) {
                CourseCardView(course: course)
              }
            }
          }
          .padding(.top)
        }
        .padding()
        .padding(.bottom,edge!.bottom + 70)
      }
    }
  }
}

struct ShareSheet: UIViewControllerRepresentable {
  typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
  
  let activityItems: [Any]
  let applicationActivities: [UIActivity]? = nil
  let excludedActivityTypes: [UIActivity.ActivityType]? = nil
  let callback: Callback? = nil
  
  func makeUIViewController(context: Context) -> UIActivityViewController {
    let controller = UIActivityViewController(
      activityItems: activityItems,
      applicationActivities: applicationActivities)
    controller.excludedActivityTypes = excludedActivityTypes
    controller.completionWithItemsHandler = callback
    return controller
  }
  
  func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    // nothing to do here
  }
}
