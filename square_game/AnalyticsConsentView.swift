import SwiftUI

struct AnalyticsConsentView: View {
    @EnvironmentObject var analyticsManager: AnalyticsManager
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    @Environment(\.dismiss) var dismiss
    
    @State private var tempConsent = AnalyticsConsent()
    @State private var acceptAll = false
    @State private var showingDetails = false
    
    var canProceed: Bool {
        return tempConsent.allowGameplayTracking || 
               tempConsent.allowPerformanceTracking || 
               tempConsent.allowCrashReporting || 
               tempConsent.allowUsageStatistics || 
               tempConsent.allowPersonalization ||
               !acceptAll // Allow proceeding even if all declined
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 15) {
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.blue)
                            
                            Text("Privacy & Data Collection")
                                .font(.title).bold()
                                .multilineTextAlignment(.center)
                            
                            Text("We value your privacy. Please choose what data you're comfortable sharing with us.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Privacy and data collection. We value your privacy. Please choose what data you're comfortable sharing.")
                        
                        // Quick Accept All
                        VStack(spacing: 12) {
                            Toggle(isOn: $acceptAll) {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(acceptAll ? .green : .gray)
                                    VStack(alignment: .leading) {
                                        Text("Accept All")
                                            .font(.headline)
                                        Text("Enable all data collection features")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .tint(.blue)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.9))
                                    .shadow(radius: 3)
                            )
                            .onChange(of: acceptAll) { newValue in
                                accessibilityManager.playSelectionHaptic()
                                if newValue {
                                    tempConsent.allowGameplayTracking = true
                                    tempConsent.allowPerformanceTracking = true
                                    tempConsent.allowCrashReporting = true
                                    tempConsent.allowUsageStatistics = true
                                    tempConsent.allowPersonalization = true
                                }
                            }
                            .accessibilityLabel("Accept all data collection")
                            .accessibilityValue(acceptAll ? "enabled" : "disabled")
                        }
                        .padding(.horizontal)
                        
                        // Individual Permissions
                        VStack(spacing: 15) {
                            Text("Choose Individual Permissions")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            // Gameplay Tracking
                            ConsentToggleRow(
                                icon: "gamecontroller.fill",
                                title: "Gameplay Tracking",
                                description: "Track your scores, levels, achievements, and game sessions",
                                examples: "• Play time\n• Scores and levels\n• Achievements unlocked\n• Game modes played",
                                isOn: $tempConsent.allowGameplayTracking,
                                color: .blue
                            )
                            .onChange(of: tempConsent.allowGameplayTracking) { _ in
                                accessibilityManager.playSelectionHaptic()
                                updateAcceptAll()
                            }
                            
                            // Performance Tracking
                            ConsentToggleRow(
                                icon: "speedometer",
                                title: "Performance Tracking",
                                description: "Monitor app performance to improve your experience",
                                examples: "• Load times\n• Memory usage\n• Frame rates\n• Response times",
                                isOn: $tempConsent.allowPerformanceTracking,
                                color: .orange
                            )
                            .onChange(of: tempConsent.allowPerformanceTracking) { _ in
                                accessibilityManager.playSelectionHaptic()
                                updateAcceptAll()
                            }
                            
                            // Crash Reporting
                            ConsentToggleRow(
                                icon: "exclamationmark.triangle.fill",
                                title: "Crash Reporting",
                                description: "Help us fix bugs by reporting crashes and errors",
                                examples: "• Crash logs\n• Error messages\n• Device information\n• App version",
                                isOn: $tempConsent.allowCrashReporting,
                                color: .red
                            )
                            .onChange(of: tempConsent.allowCrashReporting) { _ in
                                accessibilityManager.playSelectionHaptic()
                                updateAcceptAll()
                            }
                            
                            // Usage Statistics
                            ConsentToggleRow(
                                icon: "chart.bar.fill",
                                title: "Usage Statistics",
                                description: "Understand how you use the app to improve features",
                                examples: "• Feature usage\n• Session duration\n• Navigation patterns\n• Button clicks",
                                isOn: $tempConsent.allowUsageStatistics,
                                color: .green
                            )
                            .onChange(of: tempConsent.allowUsageStatistics) { _ in
                                accessibilityManager.playSelectionHaptic()
                                updateAcceptAll()
                            }
                            
                            // Personalization
                            ConsentToggleRow(
                                icon: "person.fill",
                                title: "Personalization",
                                description: "Store your preferences and user ID for a personalized experience",
                                examples: "• User ID\n• Country preference\n• Game settings\n• Leaderboard position",
                                isOn: $tempConsent.allowPersonalization,
                                color: .purple
                            )
                            .onChange(of: tempConsent.allowPersonalization) { _ in
                                accessibilityManager.playSelectionHaptic()
                                updateAcceptAll()
                            }
                        }
                        
                        // Privacy Info
                        VStack(spacing: 12) {
                            Button(action: {
                                showingDetails = true
                            }) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                    Text("Learn More About Data Collection")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.9))
                                )
                            }
                            .foregroundColor(.blue)
                            .accessibilityLabel("Learn more about data collection")
                            .accessibilityHint("Opens detailed privacy information")
                            
                            Text("Your data is encrypted and never shared with third parties. You can change these settings anytime in the app.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)
                        
                        // Action Buttons
                        VStack(spacing: 12) {
                            Button(action: {
                                accessibilityManager.playButtonTapSound()
                                analyticsManager.updateConsent(tempConsent)
                                analyticsManager.announce("Privacy settings saved")
                                dismiss()
                            }) {
                                Text("Save & Continue")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.blue.gradient)
                                    )
                            }
                            .accessibilityLabel("Save settings and continue")
                            
                            Button(action: {
                                accessibilityManager.playButtonTapSound()
                                // Decline all
                                tempConsent = AnalyticsConsent()
                                analyticsManager.updateConsent(tempConsent)
                                analyticsManager.announce("All data collection declined")
                                dismiss()
                            }) {
                                Text("Decline All & Continue")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .accessibilityLabel("Decline all data collection and continue")
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingDetails) {
                PrivacyDetailsView()
                    .environmentObject(accessibilityManager)
            }
        }
        .interactiveDismissDisabled(true) // Prevent dismissal without choice
    }
    
    private func updateAcceptAll() {
        acceptAll = tempConsent.allowGameplayTracking &&
                    tempConsent.allowPerformanceTracking &&
                    tempConsent.allowCrashReporting &&
                    tempConsent.allowUsageStatistics &&
                    tempConsent.allowPersonalization
    }
}

