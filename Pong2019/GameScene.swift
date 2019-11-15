//
//  GameScene.swift
//  Pong2019
//
//  Created by  on 4/23/19.
//  Copyright © 2019 DocsApps. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var aiPaddle = SKSpriteNode()
    var ball = SKSpriteNode()
    var paddle = SKSpriteNode()
    var bottom = SKSpriteNode()
    var top = SKSpriteNode()
    var playerLabel = SKLabelNode()
    var computerLabel = SKLabelNode()
    var playerScore = 0
    var computerScore = 0
    
    override func didMove(to view: SKView) {
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        physicsWorld.gravity = CGVector(dx: 0, dy: 0.0)
        
        ball = childNode(withName: "ball") as! SKSpriteNode
        paddle = childNode(withName: "paddle") as! SKSpriteNode
        createAIPaddle()
        createTopAndBottom()
        setUpLabels()
        
        ball.physicsBody?.categoryBitMask = 1
        paddle.physicsBody?.categoryBitMask = 2 // only necessary for future stretches
        aiPaddle.physicsBody?.categoryBitMask = 3 // only necessary for future stretches
        bottom.physicsBody?.categoryBitMask = 4
        top.physicsBody?.categoryBitMask = 4
        ball.physicsBody?.contactTestBitMask = 4
        physicsWorld.contactDelegate = self
        
        
    }
    
    func setUpLabels()
    {
        playerLabel = SKLabelNode(fontNamed: "Arial")
        playerLabel.text = "0"
        playerLabel.fontSize = 75
        playerLabel.position = CGPoint(x: frame.width * 0.25, y: frame.height * 0.10)
        playerLabel.fontColor = .blue
        addChild(playerLabel)
        
        computerLabel = SKLabelNode(fontNamed: "Arial")
        computerLabel.text = "0"
        computerLabel.fontSize = 75
        computerLabel.position = CGPoint(x: frame.width * 0.25, y: frame.height * 0.90)
        computerLabel.fontColor = .blue
        addChild(computerLabel)
        
        
    }
    
    func createTopAndBottom()
    {
        bottom = SKSpriteNode(color: .red, size: CGSize(width: frame.width, height: 50))
        bottom.position = CGPoint(x: frame.width*0.5, y: 0)
        bottom.physicsBody = SKPhysicsBody(rectangleOf: bottom.frame.size)
        bottom.physicsBody?.isDynamic = false
        bottom.name = "bottom"
        addChild(bottom)
        
        top = SKSpriteNode(color: .red, size: CGSize(width: frame.width, height: 50))
        top.position = CGPoint(x: frame.width*0.5, y: frame.height)
        top.physicsBody = SKPhysicsBody(rectangleOf: top.frame.size)
        top.physicsBody?.isDynamic = false
        top.name = "top"
        addChild(top)
        
        
    }
    
    func createAIPaddle()
    {
        aiPaddle = SKSpriteNode(color: .black, size: CGSize(width: 200, height: 50))
        aiPaddle.position = CGPoint(x: frame.width * 0.5, y: frame.height * 0.8)
        aiPaddle.physicsBody = SKPhysicsBody(rectangleOf: aiPaddle.frame.size)
        if let aiPhysics = aiPaddle.physicsBody {
            aiPhysics.allowsRotation = false
            aiPhysics.friction = 0
            aiPhysics.affectedByGravity = false
            aiPhysics.isDynamic = false
        }
        aiPaddle.name = "aiPaddle"
        aiPaddle.zPosition = 1
        addChild(aiPaddle)
        
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run(followBall),
            SKAction.wait(forDuration: 0.2)
            ])
        ))
        
    }
    

    
    func followBall()
    {
        let move = SKAction.moveTo(x: ball.position.x, duration: 0.3)
        aiPaddle.run(move)
    }
    
    var isFingerOnPaddle = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first ?? UITouch()
        let touchLocation = touch.location(in: self)
            
        if let body = physicsWorld.body(at: touchLocation) {
            if body.node?.name == "paddle"
            {
                // we found the paddle
                isFingerOnPaddle = true
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isFingerOnPaddle == true
        {
            let touch = touches.first ?? UITouch()
            let touchLoc = touch.location(in: self)
            
            // get reference to paddle
            let paddle = childNode(withName: "paddle") as! SKSpriteNode
            
            paddle.position = CGPoint(x: touchLoc.x, y: paddle.position.y)
            
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isFingerOnPaddle = false
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("contact")
        if contact.bodyA.categoryBitMask == 1 && contact.bodyB.categoryBitMask == 4 {
            displayEmitterNode(position: contact.contactPoint)
            if contact.bodyB.node == bottom
            {
                computerScore += 1
            }
            else
            {
                playerScore += 1
            }
            updateLabels()
            resetBall()
        }
        if contact.bodyA.categoryBitMask == 4 && contact.bodyB.categoryBitMask == 1 {
            displayEmitterNode(position: contact.contactPoint)
            if contact.bodyA.node == bottom
            {
                computerScore += 1
            }
            else
            {
                playerScore += 1
            }
            updateLabels()
            resetBall()
        }
    }
    
    func displayEmitterNode(position: CGPoint)
    {
        if let particles = SKEmitterNode(fileNamed: "Smoke.sks") {
            particles.position = position
            addChild(particles)
            particles.run(
                SKAction.sequence([
                    SKAction.wait(forDuration: 2.0),
                    SKAction.removeFromParent()
                    ])
            )
        }

    }
    
    func updateLabels()
    {
        playerLabel.text = "\(playerScore)"
        computerLabel.text = "\(computerScore)"
    }
    func resetBall()
    {
        ball.physicsBody?.velocity = CGVector.zero
        let wait = SKAction.wait(forDuration: 1.0)
        let repositionBall = SKAction.run(bringBallToCenter)
        let pushBall = SKAction.run(applyImpulseToBall)
        let sequence = SKAction.sequence([wait,repositionBall,wait,pushBall])
        run(sequence)
    }
    func bringBallToCenter()
    {
        ball.position = CGPoint(x: frame.width/2, y: frame.height / 2)
    }
    func applyImpulseToBall()
    {
        let impulseArray = [200,-200,150,-150]
        let randx = Int.random(in: 0..<impulseArray.count)
        let randy = Int.random(in: 0..<impulseArray.count)
        ball.physicsBody?.applyImpulse(CGVector(dx: impulseArray[randx], dy:impulseArray[randy]))
    }
}
