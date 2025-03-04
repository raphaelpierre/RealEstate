import SwiftUI
import AVKit

struct VideoSplashView: View {
    @State private var isVideoFinished = false
    @State private var player: AVPlayer?
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var firebaseManager: FirebaseManager
    
    // Configuration options
    private let videoName = "splash_video" // Name of your video file without extension
    private let videoExtension = "mp4"
    private let loopVideo = false // Set to true if you want the video to loop
    private let maxDuration: Double = 5.0 // Maximum duration to show video (in seconds)
    private let muteAudio = true // Set to false if you want audio
    
    // Get the URL of the video in the app bundle
    private var videoURL: URL? {
        Bundle.main.url(forResource: videoName, withExtension: videoExtension)
    }
    
    var body: some View {
        ZStack {
            if isVideoFinished {
                ContentView()
                    .transition(.opacity)
            } else {
                if let url = videoURL {
                    ZStack {
                        Color.black.edgesIgnoringSafeArea(.all)
                        
                        VideoPlayer(player: player)
                            .edgesIgnoringSafeArea(.all)
                            .disabled(true) // Disable user interaction with the video
                            .onAppear {
                                setupVideo(url: url)
                            }
                            .onDisappear {
                                // Clean up when view disappears
                                player?.pause()
                                NotificationCenter.default.removeObserver(self)
                            }
                        
                        // Optional: Add a skip button
                        VStack {
                            Spacer()
                            Button("Skip") {
                                withAnimation {
                                    isVideoFinished = true
                                }
                            }
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(8)
                            .padding(.bottom, 20)
                        }
                    }
                } else {
                    // Fallback if video can't be loaded
                    SplashScreenView()
                }
            }
        }
        .animation(.easeInOut, value: isVideoFinished)
    }
    
    private func setupVideo(url: URL) {
        // Create player
        player = AVPlayer(url: url)
        
        // Mute audio if needed
        if muteAudio {
            player?.volume = 0
        }
        
        // Add observer for when video ends
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main) { _ in
                handleVideoEnd()
            }
        
        // Set up a timer for maximum duration
        if maxDuration > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + maxDuration) {
                if !isVideoFinished {
                    withAnimation {
                        isVideoFinished = true
                    }
                }
            }
        }
        
        // Play the video
        player?.play()
    }
    
    private func handleVideoEnd() {
        if loopVideo {
            // Loop the video
            player?.seek(to: .zero)
            player?.play()
        } else {
            // End splash screen
            withAnimation {
                isVideoFinished = true
            }
        }
    }
}

struct VideoSplashView_Previews: PreviewProvider {
    static var previews: some View {
        VideoSplashView()
            .environmentObject(AuthManager.shared)
            .environmentObject(FirebaseManager.shared)
    }
} 