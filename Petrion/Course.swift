//
//  Course.swift
//  Petrion
//

import Foundation

struct Course : Identifiable {
  
  var id = UUID().uuidString
  var name : String
  var cost : Int
  var asset : String
}

var courses = [
  
  Course(name: "На обследование", cost: 2000,asset: "medical-report"),
  Course(name: "На собачий корм", cost: 2100,asset: "pet-food"),
  Course(name: "На лекарства", cost: 3000,asset: "pet-medicine"),
  Course(name: "На средства гигиены", cost: 2400,asset: "pet-soap"),
  Course(name: "На обследование", cost: 1000,asset: "stethoscope"),
  Course(name: "На операцию", cost: 1900,asset: "syringe")
]
