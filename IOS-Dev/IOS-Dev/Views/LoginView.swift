import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var isSignUpMode = false
    
    // Form Inputs
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var agreeToTerms = false
    @State private var isPasswordVisible = false
    
    // Validation Feedback
    @State private var validationError: String? = nil
    
    var body: some View {
        ZStack {
            // Background Layer: Sleek Dark theme
            Color.black.ignoresSafeArea()
            
            // Grid Background consistent with PlayHub style
            GridBackground()
                .ignoresSafeArea()
            
            // Subtle Radial Glows for premium neon styling
            RadialGradient(colors: [.purple.opacity(0.15), .clear], center: .topTrailing, startRadius: 10, endRadius: 380)
                .ignoresSafeArea()
            RadialGradient(colors: [.blue.opacity(0.12), .clear], center: .bottomLeading, startRadius: 10, endRadius: 420)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    if !isSignUpMode {
                        // MARK: - SIGN IN LOBBY
                        VStack(spacing: 20) {
                            // Rounded game controller app icon
                            ZStack {
                                RoundedRectangle(cornerRadius: 22)
                                    .fill(Color(red: 22/255, green: 25/255, blue: 35/255))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22)
                                            .stroke(Color.purple.opacity(0.35), lineWidth: 1.5)
                                    )
                                    .shadow(color: .purple.opacity(0.2), radius: 10, x: 0, y: 4)
                                
                                Image(systemName: "gamecontroller.fill")
                                    .font(.system(size: 34))
                                    .foregroundColor(Color(red: 220/255, green: 180/255, blue: 255/255))
                            }
                            .padding(.top, 40)
                            
                            Text("PLAYHUB")
                                .font(.system(size: 38, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .tracking(1)
                            
                            Text("Welcome back to the arena. Sign in to continue your journey.")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white.opacity(0.65))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        
                        // Login Input Card
                        VStack(spacing: 20) {
                            CustomInputField(
                                label: "Email Address",
                                placeholder: "player@example.com",
                                text: $email,
                                iconName: "envelope"
                            )
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            
                            CustomPasswordField(
                                label: "Password",
                                placeholder: "••••••••",
                                text: $password,
                                isVisible: $isPasswordVisible,
                                isForgotPasswordEnabled: true
                            )
                            
                            if let error = validationError {
                                Text(error)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 4)
                            }
                            
                            Button(action: {
                                performLogin()
                            }) {
                                Text("Sign In")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 45/255, green: 20/255, blue: 70/255))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(Color(red: 220/255, green: 180/255, blue: 255/255))
                                    .cornerRadius(14)
                                    .shadow(color: Color(red: 220/255, green: 180/255, blue: 255/255).opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .padding(.top, 8)
                        }
                        .padding(24)
                        .background(Color(red: 18/255, green: 22/255, blue: 30/255).opacity(0.85))
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                        
                        // Switch Mode Button
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .foregroundColor(.white.opacity(0.6))
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    clearInputs()
                                    isSignUpMode = true
                                }
                            }) {
                                Text("Sign Up")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 220/255, green: 180/255, blue: 255/255))
                            }
                        }
                        .font(.system(size: 15))
                        .padding(.top, 16)
                        
                    } else {
                        // MARK: - SIGN UP LOBBY
                        VStack(spacing: 12) {
                            Text("Create Account")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.top, 60)
                            
                            Text("Join the hub and start playing")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        // Signup Input Card
                        VStack(spacing: 20) {
                            CustomInputField(
                                label: "Full Name",
                                placeholder: "Enter your full name",
                                text: $fullName,
                                iconName: "person"
                            )
                            
                            CustomInputField(
                                label: "Email Address",
                                placeholder: "player@playhub.com",
                                text: $email,
                                iconName: "envelope"
                            )
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            
                            CustomPasswordField(
                                label: "Password",
                                placeholder: "••••••••",
                                text: $password,
                                isVisible: $isPasswordVisible
                            )
                            
                            // Agree to terms checkbox
                            Toggle(isOn: $agreeToTerms) {
                                HStack(spacing: 4) {
                                    Text("I agree to the")
                                        .foregroundColor(.white.opacity(0.7))
                                    Text("Terms & Conditions")
                                        .foregroundColor(Color(red: 220/255, green: 180/255, blue: 255/255))
                                        .fontWeight(.semibold)
                                }
                                .font(.system(size: 13))
                            }
                            .toggleStyle(CheckboxToggleStyle())
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 4)
                            
                            if let error = validationError {
                                Text(error)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 4)
                            }
                            
                            Button(action: {
                                performSignUp()
                            }) {
                                Text("Create Account")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 45/255, green: 20/255, blue: 70/255))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                                    .background(Color(red: 220/255, green: 180/255, blue: 255/255))
                                    .cornerRadius(14)
                                    .shadow(color: Color(red: 220/255, green: 180/255, blue: 255/255).opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .padding(.top, 8)
                        }
                        .padding(24)
                        .background(Color(red: 18/255, green: 22/255, blue: 30/255).opacity(0.85))
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                        
                        // Switch Mode Button
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .foregroundColor(.white.opacity(0.6))
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    clearInputs()
                                    isSignUpMode = false
                                }
                            }) {
                                Text("Sign In")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 220/255, green: 180/255, blue: 255/255))
                            }
                        }
                        .font(.system(size: 15))
                        .padding(.top, 16)
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
    
    // MARK: - Auth Operations
    private func performLogin() {
        validationError = nil
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedEmail.isEmpty {
            validationError = "Please enter your email address."
            return
        }
        
        if !isValidEmail(trimmedEmail) {
            validationError = "Please enter a valid email address format."
            return
        }
        
        if trimmedPassword.isEmpty {
            validationError = "Please enter your password."
            return
        }
        
        let result = authManager.login(email: trimmedEmail, password: trimmedPassword)
        if !result.success {
            validationError = result.message
        }
    }
    
    private func performSignUp() {
        validationError = nil
        
        let trimmedName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            validationError = "Please enter your full name."
            return
        }
        
        if trimmedEmail.isEmpty {
            validationError = "Please enter your email address."
            return
        }
        
        if !isValidEmail(trimmedEmail) {
            validationError = "Please enter a valid email address format."
            return
        }
        
        if trimmedPassword.count < 6 {
            validationError = "Password must be at least 6 characters."
            return
        }
        
        if !agreeToTerms {
            validationError = "You must agree to the Terms & Conditions."
            return
        }
        
        let result = authManager.signUp(fullName: trimmedName, email: trimmedEmail, password: trimmedPassword)
        if !result.success {
            validationError = result.message
        }
    }
    
    private func clearInputs() {
        fullName = ""
        email = ""
        password = ""
        agreeToTerms = false
        validationError = nil
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}

