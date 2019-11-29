//
//  ViewController.swift
//  ArPoc
//
//  Created by Collin Hemeltjen on 19/11/2019.
//  Copyright © 2019 Collin Hemeltjen. All rights reserved.
//

import UIKit
import RealityKit
import ARKit
import Combine

class ViewController: UIViewController {

	@IBOutlet var arView: ARView!
	let boxAnchor = try! Experience.loadBox()

	override func viewDidLoad() {
		super.viewDidLoad()
		arView.scene.anchors.append(boxAnchor)

        // Add the box anchor to the scene
		addTapGestureToSceneView()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		enablePeopleOcclusion()
	}

	func addVase(on anchor: float4x4) {
		guard let entity = boxAnchor.tulp?.clone(recursive: true) else {
			fatalError()
		}
		let anchorEntity = AnchorEntity(world: anchor)
		self.arView.scene.anchors.append(anchorEntity)

		anchorEntity.addChild(entity, preservingWorldTransform: false)
	}

	func addTapGestureToSceneView() {
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap(withGestureRecognizer:)))
		arView.addGestureRecognizer(tapGestureRecognizer)
	}

	var isFirstTap = true
	@objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
		let tapLocation = recognizer.location(in: arView)

		guard let entity = arView.entity(at: tapLocation) else {
			let hitTestResultsWithFeaturePoints = arView.hitTest(tapLocation, types: .estimatedHorizontalPlane)
			if let hitTestResultWithFeaturePoints = hitTestResultsWithFeaturePoints.first {
				addVase(on: hitTestResultWithFeaturePoints.worldTransform)
			}
			return
		}
		if entity == boxAnchor.tulp {
			entity.removeFromParent()
		} else if entity == boxAnchor.findEntity(named: "Ground Plane") {
			let hitTestResultsWithFeaturePoints = arView.hitTest(tapLocation, types: .estimatedHorizontalPlane)
			if let hitTestResultWithFeaturePoints = hitTestResultsWithFeaturePoints.first {
				addVase(on: hitTestResultWithFeaturePoints.worldTransform)
			}
			return
		}
	}

	func enablePeopleOcclusion(){
		guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
			print("People occlusion is not supported on this device.")
			return
		}
		guard let config = arView.session.configuration else {
			fatalError("Unexpectedly failed to get the configuration.")
		}
		config.frameSemantics.insert(.personSegmentationWithDepth)
		arView.session.run(config)
	}
}