// MARK: - Consent Toggle Row
struct ConsentToggleRow: View {
    let icon: String
    let title: String
    let description: String
    let examples: String
    @Binding var isOn: Bool
    let color: Color
    
    @State private var showExamples = false
    
    var body: some View {
        VStack(spacing: 0) {
            Toggle(isOn: $isOn) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                        .frame(width: 35)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .tint(color)
            .padding()
            
            if showExamples {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    Text("What we collect:")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text(examples)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
                .transition(.opacity)
            }
            
            Button(action: {
                withAnimation {
                    showExamples.toggle()
                }
            }) {
                HStack {
                    Text(showExamples ? "Hide Details" : "Show Details")
                        .font(.caption)
                    Image(systemName: showExamples ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
                .foregroundColor(.blue)
                .padding(.bottom, 8)
            }
            .accessibilityLabel("\(showExamples ? "Hide" : "Show") details for \(title)")
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
                .shadow(radius: 2)
        )
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(description). \(isOn ? "Enabled" : "Disabled")")
    }
}

// MARK: - Privacy Details View
struct PrivacyDetailsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    privacySection(
                        title: "🔒 Data Security",
                        content: "All data is encrypted both in transit and at rest using industry-standard encryption. We use Firebase Analytics, a trusted Google service, for data collection."
                    )
                    
                    privacySection(
                        title: "🚫 No Third-Party Sharing",
                        content: "Your data is never sold or shared with third parties for marketing purposes. We only use it to improve your gaming experience."
                    )
                    
                    privacySection(
                        title: "👤 Anonymous by Default",
                        content: "Unless you enable personalization, all analytics are anonymous and cannot be traced back to you personally."
                    )
                    
                    privacySection(
                        title: "⏱️ Data Retention",
                        content: "Analytics data is automatically deleted after 14 months. You can request deletion of your data at any time."
                    )
                    
                    privacySection(
                        title: "✋ Your Rights",
                        content: "You can:\n• View what data we collect\n• Change your preferences anytime\n• Request data deletion\n• Opt-out of all collection"
                    )
                    
                    privacySection(
                        title: "🔄 How We Use Your Data",
                        content: "• Improve game performance\n• Fix bugs and crashes\n• Develop new features\n• Balance game difficulty\n• Enhance user experience"
                    )
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Privacy Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        accessibilityManager.playButtonTapSound()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func privacySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
                .shadow(radius: 2)
        )
    }
}

#Preview {
    AnalyticsConsentView()
        .environmentObject(AnalyticsManager.shared)
        .environmentObject(AccessibilityManager.shared)
}
