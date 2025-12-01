
import SwiftUI
import Combine

// MARK: - Game Data Manager
class GameDataManager: ObservableObject {
    @Published var bestPerformance: Int = 0
    @Published var dimensionsUnlocked: Int = 1
    @Published var totalPlayTime: TimeInterval = 0
    @Published var gamesPlayed: Int = 0
    
    private let userDefaults = UserDefaults.standard
    private let bestPerformanceKey = "bestPerformance"
    private let dimensionsKey = "dimensionsUnlocked"
    private let playTimeKey = "totalPlayTime"
    private let gamesPlayedKey = "gamesPlayed"
    
    init() {
        loadStats()
    }
    
    func updateStats(score: Int, level: Int, playTime: TimeInterval) {
        if score > bestPerformance {
            bestPerformance = score
        }
        if level > dimensionsUnlocked {
            dimensionsUnlocked = level
        }
        totalPlayTime += playTime
        gamesPlayed += 1
        saveStats()
    }
    
    private func loadStats() {
        bestPerformance = userDefaults.integer(forKey: bestPerformanceKey)
        dimensionsUnlocked = userDefaults.integer(forKey: dimensionsKey)
        totalPlayTime = userDefaults.double(forKey: playTimeKey)
        gamesPlayed = userDefaults.integer(forKey: gamesPlayedKey)
    }
    
    private func saveStats() {
        userDefaults.set(bestPerformance, forKey: bestPerformanceKey)
        userDefaults.set(dimensionsUnlocked, forKey: dimensionsKey)
        userDefaults.set(totalPlayTime, forKey: playTimeKey)
        userDefaults.set(gamesPlayed, forKey: gamesPlayedKey)
    }
    
    func getFormattedPlayTime() -> String {
        let hours = Int(totalPlayTime) / 3600
        let minutes = (Int(totalPlayTime) % 3600) / 60
        let seconds = Int(totalPlayTime) % 60
        
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %02ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
}

// MARK: - Splash Screen
struct SplashScreen: View {
    @StateObject private var gameData = GameDataManager()
    @State private var isActive = false
    @State private var scaleEffect: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Cosmic background
            
            GeometryReader { geometry in
                Image("game_background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.7), Color.black.opacity(0.5)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .ignoresSafeArea()
            }
            .ignoresSafeArea()
            
            // Animated stars
            ForEach(0..<40, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.3...0.9)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
            }
            
            VStack(spacing: 30) {
                
                Text("PortalDrifter\nDash")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .blue, radius: 10)
                    .multilineTextAlignment(.center)
                    .scaleEffect(scaleEffect)
                    .opacity(opacity)
               
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                scaleEffect = 1.0
                opacity = 1.0
            }
            
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            // Move to main menu after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            MainMenuView()
                .environmentObject(gameData)
        }
    }
}


// MARK: - Main Menu View
struct MainMenuView: View {
    @EnvironmentObject var gameData: GameDataManager
    @State private var selectedFeature = 0
    @State private var showGame = false
    @State private var bounceEffect = false
    
    private let features = [
        FeatureCard(
            title: "Phase Gateway",
            description: "Create interdimensional gateways to traverse through space and overcome cosmic barriers",
            icon: "circle.circle.fill",
            colors: [.blue, .cyan]
        ),
        FeatureCard(
            title: "Dynamic Challenges",
            description: "Face ever-changing Dimensional Blockades that test your reflexes and strategic thinking",
            icon: "sparkles",
            colors: [.purple, .pink]
        ),
        FeatureCard(
            title: "Portal Progression",
            description: "Advance through multiple dimensional blockades with increasing complexity and visual splendor",
            icon: "chart.line.uptrend.xyaxis",
            colors: [.orange, .yellow]
        ),
        FeatureCard(
            title: "Strategic Gameplay",
            description: "Master the art of portal placement and timing to achieve the ultimate Mystic Score",
            icon: "brain.head.profile",
            colors: [.green, .mint]
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            GeometryReader { geometry in
                Image("game_background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.7), Color.black.opacity(0.5)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .ignoresSafeArea()
            }
            .ignoresSafeArea()
            
            // Content
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 10) {
                        Text("PortalDrifter\nDash")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: .blue, radius: 15)
                        
                        Text("Embark on an Interdimensional Journey")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.top, 50)
                    
                    // Feature Carousel Section
                    VStack(spacing: 15) {
                        Text("Game Features")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 20)
                        
                        // TabView with proper spacing
                        VStack(spacing: 0) {
                            TabView(selection: $selectedFeature) {
                                ForEach(0..<features.count, id: \.self) { index in
                                    features[index]
                                        .tag(index)
                                        .padding(.horizontal, 10)
                                }
                            }
                            .frame(height: 250)
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            
                            // Custom indicators with proper spacing
                            HStack(spacing: 10) {
                                ForEach(0..<features.count, id: \.self) { index in
                                    Circle()
                                        .fill(selectedFeature == index ? Color.blue : Color.gray.opacity(0.5))
                                        .frame(width: 8, height: 8)
                                        .scaleEffect(selectedFeature == index ? 1.2 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedFeature)
                                }
                            }
                            .padding(.top, 10)
                            .padding(.bottom, 15)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // Start Game Button
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            bounceEffect = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            bounceEffect = false
                            showGame = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                            Text("Begin Portal Adventure")
                                .font(.system(size: 20, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: .blue.opacity(0.6), radius: 10, y: 5)
                        .scaleEffect(bounceEffect ? 1.1 : 1.0)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                    
                    // Stats Preview
                    VStack(spacing: 15) {
                        Text("Portal Records")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                        
                        HStack(spacing: 15) {
                            StatPreview(icon: "trophy.fill", value: "\(gameData.bestPerformance)", label: "Best Performance", color: .yellow)
                            StatPreview(icon: "chart.line.uptrend.xyaxis", value: "\(gameData.dimensionsUnlocked)", label: "Dimensions", color: .green)
                            StatPreview(icon: "clock.fill", value: "\(gameData.getFormattedPlayTime())", label: "Play Time", color: .orange)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 10)
                    
                    Spacer(minLength: 50)
                }
            }
        }
        .fullScreenCover(isPresented: $showGame) {
            PortalRunnerView()
                .environmentObject(gameData)
        }
    }
}


