import SwiftUI

struct AccessibilitySettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    @AppStorage("soundEffectsEnabled") private var soundEffectsEnabled = true
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("voiceOverAnnouncements") private var voiceOverAnnouncements = true
    @AppStorage("highContrastMode") private var highContrastMode = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Form {
                    Section {
                        HStack {
                            Image(systemName: accessibilityManager.isVoiceOverRunning ? "speaker.wave.3.fill" : "speaker.slash.fill")
                                .foregroundColor(accessibilityManager.isVoiceOverRunning ? .green : .gray)
                            Text("VoiceOver")
                            Spacer()
                            Text(accessibilityManager.isVoiceOverRunning ? "On" : "Off")
                                .foregroundColor(.secondary)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("VoiceOver is \(accessibilityManager.isVoiceOverRunning ? "enabled" : "disabled")")
                        
                        HStack {
                            Image(systemName: accessibilityManager.isReduceMotionEnabled ? "tortoise.fill" : "hare.fill")
                                .foregroundColor(accessibilityManager.isReduceMotionEnabled ? .green : .gray)
                            Text("Reduce Motion")
                            Spacer()
                            Text(accessibilityManager.isReduceMotionEnabled ? "On" : "Off")
                                .foregroundColor(.secondary)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Reduce Motion is \(accessibilityManager.isReduceMotionEnabled ? "enabled" : "disabled")")
                        
                        HStack {
                            Image(systemName: accessibilityManager.isBoldTextEnabled ? "textformat.size" : "textformat")
                                .foregroundColor(accessibilityManager.isBoldTextEnabled ? .green : .gray)
                            Text("Bold Text")
                            Spacer()
                            Text(accessibilityManager.isBoldTextEnabled ? "On" : "Off")
                                .foregroundColor(.secondary)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Bold Text is \(accessibilityManager.isBoldTextEnabled ? "enabled" : "disabled")")
                    } header: {
                        Text("System Settings")
                    } footer: {
                        Text("These settings are controlled in your device's Settings app under Accessibility")
                    }
                    
                    Section {
                        Toggle(isOn: $soundEffectsEnabled) {
                            Label("Sound Effects", systemImage: "speaker.wave.2.fill")
                        }
                        .tint(.blue)
                        .accessibilityLabel("Sound effects")
                        .accessibilityValue(soundEffectsEnabled ? "enabled" : "disabled")
                        
                        Toggle(isOn: $hapticFeedbackEnabled) {
                            Label("Haptic Feedback", systemImage: "hand.tap.fill")
                        }
                        .tint(.blue)
                        .onChange(of: hapticFeedbackEnabled) { newValue in
                            if newValue {
                                accessibilityManager.playSuccessHaptic()
                            }
                        }
                        .accessibilityLabel("Haptic feedback")
                        .accessibilityValue(hapticFeedbackEnabled ? "enabled" : "disabled")
                        
                        Toggle(isOn: $voiceOverAnnouncements) {
                            Label("Game Announcements", systemImage: "megaphone.fill")
                        }
                        .tint(.blue)
                        .accessibilityLabel("Game announcements")
                        .accessibilityValue(voiceOverAnnouncements ? "enabled" : "disabled")
                        
                        Toggle(isOn: $highContrastMode) {
                            Label("High Contrast Colors", systemImage: "circle.lefthalf.filled")
                        }
                        .tint(.blue)
                        .accessibilityLabel("High contrast colors")
                        .accessibilityValue(highContrastMode ? "enabled" : "disabled")
                    } header: {
                        Text("Game Settings")
                    } footer: {
                        Text("Customize your gaming experience with sound, haptics, and visual options")
                    }
                    
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "textformat.size")
                                    .foregroundColor(.blue)
                                Text("Dynamic Type Support")
                                    .font(.headline)
                            }
                            Text("Text automatically adjusts to your preferred reading size set in Settings > Accessibility > Display & Text Size")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "hand.point.up.fill")
                                    .foregroundColor(.blue)
                                Text("Card Navigation")
                                    .font(.headline)
                            }
                            Text("Swipe left/right with VoiceOver to move between cards. Double-tap to flip.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "speaker.wave.3.fill")
                                    .foregroundColor(.blue)
                                Text("Audio Feedback")
                                    .font(.headline)
                            }
                            Text("Haptic feedback and audio cues help indicate matches, mismatches, and level completions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("Accessibility Features")
                    }
                    
                    Section {
                        Button(action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "gear")
                                    .foregroundColor(.blue)
                                Text("Open System Settings")
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .accessibilityLabel("Open system settings")
                        .accessibilityHint("Opens iOS Settings app to configure accessibility options")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("♿️ Accessibility")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        accessibilityManager.playButtonTapSound()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AccessibilitySettingsView()
        .environmentObject(AccessibilityManager.shared)
}
