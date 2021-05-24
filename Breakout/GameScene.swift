//
//  GameScene.swift
//  Breakout
//
//  Created by Emma Bradford on 3/15/21.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var paddle = SKSpriteNode()
    var ball = SKShapeNode()
    var brick = SKSpriteNode()
    var bricks  = [SKSpriteNode]()
    var loseZone = SKSpriteNode()
    var playLabel = SKLabelNode()
    var livesLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var playingGame = false
    var removedBricks = 0
    var score = 0
    var lives = 3
    
    override func didMove(to view: SKView)
    {
        //this stuff happens once (when the app opens)
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        createBackground()
        makeLoseZone()
        resetGame()
        makeLabels()
    }
    
    func createBackground()
    {
        let stars = SKTexture(imageNamed: "Stars")
        for i in 0...1
        {
            let starsBackground = SKSpriteNode(texture: stars)
            starsBackground.zPosition = -1
            starsBackground.position = CGPoint(x: 0, y: starsBackground.size.height * CGFloat(i))
            addChild(starsBackground)
            let moveDown = SKAction.moveBy(x: 0, y: -starsBackground.size.height, duration: 20)
            let moveReset = SKAction.moveBy(x: 0, y: starsBackground.size.height, duration: 0)
            let moveLoop = SKAction.sequence([moveDown, moveReset])
            let moveForever  = SKAction.repeatForever(moveLoop)
            starsBackground.run(moveForever)
        }
    }
    
    func resetGame()
    {
        makeBall()
        makePaddle()
        makeBricks()
        updateLabels()
    }
    
    func kickBall ()
    {
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.applyImpulse(CGVector(dx: Int.random(in: -5...5 ), dy: 5))
    }
    
    func makeBall()
    {
        ball.removeFromParent()
        ball = SKShapeNode(circleOfRadius: 10)
        ball.position = CGPoint(x: frame.midX, y: frame.midY)
        ball.strokeColor = .black
        ball.fillColor = .yellow
        ball.name = "ball"
        //physics shape matches ball shape
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        //ignores all forces and impulses
        ball.physicsBody?.isDynamic = false
        // use presise colliiosion
        ball.physicsBody?.usesPreciseCollisionDetection = true
        //NO LOSS OF ENERGY FROM FRICTION
        ball.physicsBody?.friction = 0
        //gravity is not a factor
        ball.physicsBody?.affectedByGravity = false
        //bounces fully off of  other obje cts
        ball.physicsBody?.restitution  = 1
        //does not slow down over time
        ball.physicsBody?.linearDamping = 0;
        ball.physicsBody?.contactTestBitMask = (ball.physicsBody?.collisionBitMask)!
        addChild(ball) //add ball object to view
    }
    
    func makePaddle()
    {
        paddle.removeFromParent()
        paddle = SKSpriteNode(color: .white, size: CGSize(width: frame.width/4, height: 20))
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + 125)
        paddle.name = "paddle"
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        addChild(paddle)
    }
    
    func makeBrick(x: Int, y: Int, color: UIColor)
    {
        let brick = SKSpriteNode(color: color, size: CGSize(width: 50, height: 20))
        brick.removeFromParent()
        brick.position = CGPoint(x: x, y: y)
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.isDynamic = false
        addChild(brick)
        bricks.append(brick)
    }
    
    func makeBricks()
    {
        //remove leftover bricks from propr game
        for brick in bricks
        {
            if brick.parent != nil
            {
                brick.removeFromParent()
            }
        }
        bricks.removeAll() //clear the array
        removedBricks = 0 //reset the counter
        
        //now, figure teh number and spacing of each row of bricks
        let count  = Int(frame.width) / 55 //bricks per row
        let xOffset = (Int(frame.width) - (count * 55)) / 2 + Int(frame.minX) + 25
        let colors: [UIColor] = [.blue, .orange, .green]
        for r in 0 ..< 3
        {
            let y = Int(frame.maxY) - 15 - (r * 25)
            for i in 0 ..< count
            {
                let x = i * 55 + xOffset
                makeBrick(x: x, y: y, color: colors[r])
            }
        }
    }
    
    func makeLoseZone()
    {
        loseZone = SKSpriteNode(color: .red, size: CGSize(width: frame.width, height: 50))
        loseZone.position = CGPoint(x: frame.midX, y: frame.minY + 25)
        loseZone.name = "loseZone"
        loseZone.physicsBody = SKPhysicsBody(rectangleOf: loseZone.size)
        loseZone.physicsBody?.isDynamic = false
        addChild(loseZone)
    }
    
    func makeLabels()
    {
        playLabel.fontSize = 24
        playLabel.text = "Tap to Start"
        playLabel.fontName = "Arial"
        playLabel.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        playLabel.name = "playLabel"
        addChild(playLabel)
        
        livesLabel.fontSize = 18
        livesLabel.fontColor = .black
        livesLabel.text = ""
        livesLabel.position = CGPoint(x: frame.minX + 50, y: frame.minY + 18)
        addChild(livesLabel)
        
        scoreLabel.fontSize = 18
        scoreLabel.fontColor = .black
        scoreLabel.position = CGPoint(x: frame.maxX - 50, y: frame.minY + 18)
        addChild(scoreLabel)
    }
    
    func updateLabels()
    {
        scoreLabel.text = "Score: \(score)"
        livesLabel.text = "Lives: \(lives)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches
        {
            let location  = touch.location(in: self)
            if playingGame
            {
                paddle.position.x = location.x
            }
            else
            {
                for node in nodes(at: location)
                {
                    if node.name == "playLabel"
                    {
                        playingGame = true
                        node.alpha = 0
                        score = 0
                        lives = 3
                        updateLabels()
                        kickBall()
                    }
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches
        {
            let location  = touch.location(in: self)
            if playingGame
            {
                paddle.position.x = location.x
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //ask each brick, "is it you?"
        for brick in bricks
        {
            if contact.bodyA.node == brick || contact.bodyB.node == brick
            {
                //gameOver(winner: true)
                score += 1
                updateLabels()
                if brick.color == .blue
                {
                    brick.color = .orange //blue brick turns to orange
                }
                else if brick.color == .orange
                {
                    brick.color = .green
                }
                else//must be a green brick to get removed
                {
                    brick.removeFromParent()
                    removedBricks += 1
                    if removedBricks == bricks.count
                    {
                        gameOver(winner: true)
                    }
                }
                //ball.removeFromParent()
            }
        }
        
        if contact.bodyA.node?.name == "loseZone" || contact.bodyB.node?.name == "loseZone"
        {
            lives -= 1
            if lives > 0
            {
                score = 0
                resetGame()
                kickBall()
            }
            else
            {
                gameOver(winner: false)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        if abs(ball.physicsBody!.velocity.dx) < 100
        {
            // ball has stalled in x direction, so kick it randomly horizontally
            ball.physicsBody?.applyImpulse(CGVector(dx: Int.random(in: -3...3), dy: 0))
        }
        if abs(ball.physicsBody!.velocity.dy) < 100
        {
            // ball has stalled in y direct, so kick it randomly vertically
            ball.physicsBody?.applyImpulse(CGVector(dx: 0, dy: Int.random(in: -3...3)))
        }
    }
    
    func gameOver(winner: Bool)
    {
        playingGame = false
        playLabel.alpha = 1
        resetGame()
        if winner
        {
            playLabel.text = "You Win! Tap to play again"
        }
        else
        {
            playLabel.text = "You lose! Tap to play again"
            
        }
    }
}



