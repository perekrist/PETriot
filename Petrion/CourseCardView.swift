//
//  CourseCardView.swift
//  Petrion
//

import SwiftUI

struct CourseCardView: View {
  @State var progressValue: Float = Float(Double.random(in: 0..<0.5))
  var course : Course
  
  var body: some View {
    
    VStack{
      
      VStack{
        
        Image(course.asset)
          .resizable()
          .renderingMode(.original)
          .aspectRatio(contentMode: .fit)
          .padding(.top,10)
          .padding(.leading,10)
          .frame(width: 100, height: 100)
        
        HStack{
          
          VStack(alignment: .leading, spacing: 12) {
            
            Text(course.name)
              .font(.title3)
              .lineLimit(0)
              .multilineTextAlignment(.center)
            
            Text("\(course.cost) руб")
            ProgressBar(value: $progressValue)
              .frame(height: 20)
          }
          .foregroundColor(.black)
          
          Spacer(minLength: 0)
        }
        .padding()
      }
      .background(Color.white)
      .cornerRadius(15)
      
      Spacer(minLength: 0)
    }.frame(width: 180, height: 250)
  }
}

struct ProgressBar: View {
    @Binding var value: Float
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))
                
                Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                  .foregroundColor(Color(UIColor.systemPink))
                    .animation(.linear)
            }.cornerRadius(45.0)
        }
    }
}
