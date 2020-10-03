//
//  MapView.swift
//  p3mobile
//

import SwiftUI

import SwiftUI
import MapKit
import CoreLocation

struct MapView: UIViewRepresentable {
  
  var annotations: [MKPointAnnotation]
  
  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()
    mapView.delegate = context.coordinator
    return mapView
  }
  
  func updateUIView(_ view: MKMapView, context: Context) {
    if annotations.count != view.annotations.count {
      view.removeAnnotations(view.annotations)
      view.addAnnotations(annotations)
    }
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView
    
    init(_ parent: MapView) {
      self.parent = parent
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
      
    }
  }
}