struct FeatureCard: View {
    let title: String
    let description: String
    let icon: String
    let colors: [Color]
    @State private var glow = false
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.white)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: colors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .shadow(color: colors[0].opacity(0.6), radius: glow ? 15 : 8)
            
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .padding(25)
        .background(Color.black.opacity(0.4))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(LinearGradient(gradient: Gradient(colors: colors), startPoint: .leading, endPoint: .trailing), lineWidth: 2)
        )
        .padding(.horizontal, 10)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glow.toggle()
            }
        }
    }
}

struct StatPreview: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

// MARK: - Enhanced Game Models
struct PortalPlayer {
    var position: CGPoint
    var velocity: CGVector = .zero
    var isJumping: Bool = false
    var isRunning: Bool = true
    var portalGunCharges: Int = 3
    var activePortals: (blue: Portal?, orange: Portal?) = (nil, nil)
    var lives: Int = 3
    var invincible: Bool = false
    
    init(position: CGPoint, lives: Int = 3) {
        self.position = position
        self.lives = lives
    }
}

struct Portal: Identifiable {
    let id = UUID()
    var position: CGPoint
    var type: PortalType
    var isActive: Bool = true
    
    enum PortalType {
        case blue, orange
        
        var color: Color {
            switch self {
            case .blue: return .blue
            case .orange: return .orange
            }
        }
        
        var accentColor: Color {
            switch self {
            case .blue: return .cyan
            case .orange: return .yellow
            }
        }
    }
}

struct Barrier: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGSize
    var barrierType: BarrierType
    
    enum BarrierType {
        case wall, pit, movingWall, laserGate, platform
        
        var color: Color {
            switch self {
            case .wall: return .gray
            case .pit: return .black
            case .movingWall: return .purple
            case .laserGate: return .red
            case .platform: return .green
            }
        }
    }
}

struct GameLevel {
    let levelNumber: Int
    let levelName: String
    let speed: CGFloat
    let barrierFrequency: TimeInterval
    let allowedBarriers: [Barrier.BarrierType]
    let themeColor: Color
    let backgroundGradient: [Color]
}

struct GameWorld {
    var score: Int = 0
    var distance: CGFloat = 0
    var gameSpeed: CGFloat = 3.0
    var isPlaying: Bool = false
    var gameEnded: Bool = false
    var currentLevel: Int = 1
    var portalCooldown: Bool = false
    var levelProgress: CGFloat = 0
    var bestPerformance: Int = 0
    var missionComplete: Bool = false
    var levelComplete: Bool = false
    var completedLevelName: String = ""
    var sessionStartTime: Date?
    var sessionPlayTime: TimeInterval = 0
}

// MARK: - Game Engine with Working Logic
class PortalEngine: ObservableObject {
    @Published var player = PortalPlayer(position: CGPoint(x: 80, y: 350))
    @Published var barriers: [Barrier] = []
    @Published var world = GameWorld()
    
    private var gameLoop: Timer?
    private var barrierSpawner: Timer?
    private let screenBounds = UIScreen.main.bounds
    private let floorLevel: CGFloat = 350
    private var lastBarrierPosition: CGFloat = 400
    private let gravity: CGFloat = 0.6
    private let jumpStrength: CGFloat = -14
    private var lastUpdateTime: Date?
    
    // Level system
    private let levels: [GameLevel] = [
        GameLevel(
            levelNumber: 1,
            levelName: "Training Grounds",
            speed: 3.0,
            barrierFrequency: 3.0,
            allowedBarriers: [.wall, .platform],
            themeColor: .blue,
            backgroundGradient: [Color(red: 0.1, green: 0.1, blue: 0.4), Color(red: 0.2, green: 0.2, blue: 0.6)]
        ),
        GameLevel(
            levelNumber: 2,
            levelName: "Portal Practice",
            speed: 4.0,
            barrierFrequency: 2.5,
            allowedBarriers: [.wall, .pit, .platform],
            themeColor: .green,
            backgroundGradient: [Color(red: 0.1, green: 0.3, blue: 0.2), Color(red: 0.2, green: 0.5, blue: 0.3)]
        ),
        GameLevel(
            levelNumber: 3,
            levelName: "Advanced Challenge",
            speed: 5.0,
            barrierFrequency: 2.0,
            allowedBarriers: [.wall, .pit, .movingWall, .platform],
            themeColor: .orange,
            backgroundGradient: [Color(red: 0.4, green: 0.2, blue: 0.1), Color(red: 0.6, green: 0.3, blue: 0.2)]
        ),
        GameLevel(
            levelNumber: 4,
            levelName: "Expert Mode",
            speed: 6.0,
            barrierFrequency: 1.5,
            allowedBarriers: [.wall, .pit, .movingWall, .laserGate, .platform],
            themeColor: .red,
            backgroundGradient: [Color(red: 0.4, green: 0.1, blue: 0.1), Color(red: 0.6, green: 0.2, blue: 0.2)]
        )
    ]
    
    public var currentLevelConfig: GameLevel {
        let levelIndex = min(world.currentLevel - 1, levels.count - 1)
        return levels[levelIndex]
    }
    
    func launchGame() {
        resetGameState()
        world.isPlaying = true
        world.sessionStartTime = Date()
        lastUpdateTime = Date()
        
        gameLoop = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            self?.updateGameFrame()
        }
        
