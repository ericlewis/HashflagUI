//
//  StickerARView.swift
//  Hashflag
//
//  Created by Eric Lewis on 9/10/20.
//

import SwiftUI
import RealityKit
import SDWebImage

// LOL this is so silly & shitty. plz fix.

struct ARViewContainer: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        let anchor = try! Experience.loadBox()
        let boxEntity: Entity = anchor.steelBox!.children[0]
        var boxComponent: ModelComponent = boxEntity.components[ModelComponent].self!
        
        let key = url.absoluteString.replacingOccurrences(of: ".png",
                                        with: "-SDImageResizingTransformer(%7B300.000000,300.000000%7D,0).png")
        let path = cache.cachePath(forKey: key)
        var material = SimpleMaterial()
        let texture = try! TextureResource.load(contentsOf: URL(string: "file://" + path!)!)
        material.baseColor = MaterialColorParameter.texture(texture)
        material.roughness = MaterialScalarParameter(floatLiteral: 0.1)
        material.metallic = MaterialScalarParameter(floatLiteral: 0.1)
        
        boxComponent.materials = [material]
        
        anchor.steelBox!.components.set(boxComponent)
        arView.scene.anchors.append(anchor)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}
