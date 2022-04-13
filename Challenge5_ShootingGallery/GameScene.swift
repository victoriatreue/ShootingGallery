//
//  GameScene.swift
//  Challenge5_ShootingGallery
//
//  Created by Victoria Treue on 2/9/21.
//

import SpriteKit
import GameplayKit

public var highestScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties

    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var gameOver: SKSpriteNode!
    var score = 0 { didSet { scoreLabel.text = "Score: \(score)" } }
    
    var targets = ["goalOne", "goalTwo", "dontShoot"]
    var enemyCount = 0
    var gameTimer: Timer?
    var secondInterval = 1.5
    
    var gameOverTimer: Timer?
    let gameTime = 30.0
    var isGameOver = false
        
    
    // MARK: - Set Up View
    
    override func didMove(to view: SKView) {
        
        // Background
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.zPosition = -1
        background.scale(to: CGSize(width: 1329, height: 1072))
        addChild(background)
        
        // Score Label
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        score = 0
        addChild(scoreLabel)

        // Physcis World
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        // Timers
        scheduleTimers()
    }
    
    func scheduleTimers () {
        gameTimer = Timer.scheduledTimer(timeInterval: secondInterval, target: self, selector: #selector(createTargets), userInfo: nil, repeats: true)
        gameOverTimer = Timer.scheduledTimer(timeInterval: gameTime, target: self, selector: #selector(gameIsOver), userInfo: nil, repeats: false)
    }
    
        
    @objc func createTargets() {
        
        for i in 1 ... 3 {
        
            guard let target = targets.randomElement() else { return }
            let sprite = SKSpriteNode(imageNamed: target)
            sprite.name = target
            
            let randomInt = Int.random(in: 75...200)
            sprite.size = CGSize(width: randomInt, height: randomInt)

            sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
            sprite.physicsBody?.angularVelocity = 0
            sprite.physicsBody?.linearDamping = 0
            sprite.physicsBody?.angularDamping = 0
            
            enemyCount += 1
            addChild(sprite)

            switch i {
            case 1:
                sprite.position = CGPoint(x: -200, y: 159)
                sprite.physicsBody?.velocity = CGVector(dx: 400, dy: 0)
            
            case 2:
                sprite.position = CGPoint(x: 1200, y: 384)
                sprite.physicsBody?.velocity = CGVector(dx: -400, dy: 0)
                
            case 3:
                sprite.position = CGPoint(x: -200, y: 609)
                sprite.physicsBody?.velocity = CGVector(dx: 400, dy: 0)
                
            default: break
            }
        }
       
        
    // MARK: Timer
        if enemyCount == 5 { gameTimer?.invalidate(); newTimer() }
    }
    
    func newTimer() {
        if secondInterval > 0.35 { secondInterval -= 0.1 } else { secondInterval = 0.35 }
        gameTimer = Timer.scheduledTimer(timeInterval: secondInterval, target: self, selector: #selector(createTargets), userInfo: nil, repeats: true)
        enemyCount = 0
    }
    
    
    // MARK: Game Over
    @objc func gameIsOver () {
        gameOver = SKSpriteNode(imageNamed: "gameOver")
        gameOver.position = CGPoint(x: 512, y: 384)
        gameOver.zPosition = 1
        addChild(gameOver)
        
        isGameOver = true
        if score > highestScore { highestScore = score }
        saveToUserDefaults()
        gameTimer?.invalidate() //Stop Creating Targets After Game Over
    
        
    // MARK: Play Again Alert
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            [weak self] in self?.showAlert()
        }
    }
    
    func showAlert () {
        let alert = UIAlertController(title: "New Game", message: "Record To Beat: \(highestScore) points", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Play Again", style: .default, handler: {
            [weak self] _ in
            
            self?.score = 0
            self?.secondInterval = 1.5
            self?.enemyCount = 0
            self?.isGameOver = false
            self?.scheduleTimers()
            
        }))
        gameOver.removeFromParent()
        view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: Scene Updata
    override func update(_ currentTime: TimeInterval) {
        for node in children { if node.position.x < -300 { node.removeFromParent() } }
    }
    
    
    // MARK: - Touch Screen
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            
            if !isGameOver {
                if node.name == "dontShoot" {
                    score -= 3
                    node.removeFromParent()
                    run(SKAction.playSoundFileNamed("shootSoundBad", waitForCompletion: false))
                } else if node.name == "goalOne" || node.name == "goalTwo" {
                    score += 1
                    node.removeFromParent()
                    run(SKAction.playSoundFileNamed("shootSound", waitForCompletion: false))
                }
            }
        }
    }
    
    
    // MARK: User Defaults
    
    func saveToUserDefaults() {
        let encoder = JSONEncoder()
        if let savedData = try? encoder.encode(highestScore) {
            let defaults = UserDefaults.standard
            defaults.setValue(savedData, forKey: "score")
        }
    }
}