        startBarrierSpawning()
    }
    
    func stopGame() {
        world.isPlaying = false
        gameLoop?.invalidate()
        barrierSpawner?.invalidate()
    }
    
    func continueGame() {
        guard !world.isPlaying else { return }
        world.isPlaying = true
        lastUpdateTime = Date()
        
        gameLoop = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            self?.updateGameFrame()
        }
        
        startBarrierSpawning()
    }
    
    private func startBarrierSpawning() {
        barrierSpawner?.invalidate()
        barrierSpawner = Timer.scheduledTimer(withTimeInterval: currentLevelConfig.barrierFrequency, repeats: true) { [weak self] _ in
            self?.generateBarrier()
        }
    }
    
    func resetGame() {
        resetGameState()
        world.missionComplete = false
        world.gameEnded = false
        world.levelComplete = false
    }
    
    private func resetGameState() {
        player = PortalPlayer(position: CGPoint(x: 80, y: floorLevel), lives: 3)
        barriers.removeAll()
        world.score = 0
        world.distance = 0
        world.currentLevel = 1
        world.gameSpeed = 3.0
        world.levelProgress = 0
        world.portalCooldown = false
        world.levelComplete = false
        world.sessionPlayTime = 0
        lastBarrierPosition = 400
        createInitialBarriers()
    }
    
    private func createInitialBarriers() {
        for i in 0..<2 {
            let barrierType: Barrier.BarrierType = [.wall, .platform].randomElement()!
            let position = CGPoint(x: lastBarrierPosition + CGFloat(i) * 300, y: getBarrierHeight(for: barrierType))
            let size = getBarrierSize(for: barrierType)
            barriers.append(Barrier(position: position, size: size, barrierType: barrierType))
        }
        lastBarrierPosition += 600
    }
    
    private func updateGameFrame() {
        guard world.isPlaying, let lastTime = lastUpdateTime else { return }
        
        let currentTime = Date()
        let deltaTime = currentTime.timeIntervalSince(lastTime)
        lastUpdateTime = currentTime
        
        // Update play time
        if let sessionStart = world.sessionStartTime {
            world.sessionPlayTime = currentTime.timeIntervalSince(sessionStart)
        }
        
        // Update game progress
        world.distance += world.gameSpeed * CGFloat(deltaTime) * 60
        world.score = Int(world.distance / 5)
        
        // Update level progression
        updateLevelProgression()
        
        applyPhysics(deltaTime: deltaTime)
        moveBarriers(deltaTime: deltaTime)
        updatePortalSystem()
        checkCollisions()
        
        // Clean up off-screen barriers
        barriers.removeAll { $0.position.x < -100 }
    }
    
    private func updateLevelProgression() {
        let levelThreshold = world.currentLevel * 1000
        world.levelProgress = min(CGFloat(world.score) / CGFloat(levelThreshold), 1.0)
        
        if world.score >= levelThreshold && world.currentLevel < levels.count {
            // Level completed! Pause the game and show level complete screen
            world.levelComplete = true
            world.completedLevelName = currentLevelConfig.levelName
            world.isPlaying = false // PAUSE THE GAME
            stopGame() // STOP ALL TIMERS
        }
        
        // Check for mission completion (all levels completed)
        if world.currentLevel >= levels.count && world.score >= levels.count * 1000 {
            completeMission()
        }
    }
    
    private func advanceToNextLevel() {
        world.levelComplete = false
        world.currentLevel += 1
        world.gameSpeed = currentLevelConfig.speed
        world.isPlaying = true
        lastUpdateTime = Date()
        
        // Restart the game loop
        gameLoop = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            self?.updateGameFrame()
        }
        
        startBarrierSpawning()
    }
    
    private func applyPhysics(deltaTime: TimeInterval) {
        if player.isJumping {
            player.velocity.dy += gravity * CGFloat(deltaTime) * 60
            player.position.y += player.velocity.dy * CGFloat(deltaTime) * 60
            
            // Check if landed on floor or platform
            if player.position.y >= floorLevel {
                player.position.y = floorLevel
                player.isJumping = false
                player.velocity = .zero
            } else {
                // Check platform collisions while jumping/falling
                for barrier in barriers {
                    if barrier.barrierType == .platform {
                        let platformRect = CGRect(x: barrier.position.x, y: barrier.position.y,
                                                width: barrier.size.width, height: barrier.size.height)
                        let playerRect = CGRect(x: player.position.x - 15, y: player.position.y - 25,
                                              width: 30, height: 50)
                        
                        if platformRect.intersects(playerRect) && player.velocity.dy > 0 {
                            player.position.y = barrier.position.y - 25
                            player.isJumping = false
                            player.velocity = .zero
                            break
                        }
                    }
                }
            }
        }
        
        // Update portal positions
        updatePortalPositions(deltaTime: deltaTime)
    }
    
    private func updatePortalPositions(deltaTime: TimeInterval) {
        if var bluePortal = player.activePortals.blue {
            bluePortal.position.x -= world.gameSpeed * CGFloat(deltaTime) * 60
            player.activePortals.blue = bluePortal.isActive ? bluePortal : nil
        }
        
        if var orangePortal = player.activePortals.orange {
            orangePortal.position.x -= world.gameSpeed * CGFloat(deltaTime) * 60
            player.activePortals.orange = orangePortal.isActive ? orangePortal : nil
        }
    }
    
    private func moveBarriers(deltaTime: TimeInterval) {
        barriers = barriers.map { barrier in
            var updatedBarrier = barrier
            updatedBarrier.position.x -= world.gameSpeed * CGFloat(deltaTime) * 60
            
            // Animate moving walls
            if barrier.barrierType == .movingWall {
                updatedBarrier.position.y += sin(world.distance * 0.02) * 1.5
            }
            
            return updatedBarrier
        }
    }
    
    private func updatePortalSystem() {
        // Check portal entry
        if let bluePortal = player.activePortals.blue, bluePortal.isActive {
            let portalDistance = abs(player.position.x - bluePortal.position.x)
            if portalDistance < 30 {
                teleportThroughPortal()
            }
        }
    }
    
    private func generateBarrier() {
        let allowedTypes = currentLevelConfig.allowedBarriers
        let barrierType = allowedTypes.randomElement() ?? .wall
        let position = CGPoint(x: lastBarrierPosition, y: getBarrierHeight(for: barrierType))
        let size = getBarrierSize(for: barrierType)
        let barrier = Barrier(position: position, size: size, barrierType: barrierType)
        
        barriers.append(barrier)
        
        // Dynamic spacing based on game speed
        let minDistance: CGFloat = 250
        let maxDistance: CGFloat = 400
        let speedFactor = world.gameSpeed / 6.0
        let dynamicSpacing = minDistance + (maxDistance - minDistance) * (1 - speedFactor)
        
        lastBarrierPosition += CGFloat.random(in: dynamicSpacing...dynamicSpacing + 50)
    }
    
    private func getBarrierHeight(for type: Barrier.BarrierType) -> CGFloat {
        switch type {
        case .wall, .movingWall:
            return floorLevel - 60
        case .pit, .laserGate:
            return floorLevel
        case .platform:
            return floorLevel - 80
        }
    }
    
    private func getBarrierSize(for type: Barrier.BarrierType) -> CGSize {
        switch type {
        case .wall:
            return CGSize(width: 30, height: 60)
        case .pit:
            return CGSize(width: 80, height: 20)
        case .movingWall:
            return CGSize(width: 35, height: 50)
        case .laserGate:
            return CGSize(width: 40, height: 100)
        case .platform:
            return CGSize(width: 60, height: 15)
        }
    }
    
    private func checkCollisions() {
        guard !player.invincible else { return }
        
        for barrier in barriers {
            let barrierBox = CGRect(x: barrier.position.x, y: barrier.position.y,
                                  width: barrier.size.width, height: barrier.size.height)
            let playerBox = CGRect(x: player.position.x - 15, y: player.position.y - 25,
                                 width: 30, height: 50)
            
            if barrierBox.intersects(playerBox) {
                handleBarrierCollision(barrier)
                break
            }
        }
    }
    
    private func handleBarrierCollision(_ barrier: Barrier) {
        switch barrier.barrierType {
        case .wall, .movingWall, .laserGate:
            takeDamage()
        case .pit:
            // Only take damage if not jumping over it
            if !player.isJumping || player.position.y > floorLevel - 50 {
                takeDamage()
            }
        case .platform:
            // Platforms are safe, do nothing
            break
        }
    }
    
    private func takeDamage() {
        guard !player.invincible else { return }
        
        player.lives -= 1
        player.invincible = true
        
        // Brief invincibility period
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.player.invincible = false
        }
        
        if player.lives <= 0 {
            endGameSession()
        }
    }
    
    // MARK: - Player Actions
    func performJump() {
        guard world.isPlaying && !player.isJumping else { return }
        
        player.isJumping = true
        player.velocity.dy = jumpStrength
    }
    
    func firePortalGun() {
        guard world.isPlaying && player.portalGunCharges > 0 && !world.portalCooldown else { return }
        
        if let targetBarrier = findPortalTarget() {
            createPortalPair(near: targetBarrier)
            player.portalGunCharges -= 1
            world.portalCooldown = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.world.portalCooldown = false
            }
        }
    }
    
    private func findPortalTarget() -> Barrier? {
        return barriers
            .filter { $0.position.x > player.position.x + 200 && $0.position.x < screenBounds.width }
            .first { $0.barrierType != .pit } // Don't allow portals on pits
    }
    
    private func createPortalPair(near barrier: Barrier) {
        let bluePortal = Portal(position: CGPoint(x: barrier.position.x - 80, y: floorLevel - 30), type: .blue)
        let orangePortal = Portal(position: CGPoint(x: barrier.position.x + 120, y: floorLevel - 30), type: .orange)
        
        player.activePortals.blue = bluePortal
        player.activePortals.orange = orangePortal
        
        // Remove portals after time
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            self.clearPortals()
        }
    }
    
    private func teleportThroughPortal() {
        guard let orangePortal = player.activePortals.orange else { return }
        
        player.position.x = orangePortal.position.x - 30
        world.score += 50 // Bonus for portal use
        clearPortals()
    }
    
    private func clearPortals() {
        player.activePortals.blue = nil
        player.activePortals.orange = nil
    }
    
    private func completeMission() {
        world.isPlaying = false
        world.missionComplete = true
        world.bestPerformance = max(world.bestPerformance, world.score)
        stopGame()
    }
    
    private func endGameSession() {
        world.isPlaying = false
        world.gameEnded = true
        world.bestPerformance = max(world.bestPerformance, world.score)
        stopGame()
    }
    
    func getSessionStats() -> (score: Int, level: Int, playTime: TimeInterval) {
        return (world.score, world.currentLevel, world.sessionPlayTime)
    }
    
    // MARK: - Level Completion Methods
    func continueToNextLevel() {
        advanceToNextLevel()
    }
}

