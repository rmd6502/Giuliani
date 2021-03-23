//
//  Study.swift
//  jsontables
//
//  Created by Robert Diamond on 3/22/21.
//

import Foundation

struct Study : Decodable {
  var studyNum : Int
  var _id : String
  var difficulty : Int
  var studyPath : String
}
