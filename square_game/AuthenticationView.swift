import SwiftUI
import FirebaseAuth

// MARK: - Authentication View
struct AuthenticationView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
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
                            }
                            
                            // Email
                            TextField("Email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .padding(.horizontal)
                            
                            // Password
                            SecureField("Password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                            
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
        
        Task {
            do {
                if isLoginMode {
                    try await firebaseManager.signIn(email: email, password: password)
                } else {
                    try await firebaseManager.registerUser(
                        email: email,
                        password: password,
                        username: username,
                        country: country
                    )
                }
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
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
