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
        
        view.backgroundColor = .gray
        
        guard ARFaceTrackingConfiguration.isSupported else { fatalError() }
        sceneView.delegate = self
        
        setupViews()
        setupConstraints()
    }

    // UI properties
    let sceneView = ARSCNView()
    let snapButton = UIButton()
    let displayPhotoView = UIImageView()
    let descriptionLabel = UILabel()
    
    private func setupViews() {
        view.addSubview(sceneView)
        let tapSwitch = UITapGestureRecognizer(target: self, action: #selector(tapToSwitch(_:)))
        sceneView.addGestureRecognizer(tapSwitch)
        
        view.addSubview(snapButton)
        snapButton.backgroundColor = .darkGray
        snapButton.setTitle("Snap!", for: .normal)
        snapButton.layer.cornerRadius = 5.0
        let tapSnap = UITapGestureRecognizer(target: self, action: #selector(tapToSnap(_:)))
        snapButton.addGestureRecognizer(tapSnap)
        
        sceneView.addSubview(displayPhotoView)
        displayPhotoView.isHidden = true
        
        view.addSubview(descriptionLabel)
        descriptionLabel.text = "Tap your forehead to change your program to show it off to your followers !"
        descriptionLabel.numberOfLines = 0
    }
    
    private func setupConstraints() {
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        snapButton.translatesAutoresizingMaskIntoConstraints = false
        displayPhotoView.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -150),
            
            snapButton.topAnchor.constraint(equalTo: sceneView.bottomAnchor, constant: 16),
            snapButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            snapButton.heightAnchor.constraint(equalToConstant: 32),
            snapButton.widthAnchor.constraint(equalToConstant: 72),
            
            displayPhotoView.topAnchor.constraint(equalTo: sceneView.topAnchor),
            displayPhotoView.leadingAnchor.constraint(equalTo: sceneView.leadingAnchor),
            displayPhotoView.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor),
            displayPhotoView.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: snapButton.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
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
      let child = node.childNode(withName: "forehead", recursively: false) as? EmojiNode

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
    
    @objc private func tapToSnap(_ sender: UIButton) {
        let image = sceneView.snapshot()
        displayPhotoView.image = image
        displayPhotoView.isHidden = false
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
        let foreheadNode = EmojiNode(with: options)

        // 3
        foreheadNode.name = "forehead"

        // 4
        node.addChildNode(foreheadNode)

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
