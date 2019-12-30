//
//  ViewController.swift
//  ARStuff
//
//  Created by Jon Lu on 12/29/19.
//  Copyright © 2019 Jon Lu. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    let options = ["ww_logo_1", "ww_logo_2", "ww_logo_3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        
        guard ARFaceTrackingConfiguration.isSupported else { fatalError() }
        sceneView.delegate = self
        
        setupViews()
        setupConstraints()
    }

    let sceneView = ARSCNView()

    private func setupViews() {
        view.addSubview(sceneView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToSwitch(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraints() {
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    private func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
      // 1
      let child = node.childNode(withName: "nose", recursively: false) as? EmojiNode

      // 2
      let vertices = [anchor.geometry.vertices[20]]
      
      // 3
      child?.updatePosition(for: vertices)
    }
    
    @objc private func tapToSwitch(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        let results = sceneView.hitTest(location, options: nil)
        if let result = results.first,
            let node = result.node as? EmojiNode {
            node.next()
        }
    }
}

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let faceAnchor = anchor as? ARFaceAnchor,
            let device = sceneView.device else { return nil }
        
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let node = SCNNode(geometry: faceGeometry)
        node.geometry?.firstMaterial?.fillMode = .lines
        
        // 1
        node.geometry?.firstMaterial?.transparency = 0.0

        // 2
        let noseNode = EmojiNode(with: options)

        // 3
        noseNode.name = "nose"

        // 4
        node.addChildNode(noseNode)

        // 5
        updateFeatures(for: node, using: faceAnchor)
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
            let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return }
        faceGeometry.update(from: faceAnchor.geometry)
        
        updateFeatures(for: node, using: faceAnchor)
    }
}
