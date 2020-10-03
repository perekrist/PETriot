//
//  CustomTabView.swift
//  Petrion
//

import SwiftUI

struct CustomTabView : View {
  
  @State var selectedTab = "dollarsign.circle"
  @State var edge = UIApplication.shared.windows.first?.safeAreaInsets
  @State var isPresented = true
  
  var body: some View {
    NavigationView {
      ZStack {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
          
          TabView(selection: $selectedTab) {
            
            Home()
              .tag("dollarsign.circle")
            
            Email()
              .tag("envelope.fill")
            
            FolderView()
              .tag("folder")
            
            WebSocketView()
              .tag("plus")
          }
          .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
          .ignoresSafeArea(.all, edges: .bottom)
          HStack(spacing: 0){
            
            ForEach(tabs, id: \.self){image in
              
              TabButton(image: image, selectedTab: $selectedTab)
              
              if image != tabs.last{
                
                Spacer(minLength: 0)
              }
            }
          }
          .padding(.horizontal,25)
          .padding(.vertical,5)
          .background(Color.white)
          .clipShape(Capsule())
          .shadow(color: Color.black.opacity(0.15), radius: 5, x: 5, y: 5)
          .shadow(color: Color.black.opacity(0.15), radius: 5, x: -5, y: -5)
          .padding(.horizontal)
          .padding(.bottom,edge!.bottom == 0 ? 20 : 0)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .background(Color.black.opacity(0.05).ignoresSafeArea(.all, edges: .all))
        .navigationTitle("")
        .navigationBarHidden(true)
        
        if isPresented {
          Alert(isPresented: $isPresented)
        }
      }
    }
  }
}

var tabs = ["dollarsign.circle","envelope.fill","folder","plus"]

struct TabButton : View {
  
  var image : String
  @Binding var selectedTab : String
  
  var body: some View{
    
    Button(action: {selectedTab = image}) {
      
      Image(systemName: image)
        .renderingMode(.template)
        .foregroundColor(selectedTab == image ? Color(UIColor.systemPink) : Color.black.opacity(0.4))
        .padding()
    }
  }
}

struct Email : View {
  
  var body: some View{
    
    ScrollView(.vertical, showsIndicators: false) {
      ForEach(0..<15) { i in
        PetitionView()
      }
    }
  }
}

struct DetailView : View {
  
  var course : Course
  @State var showShareSheet = false
  
  var body: some View{
    
    VStack{
      
      Text(course.name)
        .font(.title2)
        .fontWeight(.bold)
        .padding()
      
      Button {
        
      } label: {
        Text("Задонатить 50 руб")
          .bold()
          .font(.title)
      }.padding()
      Image("hum")
      VStack {
        Text("Задонать еще 540 руб, чтобы повысить уровень!")
          .multilineTextAlignment(.center)
          .font(.headline)
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
      }.padding()
      Spacer()
      Button {
        self.showShareSheet.toggle()
      } label: {
        Text("Нету денежек? Попросите у своих друзей!")
          .font(.body)
      }.padding()

    }
    .navigationTitle(course.name)
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarItems(trailing: Button(action: {}, label: {
      
      Image(systemName: "dollarsign.circle")
        .renderingMode(.template)
        .foregroundColor(.gray)
    }))
    .sheet(isPresented: $showShareSheet) {
      ShareSheet(activityItems: [course.name])
  }
  }
}

struct Alert: View {
  @Binding var isPresented: Bool
  
  var body: some View {
    ZStack {
      Color.black.opacity(0.2).edgesIgnoringSafeArea(.all)
    VStack {
      Text("Если вы сейчас находитесь на месте совершения преступленияправонарушения, то сначала сообщите в полицию по телефону 112 и дождитесь наряда на место, предварительно сохранив все вещественные доказательства в исходном виде.\nЕсли животному необходимо оказать неотложную вет.помощь, вовлеките еще очевидцев, которые смогут остаться на месте происшествия или наоборот сопроводить животное для оказания помощи в вет клинике")
        .font(.body)
        .multilineTextAlignment(.center)
        .padding()
      
      HStack {
        Button {
          if let phoneCallURL = URL(string: "telprompt://\(112)") {

                  let application:UIApplication = UIApplication.shared
                  if (application.canOpenURL(phoneCallURL)) {
                      if #available(iOS 10.0, *) {
                          application.open(phoneCallURL, options: [:], completionHandler: nil)
                      } else {
                           application.openURL(phoneCallURL as URL)
                      }
                  }
              }
        } label: {
          Text("Позвонить в полицию")
        }.padding()
        Spacer()
        Button {
          self.isPresented.toggle()
        } label: {
          Text("OK")
        }.padding()
      }.padding()
    }.frame(width: UIScreen.main.bounds.width - 64)
    .padding()
    .background(Color.white)
    .cornerRadius(12)
    }
  }
}