// MARK: - Main Game View
struct PortalRunnerView: View {
    @StateObject private var engine = PortalEngine()
    @EnvironmentObject var gameData: GameDataManager
    @Environment(\.dismiss) private var goBack
    @State private var showMenu = false
    
    var body: some View {
        ZStack {
            // Dynamic background based on level
          //  CosmicBackground(levelConfig: engine.currentLevelConfig)
            
            GeometryReader { geometry in
                Image("game_background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.black.opacity(0.7), Color.black.opacity(0.5)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .ignoresSafeArea()
            }
            .ignoresSafeArea()
            
            
            ScrollView {
                VStack(spacing: 0) {
                    // Game header
                    GameHeader(engine: engine, showMenu: $showMenu)
                        .padding(.top, 100)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    // Game world
                    GameWorldView(engine: engine)
                        .frame(height: 400)
                    
                    Spacer()
                    
                    // Control panel
                    ControlPanel(engine: engine)
                        .padding(.bottom, 30)
                        .padding(.horizontal)
                }
            }
            
            // Overlay views - Centered using ZStack with alignment
            if engine.world.missionComplete {
                MissionCompleteView(engine: engine, gameData: gameData, dismiss: goBack)
            } else if engine.world.gameEnded {
                GameOverView(engine: engine, gameData: gameData, dismiss: goBack)
            } else if engine.world.levelComplete {
                LevelCompleteView(engine: engine, levelName: engine.world.completedLevelName)
            }
            
            if showMenu {
                GamePauseView(engine: engine, gameData: gameData, isVisible: $showMenu, dismiss: goBack)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            engine.launchGame()
        }
    }
}

// MARK: - Level Complete View
struct LevelCompleteView: View {
    @ObservedObject var engine: PortalEngine
    let levelName: String
    @State private var showContent = false
    @State private var confetti = false
    @State private var countdown = 3
    
    var body: some View {
        ZStack {
            // Dark overlay with blur
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
            
            // Confetti effects
            if confetti {
                ForEach(0..<30, id: \.self) { index in
                    ConfettiPiece(index: index)
                }
            }
            
            // Centered container
            GeometryReader { geometry in
                VStack(spacing: 30) {
                    // Header with icon
                    VStack(spacing: 15) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                            .scaleEffect(showContent ? 1.0 : 1.2)
                        
                        Text("LEVEL COMPLETE!")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .shadow(color: .black, radius: 10)
                        
                        Text(levelName)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(engine.currentLevelConfig.themeColor)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0 : 20)
                    
                    if showContent {
                        VStack(spacing: 20) {
                            // Next level info
                            VStack(spacing: 10) {
                                Text("Next Dimension")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                
                                if engine.world.currentLevel < 4 {
                                    Text("Dimension \(engine.world.currentLevel + 1)")
                                        .font(.system(size: 28, weight: .heavy, design: .monospaced))
                                        .foregroundColor(.green)
                                        .shadow(color: .blue, radius: 5)
                                } else {
                                    Text("Final Dimension")
                                        .font(.system(size: 28, weight: .heavy, design: .monospaced))
                                        .foregroundColor(.orange)
                                        .shadow(color: .red, radius: 5)
                                }
                            }
                            
                            // Progress indicator
                            VStack(spacing: 8) {
                                Text("Portal Progress")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                HStack {
                                    ForEach(1...4, id: \.self) { level in
                                        Circle()
                                            .fill(level <= engine.world.currentLevel ? engine.currentLevelConfig.themeColor : Color.gray.opacity(0.3))
                                            .frame(width: 12, height: 12)
                                    }
                                }
                            }
                            
                            // Countdown to next level
                            VStack(spacing: 8) {
                                Text("Next level in:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("\(countdown)")
                                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                                    .foregroundColor(.yellow)
                                    .scaleEffect(countdown == 0 ? 1.5 : 1.0)
                            }
                        }
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.black.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(LinearGradient(
                                    gradient: Gradient(colors: [.yellow, .orange, .red]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ), lineWidth: 4)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                )
                .padding(30)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showContent = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 1.5)) {
                    confetti = true
                }
            }
            
            // Start countdown
            startCountdown()
        }
    }
    
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 0 {
                countdown -= 1
            } else {
                timer.invalidate()
                // Auto-advance to next level when countdown reaches 0
                engine.continueToNextLevel()
            }
        }
    }
}

