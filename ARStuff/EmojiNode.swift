//
//  EmojiNode.swift
//  ARStuff
//
//  Created by Jon Lu on 12/29/19.
//  Copyright © 2019 Jon Lu. All rights reserved.
//

import SceneKit

class EmojiNode: SCNNode {
  
  var options: [String]
  var index = 0
  
  init(with options: [String], width: CGFloat = 0.06, height: CGFloat = 0.02) {
    self.options = options
    
    super.init()
    
    let plane = SCNPlane(width: width, height: height)
    plane.firstMaterial?.diffuse.contents = UIImage(named: options.first ?? "")
    plane.firstMaterial?.isDoubleSided = true
    
    geometry = plane
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Custom functions

extension EmojiNode {
  
  func updatePosition(for vectors: [vector_float3]) {
    let newPos = vectors.reduce(vector_float3(), +) / Float(vectors.count)
    position = SCNVector3(newPos)
  }
  
  func next() {
    index = (index + 1) % options.count
    
    if let plane = geometry as? SCNPlane {
        plane.firstMaterial?.diffuse.contents = UIImage(named: options[index])
      plane.firstMaterial?.isDoubleSided = true
    }
  }
}

