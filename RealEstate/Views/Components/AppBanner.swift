import SwiftUI

struct AppBanner: View {
    var body: some View {
        Text("SindApp")
            .font(.system(size: 22, weight: .semibold))
            .foregroundColor(Theme.primaryRed)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Theme.backgroundBlack)
    }
}

#Preview {
    AppBanner()
} 