// MARK: - Cosmic Background
struct CosmicBackground: View {
    let levelConfig: GameLevel
    @State private var starOffset: CGFloat = 0
    @State private var pulsePhase: Double = 0
    
    var body: some View {
        ZStack {
            // Dynamic gradient based on level
            LinearGradient(
                gradient: Gradient(colors: levelConfig.backgroundGradient),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Animated stars
            ForEach(0..<60, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.3...0.9)))
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .offset(x: starOffset + CGFloat(index) * 5)
            }
            
            // Pulsing nebula effect
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            levelConfig.themeColor.opacity(0.3),
                            levelConfig.themeColor.opacity(0.1),
                            .clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: -100, y: -150)
                .scaleEffect(1 + pulsePhase * 0.2)
            
            // Secondary nebula
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            .cyan.opacity(0.2),
                            .blue.opacity(0.1),
                            .clear
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .frame(width: 300, height: 300)
                .offset(x: 200, y: 200)
                .scaleEffect(1 + pulsePhase * 0.1)
        }
        .onAppear {
            withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
                starOffset = -UIScreen.main.bounds.width
            }
            
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                pulsePhase = 1.0
            }
        }
    }
}

// MARK: - Game Header
struct GameHeader: View {
    @ObservedObject var engine: PortalEngine
    @Binding var showMenu: Bool
    
    var body: some View {
        HStack {
            // Lives display
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: index < engine.player.lives ? "heart.fill" : "heart")
                        .foregroundColor(index < engine.player.lives ? .red : .gray)
                        .font(.system(size: 16))
                }
            }
            .padding(8)
            .background(Color.black.opacity(0.5))
            .cornerRadius(10)
            
            Spacer()
            
            // Level and score info
            VStack(spacing: 4) {
                Text("DIMENSION \(engine.world.currentLevel)")
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(engine.currentLevelConfig.themeColor)
                
                Text("\(engine.world.score)")
                    .font(.system(size: 24, weight: .heavy, design: .monospaced))
                    .foregroundColor(.white)
                    .shadow(color: .blue, radius: 5)
                
                // Level progress bar
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(engine.currentLevelConfig.themeColor)
                        .frame(width: 100 * engine.world.levelProgress, height: 4)
                }
                .frame(width: 100)
                .cornerRadius(2)
            }
            
            Spacer()
            
            // Menu and controls
            HStack(spacing: 12) {
                Button(action: {
                    showMenu = true
                    engine.stopGame()
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                
                Button(action: {
                    engine.launchGame()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
            }
        }
    }
}

// MARK: - Game World View
struct GameWorldView: View {
    @ObservedObject var engine: PortalEngine
    
    var body: some View {
        ZStack {
            // Game floor with level-themed color
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            engine.currentLevelConfig.themeColor.opacity(0.8),
                            engine.currentLevelConfig.themeColor.opacity(0.4)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 100)
                .offset(y: 150)
            
            // Player character with invincibility effect
            PlayerCharacter(player: engine.player, levelConfig: engine.currentLevelConfig)
                .position(engine.player.position)
                .opacity(engine.player.invincible ? 0.5 : 1.0)
            
            // Barriers
            ForEach(engine.barriers) { barrier in
                BarrierView(barrier: barrier, levelConfig: engine.currentLevelConfig)
                    .position(barrier.position)
            }
            
            // Portals
            if let bluePortal = engine.player.activePortals.blue {
                PortalView(portal: bluePortal)
                    .position(bluePortal.position)
            }
            
            if let orangePortal = engine.player.activePortals.orange {
                PortalView(portal: orangePortal)
                    .position(orangePortal.position)
            }
        }
    }
}

