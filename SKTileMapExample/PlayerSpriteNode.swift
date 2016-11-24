//
//  PlayerSpriteNode.swift
//  SKTileMapExample
//
//  Created by Skyler Lauren on 11/18/16.
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

enum Direction: Int {
    case down = 0
    case left = 1
    case right = 2
    case up = 3
}

class PlayerSpriteNode: SKSpriteNode {
   
    var velocity = CGPoint.zero
    var moveSpeed: CGFloat = 0
    var distanceTraveld: CGFloat = 0.0
    
    var frameIndex = 0
    
    var direction = Direction.down
    
    var moveTextures = [[SKTexture]]()
    
    private var columns = 0
    private var rows = 0
    
    init (imageName: String, columns: Int, rows: Int) {
        
        //get individual textures from spritesheet
        let spritesheet = SKTexture(imageNamed: imageName)
    
        let textureWidth = 1.0/Double(columns)
        let textureHeight = 1.0/Double(rows)
        
        for y in 0 ..< columns{
            var textures = [SKTexture]()
            for x in 0 ..< rows{
                textures.append(SKTexture(rect: CGRect(x: Double(x) * textureWidth, y: 1 - (Double(y) * textureHeight) - textureHeight, width: textureWidth, height: textureHeight), in: spritesheet))
            }
            moveTextures.append(textures)
        }
        
        //give it the pixel look
        for textures in moveTextures{
            for texture in textures{
                texture.filteringMode = .nearest
            }
        }
                
        super.init(texture: moveTextures[0][0], color: UIColor.clear, size: moveTextures[0][0].size())
        
        moveSpeed = size.width * 5
        
        self.columns = columns
        self.rows = rows
    }
    
    func update(dt: TimeInterval){
        
       
        
        //set direction based on velocity
        if abs(velocity.y) > abs(velocity.x){
            if velocity.y > 0 && direction != .up{
                switchDirection(direction: .up)
            }else if velocity.y < 0 && direction != .down{
                switchDirection(direction: .down)
            }
        }else{
            if velocity.x > 0 && direction != .right{
                switchDirection(direction: .right)
            }else if velocity.x < 0 && direction != .left{
                switchDirection(direction: .left)
            }
        }
        
        //see if velocity is great enough to move the player
        if abs(velocity.x) + abs(velocity.y) > 0.5 {
            
            //calculate new position based on veloity and move speed
            let newPosition = CGPoint(x: position.x + velocity.x * CGFloat(dt) * moveSpeed, y: position.y + velocity.y * CGFloat(dt) * moveSpeed)
            
            distanceTraveld += abs(position.distanceFromPoint(point: newPosition))
            
            if distanceTraveld > size.width {
                frameIndex += 1
                let index = direction.rawValue
                let textures = moveTextures[index]
                
                if frameIndex > textures.count-1{
                    frameIndex = 0
                }
                
                texture = textures[frameIndex]
            
                distanceTraveld = 0
            }
            
             self.position = newPosition

        }
        //if not moving set texture to resting texture
        else{
            let index = direction.rawValue
            frameIndex = columns - 1
            texture = moveTextures[index][frameIndex]
        }
    }
    
    func switchDirection(direction: Direction){
        self.direction = direction
        frameIndex = columns - 1
        let index = direction.rawValue
        let textures = moveTextures[index]
        texture = textures[frameIndex]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
