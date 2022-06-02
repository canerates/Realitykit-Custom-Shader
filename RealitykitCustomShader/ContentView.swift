//
//  ContentView.swift
//  RealitykitCustomShader
//
//  Created by Caner on 2022/6/2.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    var body: some View {
        return ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        var descr = MeshDescriptor(name: "tritri")
        descr.positions = MeshBuffers.Positions([[-1,-1,0],[1,-1,0],[0,1,0]])
        descr.primitives = .triangles([0,1,2])
        
        var model = ModelEntity()
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Error creating default metal device")
        }
        
        let library = device.makeDefaultLibrary()!
        
        let surfaceShader = CustomMaterial.SurfaceShader(named: "surfaceShader", in: library)
        let geometryModifier = CustomMaterial.GeometryModifier(named: "geometryModifier", in: library)
        
        var customMaterial: CustomMaterial
        
        do {
            customMaterial = try CustomMaterial(surfaceShader: surfaceShader, geometryModifier: geometryModifier, lightingModel: .lit)
            
            if let textureResource = try? TextureResource.load(named: "Sample") {
                let texture = CustomMaterial.Texture(textureResource)
                customMaterial.baseColor.texture = .init(texture)
                
                model = ModelEntity(mesh: try! .generate(from: [descr]), materials: [customMaterial])
                
            } else {
                print("Texture file could not loaded.")
            }
        } catch {
            print("Custom Material Initializing Error: \(error.localizedDescription)")
        }
        
        let anchor = AnchorEntity(world: [0,0,-2])
        anchor.addChild(model)
        
        arView.scene.anchors.append(anchor)
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