// MARK: - Player Character
struct PlayerCharacter: View {
    let player: PortalPlayer
    let levelConfig: GameLevel
    @State private var runOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Character body with level-themed colors
            VStack(spacing: 0) {
                // Head with helmet
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 22, height: 22)
                    
                    // Helmet visor
                    Rectangle()
                        .fill(levelConfig.themeColor)
                        .frame(width: 16, height: 8)
                        .offset(y: 2)
                }
                
                // Body with running animation
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [levelConfig.themeColor, levelConfig.themeColor.opacity(0.8)]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 26, height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                    .offset(x: runOffset)
            }
            .offset(y: player.isJumping ? -40 : 0)
            .scaleEffect(player.isJumping ? 0.9 : 1.0)
            
            // Portal gun
            if player.portalGunCharges > 0 {
                Circle()
                    .fill(Color.blue.opacity(0.4))
                    .frame(width: 6, height: 6)
                    .offset(x: 18, y: 8)
                    .blur(radius: 2)
            }
            
            // Invincibility effect
            if player.invincible {
                Circle()
                    .stroke(Color.yellow, lineWidth: 2)
                    .frame(width: 40, height: 40)
                    .blur(radius: 1)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                runOffset = player.isRunning ? 2 : 0
            }
        }
    }
}

// MARK: - Barrier View
struct BarrierView: View {
    let barrier: Barrier
    let levelConfig: GameLevel
    @State private var laserPhase: Double = 0
    @State private var bounceOffset: CGFloat = 0
    
    var body: some View {
        Group {
            switch barrier.barrierType {
            case .wall:
                RoundedRectangle(cornerRadius: 6)
                    .fill(barrier.barrierType.color)
                    .frame(width: barrier.size.width, height: barrier.size.height)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(levelConfig.themeColor, lineWidth: 2)
                    )
                
            case .pit:
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(barrier.barrierType.color)
                        .frame(width: barrier.size.width, height: barrier.size.height)
                    
                    // Animated void effect
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.purple.opacity(0.3))
                            .frame(width: 20, height: 20)
                            .offset(
                                x: CGFloat.random(in: -30...30),
                                y: sin(laserPhase + Double(index)) * 5
                            )
                    }
                }
                
            case .movingWall:
                RoundedRectangle(cornerRadius: 6)
                    .fill(barrier.barrierType.color)
                    .frame(width: barrier.size.width, height: barrier.size.height)
                    .overlay(
                        Circle()
                            .fill(Color.pink)
                            .frame(width: 14, height: 14)
                            .offset(y: -20)
                    )
                    .offset(y: bounceOffset)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            bounceOffset = -10
                        }
                    }
                
            case .laserGate:
                ZStack {
                    Rectangle()
                        .fill(barrier.barrierType.color.opacity(0.3))
                        .frame(width: barrier.size.width, height: barrier.size.height)
                    
                    // Animated laser beams
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.red, .yellow, .red]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 3, height: barrier.size.height)
                            .offset(x: CGFloat(index) * 12 - 12)
                            .opacity(0.7 + laserPhase * 0.3)
                    }
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                        laserPhase = 1.0
                    }
                }
                
            case .platform:
                RoundedRectangle(cornerRadius: 4)
                    .fill(barrier.barrierType.color)
                    .frame(width: barrier.size.width, height: barrier.size.height)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.green, lineWidth: 1)
                    )
            }
        }
    }
}

// MARK: - Portal View
struct PortalView: View {
    let portal: Portal
    @State private var rotation: Double = 0
    @State private var pulse: Double = 0
    @State private var sparkle: Double = 0
    
    var body: some View {
        ZStack {
            // Outer portal ring with rotation
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [portal.type.color, portal.type.accentColor]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 8
                )
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(rotation))
            
            // Middle ring
            Circle()
                .stroke(portal.type.accentColor.opacity(0.6), lineWidth: 4)
                .frame(width: 45, height: 45)
                .rotationEffect(.degrees(-rotation * 0.7))
            
            // Inner energy field
            Circle()
                .fill(portal.type.color.opacity(0.3))
                .frame(width: 35, height: 35)
                .scaleEffect(1 + pulse * 0.4)
            
            // Portal core
            Circle()
                .fill(portal.type.color.opacity(0.8))
                .frame(width: 25, height: 25)
                .blur(radius: 3)
            
            // Sparkle effects
            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(portal.type.accentColor)
                    .frame(width: 4, height: 4)
                    .offset(x: 30 * cos(Double(index) * .pi / 2 + sparkle),
                           y: 30 * sin(Double(index) * .pi / 2 + sparkle))
                    .opacity(0.8)
            }
            
            // Direction indicator
            Text(portal.type == .blue ? "IN" : "OUT")
                .font(.system(size: 10, weight: .black))
                .foregroundColor(.white)
        }
        .onAppear {
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulse = 1.0
            }
            
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                sparkle = .pi * 2
            }
        }
    }
}

