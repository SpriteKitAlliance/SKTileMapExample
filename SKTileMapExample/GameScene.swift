//
//  GameScene.swift
//  SKTileMapExample
//
//  Created by Skyler Lauren on 11/22/16.
//  Copyright © 2016 Sky Mist Development. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.


import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var player = PlayerSpriteNode(imageName: "Frank", columns: 4, rows: 4)
    private var outline = SKSpriteNode(imageNamed: "outline")

    private var touchStartLocation = CGPoint.zero
    
    private var lastUpdateTime: TimeInterval = 0.0
    
    private var dirtTileMap: SKTileMapNode!
    
    //analog controller
    private var controller: SKShapeNode!
    private var joystick: SKShapeNode!
    private var knob: SKShapeNode!
    
    override func didMove(to view: SKView) {
        
        player.zPosition = 10
        addChild(player)
        
        dirtTileMap = childNode(withName: "//dirt") as? SKTileMapNode
        
        //outline
        outline.zPosition = 4
        outline.texture?.filteringMode = .nearest
        dirtTileMap?.addChild(outline)
        
        //analog controller
        controller = SKShapeNode(circleOfRadius: size.width/4)
        controller.fillColor = SKColor.lightGray
        controller.zPosition = 101
        camera!.addChild(controller)
        controller.isHidden = true
        controller.alpha = 0.75
        
        joystick = SKShapeNode(circleOfRadius: size.width/8)
        joystick.zPosition = 1
        joystick.fillColor = SKColor.darkGray
        controller.addChild(joystick)
        
        knob = SKShapeNode(circleOfRadius: size.width/16)
        knob.zPosition = 2
        knob.fillColor = SKColor.black
        controller.addChild(knob)
        
    }
    
    func touchDown(atPoint pos : CGPoint) {
        touchStartLocation = pos
        
        //analog controller
        controller.position = pos
        controller.isHidden = false
        knob.position = CGPoint.zero
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
        let convertedPoint = CGPoint(x:(pos.x-touchStartLocation.x), y:(pos.y-touchStartLocation.y))
        player.velocity = convertedPoint
        
        //normalize velocity
        let standardWidth = size.width/4
        let normalX = (player.velocity.x/standardWidth).clamped(v1: -1, 1)
        let normalY = (player.velocity.y/standardWidth).clamped(v1: -1, 1)
        
        //making it so any given direction the velocity is between -1 to 1 total
        let total = abs(normalY) + abs(normalX)
        let percentX = abs(normalX)/total
        let percentY = abs(normalY)/total
        
        player.velocity = CGPoint(x: normalX * percentX, y: normalY * percentY)
        
        //analog controller
        knob.position = convertedPoint
    }
    
    func touchUp(atPoint pos : CGPoint) {
        touchStartLocation = CGPoint.zero
        player.velocity = CGPoint.zero
        controller.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self.camera!)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self.camera!)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self.camera!)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self.camera!)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
        let dt = currentTime - lastUpdateTime
        player.update(dt: dt)
        
        //keep player from going off map
        player.position.x = player.position.x.clamped(v1: player.size.width/2, dirtTileMap.mapSize.width-player.size.width/2)
        player.position.y = player.position.y.clamped(v1: player.size.height/2, dirtTileMap.mapSize.height-player.size.height/2)
        
        //keep camera from going off map
        camera?.position = player.position
        camera?.position.x = camera!.position.x.clamped(v1: size.width/2, dirtTileMap.mapSize.width-size.width/2)
        camera?.position.y = camera!.position.y.clamped(v1: size.height/2, dirtTileMap.mapSize.height-size.height/2)
        
        //set target outline
        var playerOffsetPosition = CGPoint(x: player.position.x, y: player.position.y-player.size.height/4)
        
        let width = Int(dirtTileMap.tileSize.width)
        let height = Int(dirtTileMap.tileSize.height)
        
        switch player.direction {
        case .right:
            playerOffsetPosition.x += CGFloat(width)
        case .left:
            playerOffsetPosition.x -= CGFloat(width)
        case .down:
            playerOffsetPosition.y -= CGFloat(height)
        case .up:
            playerOffsetPosition.y += CGFloat(height)
        }
        
        let column = dirtTileMap.tileColumnIndex(fromPosition: playerOffsetPosition)
        let row = dirtTileMap.tileRowIndex(fromPosition: playerOffsetPosition)
        outline.isHidden = true
        
        if let def = dirtTileMap.tileDefinition(atColumn: column, row: row){
            if let userData = def.userData{
                if let _ = userData.value(forKey: "dirt"){
                    outline.isHidden = false
                    outline.position = CGPoint(x: column * width + width/2, y: row * height + height/2)
                }
            }
        }
        
        lastUpdateTime = currentTime
    }
}
