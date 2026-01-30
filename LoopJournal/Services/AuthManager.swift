import Foundation
import LocalAuthentication
import Combine

/// Manager for handling biometric authentication
@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLockEnabled: Bool
    @Published var authenticationError: String?
    @Published var isAuthenticating = false
    
    static let shared = AuthManager()
    
    private let lockEnabledKey = "biometricLockEnabled"
    
    init() {
        // Load user preference from UserDefaults
        self.isLockEnabled = UserDefaults.standard.bool(forKey: lockEnabledKey)
        isAuthenticated = !self.isLockEnabled
    }
    
    /// Enable or disable app lock
    func setLockEnabled(_ enabled: Bool) {
        isLockEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: lockEnabledKey)
        
        // If disabling lock, authenticate immediately
        if !enabled {
            isAuthenticated = true
        }
    }
    
    /// Check if biometric authentication is available
    var isBiometricAvailable: Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    /// Get the type of biometric available
    var biometricType: BiometricType {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .opticID:
            return .opticID
        case .none:
            return .none
        @unknown default:
            return .none
        }
    }
    
    /// Authenticate user with biometrics or device passcode
    func authenticate() async {
        guard isLockEnabled else {
            isAuthenticated = true
            return
        }
        
        // Skip if already authenticated
        guard !isAuthenticated else { return }
        
        isAuthenticating = true
        authenticationError = nil
        
        let context = LAContext()
        var error: NSError?
        
        // Check if authentication is possible
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Try device passcode as fallback
            authenticateWithPasscode()
            return
        }
        
        let reason = "Unlock LoopJournal to access your private journal"
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            
            if success {
                isAuthenticated = true
            } else {
                authenticationError = "Authentication failed. Please try again."
            }
        } catch let authError as NSError {
            authenticationError = authError.localizedDescription
        }
        
        isAuthenticating = false
    }
    
    /// Fallback to device passcode
    private func authenticateWithPasscode() {
        let context = LAContext()
        let reason = "Enter your device passcode to unlock LoopJournal"
        
        context.evaluatePolicy(
            .deviceOwnerAuthentication,
            localizedReason: reason
        ) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.isAuthenticated = true
                } else {
                    self.authenticationError = error?.localizedDescription ?? "Authentication failed"
                }
                self.isAuthenticating = false
            }
        }
    }
    
    /// Reset authentication state (e.g., when app goes to background)
    func resetAuthentication() {
        if isLockEnabled {
            isAuthenticated = false
        }
    }
}

/// Types of biometric authentication
enum BiometricType {
    case none
    case touchID
    case faceID
    case opticID
    
    var iconName: String {
        switch self {
        case .faceID: return "faceid"
        case .touchID: return "touchid"
        case .opticID: return "opticid"
        case .none: return "lock.fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .faceID: return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        case .none: return "Passcode"
        }
    }
}

