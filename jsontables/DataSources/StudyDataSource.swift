//
//  StudyDataSource.swift
//  jsontables
//
//  Created by Robert Diamond on 3/22/21.
//

import Foundation

class StudyDataSource {
  lazy var fetchQueue = OperationQueue()
  lazy var fetchSession = URLSession(configuration: .default, delegate: nil, delegateQueue: fetchQueue)
  let DEFAULT_DIFFICULTY = 1
  let DEFAULT_COUNT=5
  var endpoint = "http://rmd-linux.local:5000"
  var dataTask : URLSessionDataTask?

  func fetchStudies(difficulty : Int?, count : Int?, completion : @escaping (_ data : [Study]?, _ error : Error?) -> Void) {
    dataTask?.cancel()
    guard let fetchURL = URL(string: "/get-randomized-studies-by-difficulty?difficulty=\(difficulty ?? DEFAULT_DIFFICULTY)&limit=\(count ?? DEFAULT_COUNT)", relativeTo: URL(string: endpoint)) else { return }
    dataTask = fetchSession.dataTask(with: fetchURL) { [weak self] data, response, error in
      guard let self = self else { return }
      self.handleDataTask(data, response: response, error: error, completion: completion)
    }
    dataTask?.resume()
  }

  func fetchStudy(id : String, completion : @escaping (_ data : [Study]?, _ error : Error?) -> Void) {
    guard let fetchURL = URL(string: "/get-studies-by-id/\(id)", relativeTo: URL(string: endpoint)) else { return }
    dataTask = fetchSession.dataTask(with: fetchURL) { [weak self] data, response, error in
      guard let self = self else { return }
      self.handleDataTask(data, response: response, error: error, completion: completion)
    }
    dataTask?.resume()
  }

  func handleDataTask(_ data : Data?, response : URLResponse?, error : Error?, completion : @escaping (_ data : [Study]?, _ error : Error?) -> Void) {
    defer {
      self.dataTask = nil
    }
    if let error = error {
      completion([], error)
    } else if let data = data, let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) {
      if let responseData = try? JSONDecoder().decode([Study].self, from: data) {
        completion(responseData, nil)
      } else {
        completion([], NSError(domain: "Invalid response", code: -1, userInfo: [
          NSLocalizedDescriptionKey : "Response failed to decode: invalid JSON"
        ]))
      }
    } else {
      var statusCode = -1
      if let response = response as? HTTPURLResponse {
        statusCode = response.statusCode
      }
      completion([], NSError(domain: "Server Issue", code: statusCode, userInfo: [
        NSLocalizedDescriptionKey : "Server issue"
      ]))
    }
  }
}
