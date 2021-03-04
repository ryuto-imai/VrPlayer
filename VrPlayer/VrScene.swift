//
//  VrScene.swift
//  VrPlayer
//
//  Created by Ryuto Imai on 2021/02/28.
//

import SwiftUI
import AVFoundation
import SceneKit
import SpriteKit
import CoreMotion

/// VR動画を表示するクラス
class VrScene: SCNScene {
    private var playerLooper: AVPlayerLooper?
    private let cameraNode: SCNNode
    private var currentDragVlaue: DragGesture.Value?
    
    override init() {
        cameraNode = SCNNode()
        super.init()

        // カメラ
        cameraNode.camera = SCNCamera()
        // カメラの向きが後ほど追加する動画の中央に向くように変更
        cameraNode.orientation = .init(0, 1, 0, 0)
        self.rootNode.addChildNode(cameraNode)
        
        // ループ動画プレイヤーの生成
        let asset = AVAsset(url: URL(string: "https://s3-ap-northeast-1.amazonaws.com/panora-t-download/wp-content/uploads/2014/11/20141103_nogawa.mp4")!)
        let playerItem = AVPlayerItem(asset: asset)
        let queuePlayer = AVQueuePlayer(playerItem: playerItem)
        queuePlayer.isMuted = true
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        
        // SKSceneを生成する
        let videoScene = SKScene(size: .init(width: 1920, height: 960))
        // AVPlayerからSKVideoNodeの生成する
        let videoNode = SKVideoNode(avPlayer: queuePlayer)
        // シーンと同じサイズとし、中央に配置する
        videoNode.position = .init(x: videoScene.size.width / 2.0, y: videoScene.size.height / 2.0)
        videoNode.size = videoScene.size
        // 座標系を上下逆にする
        videoNode.yScale = -1.0
        videoNode.play()
        videoScene.addChild(videoNode)
        
        // カメラを囲う球体
        let sphere = SCNSphere(radius: 20)
        sphere.firstMaterial?.isDoubleSided = true
        sphere.firstMaterial?.diffuse.contents = videoScene
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3Zero
        self.rootNode.addChildNode(sphereNode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// カメラを回転させる
    func drag(value: DragGesture.Value) {
        // ドラッグの移動値を取得
        if currentDragVlaue?.startLocation != value.startLocation { currentDragVlaue = nil }
        let dragX = value.location.x - (currentDragVlaue?.location.x ?? value.startLocation.x)
        let dragY = value.location.y - (currentDragVlaue?.location.y ?? value.startLocation.y)

        // カメラを回転
        cameraNode.orientation = rotateCamera(
            q: cameraNode.orientation, // カメラの元々の姿勢
            point: cameraDragPoint(dragOffset: .init(x: dragX, y: dragY)) // ドラッグした距離を角度に変換
        )
        currentDragVlaue = value
    }
    
    
    /// スクロール幅のxy移動値を角度に変換
    private func cameraDragPoint(dragOffset: CGPoint) -> CGPoint {
        let radian = CGFloat(180)
        let x = (dragOffset.x / UIScreen.main.bounds.width) * radian
        let y = (dragOffset.y / UIScreen.main.bounds.height) * radian * -1
        return .init(x: x, y: y)
    }
    
    /// カメラの回転値を取得
    private func rotateCamera(q: SCNQuaternion, point: CGPoint) -> SCNQuaternion {
        // カメラの元々の姿勢
        let current = GLKQuaternionMake(q.x, q.y, q.z, q.w)
        // y軸をドラッグのx移動値まで回転させる
        let width = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(Float(point.x)), 0, 1, 0)
        // x軸をドラッグのy移動値まで回転させる
        let height = GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(Float(point.y)), 1, 0, 0)
        // 新しいカメラの姿勢を設定
        let qp  = GLKQuaternionMultiply(GLKQuaternionMultiply(width, current), height)
        return SCNQuaternion(qp.x, qp.y, qp.z, qp.w)
    }
}
