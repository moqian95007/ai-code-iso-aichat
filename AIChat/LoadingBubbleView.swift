import SwiftUI

struct LoadingBubbleView: View {
    @State private var showFirstDot = false
    @State private var showSecondDot = false
    @State private var showThirdDot = false
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(showFirstDot ? .gray : Color.gray.opacity(0.3))
            
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(showSecondDot ? .gray : Color.gray.opacity(0.3))
            
            Circle()
                .frame(width: 8, height: 8)
                .foregroundColor(showThirdDot ? .gray : Color.gray.opacity(0.3))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(20)
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        let animationDuration = 0.3
        
        withAnimation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
            showFirstDot = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            withAnimation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
                showSecondDot = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration * 2) {
            withAnimation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
                showThirdDot = true
            }
        }
    }
}

#Preview {
    LoadingBubbleView()
        .previewLayout(.sizeThatFits)
        .padding()
} 