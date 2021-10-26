//
//  ContentView.swift
//  VrPlayer
//
//  Created by Ryuto Imai on 2021/02/28.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    let vrScene = VrScene()
    
    var body: some View {
        SceneView(scene: vrScene)
            .gesture(
                DragGesture()
                    .onChanged(vrScene.drag(value:))
            )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