// MARK: - Input Field Subcomponent
struct CustomInputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let iconName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
                .tracking(1.5)
            
            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .foregroundColor(.white.opacity(0.4))
                    .frame(width: 20)
                
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.25)))
                    .foregroundColor(.white)
                    .font(.system(size: 15))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.035))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
    }
}

// MARK: - Password Field Subcomponent
struct CustomPasswordField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    @Binding var isVisible: Bool
    var isForgotPasswordEnabled = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(label.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(1.5)
                
                Spacer()
                
                if isForgotPasswordEnabled {
                    Button(action: {}) {
                        Text("Forgot Password?")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 220/255, green: 180/255, blue: 255/255))
                    }
                }
            }
            
            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .foregroundColor(.white.opacity(0.4))
                    .frame(width: 20)
                
                Group {
                    if isVisible {
                        TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.25)))
                    } else {
                        SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.25)))
                    }
                }
                .foregroundColor(.white)
                .font(.system(size: 15))
                .autocapitalization(.none)
                .disableAutocorrection(true)
                
                Button(action: {
                    isVisible.toggle()
                }) {
                    Image(systemName: isVisible ? "eye.fill" : "eye.slash.fill")
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white.opacity(0.035))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
    }
}

// MARK: - Custom Checkbox Style
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack(spacing: 10) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .font(.system(size: 18))
                    .foregroundColor(configuration.isOn ? Color(red: 220/255, green: 180/255, blue: 255/255) : .white.opacity(0.3))
                
                configuration.label
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    LoginView()
}