// MARK: - Control Panel
struct ControlPanel: View {
    @ObservedObject var engine: PortalEngine
    @State private var jumpPressed = false
    @State private var portalPressed = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Level info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(engine.currentLevelConfig.levelName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(engine.currentLevelConfig.themeColor)
                    
                    Text("Portal Speed: \(String(format: "%.1f", engine.world.gameSpeed))x")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Portal charges display
                VStack(spacing: 4) {
                    HStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { charge in
                            Circle()
                                .fill(charge < engine.player.portalGunCharges ? Color.blue : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Text("PORTAL ENERGY")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 8)
            
            // Action buttons
            HStack(spacing: 50) {
                ActionButton(
                    icon: "arrow.up",
                    color: .green,
                    label: "LEAP",
                    isPressed: $jumpPressed,
                    action: { engine.performJump() }
                )
                
                ActionButton(
                    icon: "circle.circle.fill",
                    color: .blue,
                    label: "PORTAL",
                    isPressed: $portalPressed,
                    action: { engine.firePortalGun() }
                )
                .disabled(engine.player.portalGunCharges == 0 || engine.world.portalCooldown)
                .opacity((engine.player.portalGunCharges == 0 || engine.world.portalCooldown) ? 0.5 : 1.0)
            }
            
            // Status display
            if engine.world.portalCooldown {
                Text("Portal Recharging...")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.blue)
                    .transition(.scale)
            }
        }
    }
}

struct ActionButton: View {
    let icon: String
    let color: Color
    let label: String
    @Binding var isPressed: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            isPressed = true
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                
                Text(label)
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 80)
            .background(color)
            .clipShape(Circle())
            .shadow(color: color.opacity(0.6), radius: isPressed ? 5 : 10, y: isPressed ? 2 : 5)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
}

// MARK: - Redesigned Mission Complete View with ScrollView - CENTERED
struct MissionCompleteView: View {
    @ObservedObject var engine: PortalEngine
    @ObservedObject var gameData: GameDataManager
    let dismiss: DismissAction
    @State private var showStats = false
    @State private var confetti = false
    
    var body: some View {
        ZStack {
            // Dark overlay with blur
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
            
            // Confetti effects
            if confetti {
                ForEach(0..<50, id: \.self) { index in
                    ConfettiPiece(index: index)
                }
            }
            
            // Centered container
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 30) {
                        // Header with icon
                        VStack(spacing: 15) {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.yellow)
                                .scaleEffect(showStats ? 1.0 : 1.2)
                            
                            Text("Portal VICTORY!")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .shadow(color: .black, radius: 10)
                            
                            Text("All Dimensions Conquered")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.green)
                        }
                        
                        if showStats {
                            VStack(spacing: 25) {
                                // Score highlight
                                VStack(spacing: 10) {
                                    Text("Cosmic Performance")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                    
                                    Text("\(engine.world.score)")
                                        .font(.system(size: 52, weight: .heavy, design: .monospaced))
                                        .foregroundColor(.yellow)
                                        .shadow(color: .orange, radius: 5)
                                }
                                
                                // Stats grid
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                    StatCard(title: "Dimensions Mastered", value: "\(engine.world.currentLevel)", color: .blue, icon: "chart.line.uptrend.xyaxis")
                                    StatCard(title: "Portal Reach", value: "\(Int(engine.world.distance))m", color: .green, icon: "point.fill.topleft.down.curvedto.point.fill.bottomright.up")
                                    StatCard(title: "Best Performance", value: "\(engine.world.bestPerformance)", color: .purple, icon: "crown.fill")
                                    StatCard(title: "Portal Activations", value: "\(3 - engine.player.portalGunCharges)", color: .orange, icon: "circle.circle.fill")
                                }
                                .padding(.horizontal)
                            }
                            .transition(.opacity.combined(with: .scale))
                            
                            // Action buttons
                            VStack(spacing: 12) {
                                Button(action: {
                                    let stats = engine.getSessionStats()
                                    gameData.updateStats(score: stats.score, level: stats.level, playTime: stats.playTime)
                                    engine.resetGame()
                                    engine.launchGame()
                                }) {
                                    HStack {
                                        Image(systemName: "play.fill")
                                        Text("New Portal Journey")
                                    }
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(15)
                                    .shadow(color: .green.opacity(0.5), radius: 10, y: 5)
                                }
                                
                                Button(action: {
                                    let stats = engine.getSessionStats()
                                    gameData.updateStats(score: stats.score, level: stats.level, playTime: stats.playTime)
                                    dismiss()
                                }) {
                                    HStack {
                                        Image(systemName: "house.fill")
                                        Text("Menu")
                                    }
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(15)
                                    .shadow(color: .blue.opacity(0.5), radius: 10, y: 5)
                                }
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.black.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(LinearGradient(
                                        gradient: Gradient(colors: [.yellow, .orange, .red]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ), lineWidth: 4)
                            )
                            .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                    )
                    .padding(30)
                    .frame(minHeight: geometry.size.height)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showStats = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeOut(duration: 1.5)) {
                    confetti = true
                }
            }
        }
    }
}

// MARK: - Redesigned Game Over View with ScrollView - CENTERED
struct GameOverView: View {
    @ObservedObject var engine: PortalEngine
    @ObservedObject var gameData: GameDataManager
    let dismiss: DismissAction
    @State private var showStats = false
    
