import SwiftUI
import FirebaseAuth

// MARK: - Authentication View
struct AuthenticationView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @EnvironmentObject var accessibilityManager: AccessibilityManager
    @EnvironmentObject var analyticsManager: AnalyticsManager
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var country = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    let countries = ["USA", "UK", "Canada", "Australia", "India", "Germany", "France", "Japan", "China", "Brazil", "Sri Lanka", "Other"]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.6),
                    Color.purple.opacity(0.6),
                    Color.pink.opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Spacer()
                    
                    // Logo and Title
                    VStack(spacing: 10) {
                        Text("🧠")
                            .font(.system(size: 80))
                        
                        Text("Memory Color Match")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.top, 40)
                    
                    // Auth Form
                    VStack(spacing: 20) {
                        // Toggle between Login and Register
                        Picker("Mode", selection: $isLoginMode) {
                            Text("Login").tag(true)
                            Text("Register").tag(false)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
                        VStack(spacing: 15) {
                            // Username (Register only)
                            if !isLoginMode {
                                TextField("Username", text: $username)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                    .padding(.horizontal)
                                    .accessibilityLabel("Username")
                                    .accessibilityHint("Enter your username for registration")
                            }
                            
                            // Email
                            TextField("Email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .padding(.horizontal)
                                .accessibilityLabel("Email address")
                                .accessibilityHint("Enter your email address")
                            
                            // Password
                            SecureField("Password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                                .accessibilityLabel("Password")
                                .accessibilityHint("Enter your password")
                            
                            // Country (Register only)
                            if !isLoginMode {
                                Picker("Country", selection: $country) {
                                    Text("Select Country").tag("")
                                    ForEach(countries, id: \.self) { country in
                                        Text(country).tag(country)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .accessibilityLabel("Country selection")
                                .accessibilityValue(country.isEmpty ? "No country selected" : country)
                            }
                            
                            // Submit Button
                            Button(action: {
                                handleAuthentication()
                            }) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text(isLoginMode ? "Login" : "Register")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(isLoading || !isFormValid)
                            .padding(.horizontal)
                            .accessibilityLabel(isLoginMode ? "Login" : "Register")
                            .accessibilityHint(isLoginMode ? "Sign in with your credentials" : "Create new account")
                            
                            // Error Message
                            if showError {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.95))
                                .shadow(radius: 10)
                        )
                        .padding(.horizontal, 30)
                    }
                    
                    Spacer()
                }
            }
        }
    }
    
    var isFormValid: Bool {
        if isLoginMode {
            return !email.isEmpty && !password.isEmpty
        } else {
            return !email.isEmpty && !password.isEmpty && !username.isEmpty && !country.isEmpty
        }
    }
    
    func handleAuthentication() {
        isLoading = true
        showError = false
        errorMessage = ""
        
        accessibilityManager.playButtonTapSound()
        
        Task {
            do {
                if isLoginMode {
                    try await firebaseManager.signIn(email: email, password: password)
                    // Track login
                    analyticsManager.trackLogin(method: "email", userId: firebaseManager.currentUser?.uid)
                    analyticsManager.trackScreenView(screenName: "Main Menu", screenClass: "ContentView")
                } else {
                    try await firebaseManager.registerUser(
                        email: email,
                        password: password,
                        username: username,
                        country: country
                    )
                    // Track signup
                    analyticsManager.trackSignUp(method: "email", userId: firebaseManager.currentUser?.uid)
                    analyticsManager.updateUserProperties(country: country, level: 1, totalScore: 0)
                    analyticsManager.trackScreenView(screenName: "Main Menu", screenClass: "ContentView")
                }
                await MainActor.run {
                    isLoading = false
                    accessibilityManager.playSuccessHaptic()
                    accessibilityManager.announce(isLoginMode ? "Signed in successfully" : "Account created successfully")
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                    accessibilityManager.playErrorHaptic()
                    accessibilityManager.announce("Error: \(error.localizedDescription)")
                    analyticsManager.trackError(error: error, context: isLoginMode ? "login" : "signup")
                }
            }
        }
    }
}

// MARK: - Preview
struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(FirebaseManager.shared)
    }
}
