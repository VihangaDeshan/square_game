import SwiftUI
import AVFoundation
import UIKit
import Combine

// MARK: - Accessibility Manager
@MainActor
class AccessibilityManager: ObservableObject {
    static let shared = AccessibilityManager()
    
    @Published var isVoiceOverRunning: Bool = false
    @Published var isReduceMotionEnabled: Bool = false
    @Published var isBoldTextEnabled: Bool = false
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    
    private init() {
        // Monitor accessibility settings
        updateAccessibilitySettings()
        
        // Listen for changes
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAccessibilitySettings()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAccessibilitySettings()
        }
        
        NotificationCenter.default.addObserver(
            forName: UIAccessibility.boldTextStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAccessibilitySettings()
        }
    }
    
    private func updateAccessibilitySettings() {
        isVoiceOverRunning = UIAccessibility.isVoiceOverRunning
        isReduceMotionEnabled = UIAccessibility.isReduceMotionEnabled
        isBoldTextEnabled = UIAccessibility.isBoldTextEnabled
    }
    
    // MARK: - Haptic Feedback
    func playHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func playSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    func playErrorHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    func playWarningHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    func playSelectionHaptic() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    // MARK: - VoiceOver Announcements
    func announce(_ message: String, priority: UIAccessibility.Notification = .announcement) {
        UIAccessibility.post(notification: priority, argument: message)
    }
    
    func announceScreenChange(_ message: String? = nil) {
        UIAccessibility.post(notification: .screenChanged, argument: message)
    }
    
    func announceLayoutChange(_ message: String? = nil) {
        UIAccessibility.post(notification: .layoutChanged, argument: message)
    }
    
    // MARK: - Sound Effects
    func playSound(_ soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") ?? 
                       Bundle.main.url(forResource: soundName, withExtension: "wav") else {
            // If no sound file exists, provide haptic feedback as fallback
            playHaptic(.light)
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()
            audioPlayers[soundName] = player
        } catch {
            print("Error playing sound: \(error)")
            // Fallback to haptic
            playHaptic(.light)
        }
    }
    
    func playMatchSound() {
        playSuccessHaptic()
        // You can add actual sound file here
    }
    
    func playMismatchSound() {
        playErrorHaptic()
        // You can add actual sound file here
    }
    
    func playLevelCompleteSound() {
        playSuccessHaptic()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.playSuccessHaptic()
        }
    }
    
    func playCardFlipSound() {
        playSelectionHaptic()
    }
    
    func playButtonTapSound() {
        playHaptic(.light)
    }
    
    // MARK: - Animation Helpers
    func getAnimationDuration(_ baseDuration: Double) -> Double {
        return isReduceMotionEnabled ? 0.0 : baseDuration
    }
    
    func shouldUseAnimation() -> Bool {
        return !isReduceMotionEnabled
    }
    
    // MARK: - Font Helpers
    func scaledFont(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        return .system(style).weight(weight)
    }
}

// MARK: - View Extensions for Accessibility
extension View {
    func accessibleTapGesture(action: @escaping () -> Void) -> some View {
        self.onTapGesture {
            AccessibilityManager.shared.playButtonTapSound()
            action()
        }
    }
    
    func withReduceMotion<T: View>(@ViewBuilder reduced: () -> T) -> some View {
        Group {
            if AccessibilityManager.shared.isReduceMotionEnabled {
                reduced()
            } else {
                self
            }
        }
    }
}