    var body: some View {
        ZStack {
            // Dark red overlay
            LinearGradient(
                gradient: Gradient(colors: [Color.red.opacity(0.8), Color.black.opacity(0.9)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Centered container
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 30) {
                        // Header with icon
                        VStack(spacing: 15) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.red)
                            
                            Text("PORTAL SETBACK")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .shadow(color: .black, radius: 10)
                            
                            Text("Dimensions await your return")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        if showStats {
                            VStack(spacing: 25) {
                                // Score highlight
                                VStack(spacing: 10) {
                                    Text("Portal Achievement")
                                        .font(.title3)
                                        .foregroundColor(.green)
                                    
                                    Text("\(engine.world.score)")
                                        .font(.system(size: 48, weight: .heavy, design: .monospaced))
                                        .foregroundColor(.orange)
                                        .shadow(color: .red, radius: 5)
                                }
                                
                                // Stats
                                VStack(spacing: 12) {
                                    HStack {
                                        Image(systemName: "chart.line.uptrend.xyaxis")
                                            .foregroundColor(.blue)
                                        Text("Dimensions Reached:")
                                        Spacer()
                                        Text("\(engine.world.currentLevel)")
                                            .fontWeight(.bold)
                                    }
                                    
                                    HStack {
                                        Image(systemName: "point.fill.topleft.down.curvedto.point.fill.bottomright.up")
                                            .foregroundColor(.green)
                                        Text("Portal Reach:")
                                        Spacer()
                                        Text("\(Int(engine.world.distance))m")
                                            .fontWeight(.bold)
                                    }
                                    
                                    HStack {
                                        Image(systemName: "crown.fill")
                                            .foregroundColor(.yellow)
                                        Text("Best Performance:")
                                        Spacer()
                                        Text("\(engine.world.bestPerformance)")
                                            .fontWeight(.bold)
                                    }
                                }
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(12)
                            }
                            .transition(.opacity.combined(with: .scale))
                            
                            // Action buttons
                            VStack(spacing: 12) {
                                Button(action: {
                                    let stats = engine.getSessionStats()
                                    gameData.updateStats(score: stats.score, level: stats.level, playTime: stats.playTime)
                                    engine.resetGame()
                                    engine.launchGame()
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Reattempt Journey")
                                    }
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .cornerRadius(15)
                                    .shadow(color: .orange.opacity(0.5), radius: 10, y: 5)
                                }
                                
                                Button(action: {
                                    let stats = engine.getSessionStats()
                                    gameData.updateStats(score: stats.score, level: stats.level, playTime: stats.playTime)
                                    dismiss()
                                }) {
                                    HStack {
                                        Image(systemName: "house.fill")
                                        Text("Menu")
                                    }
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(15)
                                    .shadow(color: .blue.opacity(0.5), radius: 10, y: 5)
                                }
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.black.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(LinearGradient(
                                        gradient: Gradient(colors: [.red, .orange, .yellow]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ), lineWidth: 4)
                            )
                            .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                    )
                    .padding(30)
                    .frame(minHeight: geometry.size.height)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showStats = true
                }
            }
        }
    }
}

// MARK: - Redesigned Game Pause View with ScrollView - CENTERED
struct GamePauseView: View {
    @ObservedObject var engine: PortalEngine
    @ObservedObject var gameData: GameDataManager
    @Binding var isVisible: Bool
    let dismiss: DismissAction
    @State private var showOptions = false
    
    var body: some View {
        ZStack {

            LinearGradient(
                gradient: Gradient(colors: [Color.red.opacity(0.8), Color.black.opacity(0.9)]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Centered container
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 10) {
                            Image(systemName: "pause.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                            
                            Text("PORTAL PAUSE")
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 5)
                        }
                        
                        if showOptions {
                            VStack(spacing: 20) {
                                // Current mission info
                                VStack(spacing: 8) {
                                    Text("Active Dimension")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.black)
                                    
                                    Text(engine.currentLevelConfig.levelName)
                                        .font(.system(size: 22, weight: .black))
                                        .foregroundColor(engine.currentLevelConfig.themeColor)
                                }
                                
                                // Quick stats
                                VStack(spacing: 10) {
                                    StatRow(title: "Portal Score", value: "\(engine.world.score)", color: .white)
                                    StatRow(title: "Dimension", value: "\(engine.world.currentLevel)", color: .white)
                                    StatRow(title: "Portal Energy", value: "\(engine.player.lives)", color: .white)
                                    StatRow(title: "Portal Charges", value: "\(engine.player.portalGunCharges)", color: .white)
                                }
                                .padding()
                                .background(Color.black.opacity(0.3))
                                .cornerRadius(15)
                                
                                // Action buttons
                                VStack(spacing: 12) {
                                    Button(action: {
                                        isVisible = false
                                        engine.continueGame()
                                    }) {
                                        HStack {
                                            Image(systemName: "play.fill")
                                            Text("Resume Journey")
                                        }
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .cornerRadius(12)
                                        .shadow(color: .green.opacity(0.5), radius: 8, y: 4)
                                    }
                                    
                                    Button(action: {
                                        let stats = engine.getSessionStats()
                                        gameData.updateStats(score: stats.score, level: stats.level, playTime: stats.playTime)
                                        isVisible = false
                                        engine.resetGame()
                                        engine.launchGame()
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.clockwise")
                                            Text("Restart Dimension")
                                        }
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.orange)
                                        .cornerRadius(12)
                                        .shadow(color: .orange.opacity(0.5), radius: 8, y: 4)
                                    }
                                    
                                    Button(action: {
                                        let stats = engine.getSessionStats()
                                        gameData.updateStats(score: stats.score, level: stats.level, playTime: stats.playTime)
                                        dismiss()
                                    }) {
                                        HStack {
                                            Image(systemName: "house.fill")
                                            Text("Menu")
                                        }
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red)
                                        .cornerRadius(12)
                                        .shadow(color: .red.opacity(0.5), radius: 8, y: 4)
                                    }
                                }
                            }
                            .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.black.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(LinearGradient(
                                        gradient: Gradient(colors: [.blue, .purple, .cyan]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ), lineWidth: 4)
                            )
                            .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
                    )
                    .padding(30)
                    .frame(minHeight: geometry.size.height)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showOptions = true
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct ConfettiPiece: View {
    let index: Int
    @State private var yOffset: CGFloat = -100
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1
    
    private let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink]
    private let shapes: [AnyView] = [
        AnyView(Circle().frame(width: 8, height: 8)),
        AnyView(Rectangle().frame(width: 6, height: 12)),
        AnyView(RoundedRectangle(cornerRadius: 2).frame(width: 10, height: 6))
    ]
    
    var body: some View {
        shapes.randomElement()!
            .foregroundColor(colors.randomElement()!)
            .offset(x: xOffset, y: yOffset)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: Double.random(in: 1.5...3.0))) {
                    yOffset = UIScreen.main.bounds.height + 100
                    xOffset = CGFloat.random(in: -200...200)
                    rotation = Double.random(in: 0...720)
                }
                
                withAnimation(.easeIn(duration: 1.0).delay(1.0)) {
                    opacity = 0
                }
            }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

struct StatRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(color.opacity(0.9))
                .font(.system(size: 16, weight: .medium))
            
            Spacer()
            
            Text(value)
                .foregroundColor(color)
                .font(.system(size: 16, weight: .bold))
        }
    }
}

