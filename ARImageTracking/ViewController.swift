//
//  ViewController.swift
//  ARImageTracking
//
//  Created by sun on 6/5/2562 BE.
//  Copyright © 2562 sun. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var BayMaxNode: SCNNode?
    var DuckNode: SCNNode?
    var imageNode = [SCNNode]()
    var isJumping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        let BayMaxScene = SCNScene(named: "art.scnassets/Bigmax_White_OBJ.scn")
        let DuckScene = SCNScene(named: "art.scnassets/tinker.scn")
        
        BayMaxNode = BayMaxScene?.rootNode
        DuckNode = DuckScene?.rootNode
        
        
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        if let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources AQUAMAN", bundle: Bundle.main) {
            configuration.trackingImages = trackingImages
            configuration.maximumNumberOfTrackedImages = 2
            
        }

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let node = SCNNode()
        
        if let ImageAnchor = anchor as? ARImageAnchor {
            
            let size = ImageAnchor.referenceImage.physicalSize
            let plane = SCNPlane(width: size.width, height: size.height)
            
            plane.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.5)
            plane.cornerRadius = 0.005
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
            

            var shapeNode: SCNNode?
            
            switch ImageAnchor.referenceImage.name{ //  check รูปภาพที่จับได้
                
            case CardType.USBC.rawValue :
                shapeNode = DuckNode
            case CardType.BOOK.rawValue :
                shapeNode = BayMaxNode
            default :
                break
                
            }
            
            let shapeSpin = SCNAction.rotateBy(x: 0, y: 2 * .pi , z: 0, duration:  5) // หมุน
            let repeatSpin = SCNAction.repeatForever(shapeSpin)
            shapeNode?.runAction(repeatSpin)
            
            guard let shape = shapeNode else { return nil }
            node.addChildNode(shape)
            imageNode.append(node)
            
            return node
            
            
         }
        
        return nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if imageNode.count == 2 {
            let positionOne = SCNVector3ToGLKVector3(imageNode[0].position)
            let positionTwo = SCNVector3ToGLKVector3(imageNode[1].position)
            
            let distance = GLKVector3Distance(positionOne, positionTwo) // ระยะที่ 2 วัตถุอยู่ห่างกัน ตั้งแต่ซ้ายสุดไปขวาสุด
            print(distance)
            if distance < 30 /* cm */ {
                
                print("We are close!")
                
                spinJump(node: imageNode[0])
                spinJump(node: imageNode[1])
                isJumping = true
                
            }else {
                
                isJumping = false
            }
        }
    }
    
    enum CardType :String{
        case USBC = "USB-C"
        case BOOK = "bookIMG"
    }
    
    func spinJump(node: SCNNode)  {
        if isJumping {return}
        
        let shapeNode = node.childNodes[1]
        
        let shapeSpin = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 1)
        shapeSpin.timingMode = .easeInEaseOut
        
        let up = SCNAction.moveBy(x: 0, y: 0.05, z: 0, duration: 0.5)
        up.timingMode = .easeInEaseOut
        let down = up.reversed()
        
        let upDown = SCNAction.sequence([up,down])
        
        
        shapeNode.runAction(shapeSpin)
        shapeNode.runAction(upDown)
        
        
    }

  
}
