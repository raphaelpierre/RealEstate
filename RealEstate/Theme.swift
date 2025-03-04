import SwiftUI

enum Theme {
    static let primaryRed = Color("PrimaryRed")
    static let primaryBlue = Color("PrimaryBlue")
    static let backgroundBlack = Color("BackgroundBlack")
    static let textWhite = Color.white
    static let cardBackground = Color("CardBackground")
    
    static let cornerRadius: CGFloat = 12
    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 8
    
    static let shadowRadius: CGFloat = 10
    static let shadowOpacity: CGFloat = 0.1
    
    struct Typography {
        static let titleLarge = Font.system(size: 28, weight: .bold)
        static let title = Font.system(size: 22, weight: .bold)
        static let heading = Font.system(size: 18, weight: .semibold)
        static let subheading = Font.system(size: 17, weight: .medium)
        static let body = Font.system(size: 16, weight: .regular)
        static let caption = Font.system(size: 14, weight: .regular)
    }
    
    struct Modifiers {
        struct CustomTextField: ViewModifier {
            func body(content: Content) -> some View {
                content
                    .padding(12)
                    .background(Theme.cardBackground)
                    .cornerRadius(Theme.cornerRadius)
                    .foregroundColor(Theme.textWhite)
            }
        }

        struct Button: ViewModifier {
            let isPrimary: Bool
            let isPressed: Bool
            
            func body(content: Content) -> some View {
                content
                    .padding()
                    .background(
                        isPrimary 
                            ? Theme.primaryRed.opacity(isPressed ? 0.8 : 1)
                            : Theme.cardBackground.opacity(0.1)
                    )
                    .foregroundColor(isPrimary ? Theme.textWhite : Theme.primaryRed)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    .scaleEffect(isPressed ? 0.98 : 1)
            }
        }
    }
}

// Custom style modifiers
extension View {
    func modernTextField() -> some View {
        modifier(Theme.Modifiers.CustomTextField())
    }
    
    func primaryButton(isPressed: Bool = false) -> some View {
        modifier(Theme.Modifiers.Button(isPrimary: true, isPressed: isPressed))
    }
    
    func secondaryButton(isPressed: Bool = false) -> some View {
        modifier(Theme.Modifiers.Button(isPrimary: false, isPressed: isPressed))
    }
}