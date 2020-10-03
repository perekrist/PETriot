//
//  WebsocketService.swift
//  p3mobile
//

import UIKit
import SwiftUI
import Starscream
import SwiftyJSON

class WebsocketService: WebSocketDelegate, ObservableObject {
  var socket: WebSocket!
  var isConnected = false
  let server = WebSocketServer()
  @Published var response: Response?
  
  func connect() {
    var request = URLRequest(url: URL(string: "wss://p3project.herokuapp.com/ws")!)
    request.timeoutInterval = 60
    socket = WebSocket(request: request)
    socket.delegate = self
    socket.connect()
  }
  
  func didReceive(event: WebSocketEvent, client: WebSocket) {
    switch event {
    case .connected(let headers):
      isConnected = true
      print("websocket is connected: \(headers)")
    case .disconnected(let reason, let code):
      isConnected = false
      print("websocket is disconnected: \(reason) with code: \(code)")
    case .text(let string):
      print("Received text: \(string)")
      decodeJSON(text: string)
    case .binary(let data):
      print("Received data: \(data.count)")
    case .ping(let ping):
      print("ping \(String(describing: ping))")
    case .pong(let pong):
      print("pong \(String(describing: pong))")
    case .viabilityChanged(_):
      break
    case .reconnectSuggested(_):
      break
    case .cancelled:
      isConnected = false
    case .error(let error):
      isConnected = false
      handleError(error)
    }
  }
  
  func handleError(_ error: Error?) {
    if let e = error as? WSError {
      print("websocket encountered an error: \(e.message)")
    } else if let e = error {
      print("websocket encountered an error: \(e.localizedDescription)")
    } else {
      print("websocket encountered an error")
    }
  }
  
  func disconnect() {
    if isConnected {
      print("Disconnect")
      socket.disconnect()
    } else {
      print("Connect")
      socket.connect()
    }
  }
  
  func write(text: String) {
    socket.write(string: text)
  }
  
  func decodeJSON(text: String) {
    let jsonData = text.data(using: .utf8)!
    let response: Response = try! JSONDecoder().decode(Response.self, from: jsonData)
    self.response = response
    if response.cmd == "debug" {
      self.response = nil
    }
  }
  
  func writeLocation(lat: Float, lng: Float) {
    guard let response = response else { return }
    guard let id = response.id else { return }
    write(text: "{\"cmd\": \"answer\", \"id\": \(id), \"answer\": {\"latitude\": \(lat), \"longitude\": \(lng)}}")
  }
  
  func writeStringInt(text: String) {
    guard let response = response else { return }
    guard let id = response.id else { return }
    write(text: "{\"cmd\": \"answer\", \"answer\": \(text), \"id\": \(id)}")
  }
  
  func writeFile(fileName: String) {
    guard let response = response else { return }
    guard let id = response.id else { return }
    write(text: "{\"cmd\": \"answer\", \"filename\": \"\(fileName).jpeg\", \"id\": \(id)}")
  }
  
  func writeUploaded() {
    guard let response = response else { return }
    guard let id = response.id else { return }
    write(text: "{\"cmd\": \"uploaded\", \"id\": \(id)}")
  }
}

struct Response: Decodable {
  let question: String?
  var id: Int?
  let type: String?
  let answer: [String]?
  let cmd: String
  let key: String?
  // debug
  let explain: String?
  let e: String?
}
