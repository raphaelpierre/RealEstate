import SwiftUI
import AVKit

class VideoPlayerCoordinator: NSObject {
    var player: AVPlayer?
    var onVideoReady: () -> Void
    
    init(onVideoReady: @escaping () -> Void) {
        self.onVideoReady = onVideoReady
        super.init()
    }
    
    func setupVideo(url: URL, muteAudio: Bool) {
        // Create player
        player = AVPlayer(url: url)
        
        // Mute audio if needed
        if muteAudio {
            player?.volume = 0
        }
        
        // Add observer for when video ends
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleVideoEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
        
        // Wait for the player item to be ready before playing
        if let playerItem = player?.currentItem {
            playerItem.addObserver(self, forKeyPath: "status", options: [.new, .old], context: nil)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status",
           let playerItem = object as? AVPlayerItem {
            if playerItem.status == .readyToPlay {
                // Remove the observer
                playerItem.removeObserver(self, forKeyPath: "status")
                // Ensure video starts from the beginning
                player?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
                // Play the video
                player?.play()
                onVideoReady()
            }
        }
    }
    
    @objc private func handleVideoEnd() {
        // Handle video end if needed
    }
    
    deinit {
        // Clean up observers
        if let playerItem = player?.currentItem {
            playerItem.removeObserver(self, forKeyPath: "status")
        }
        NotificationCenter.default.removeObserver(self)
    }
}

struct VideoSplashView: View {
    @State private var isVideoFinished = false
    @State private var coordinator: VideoPlayerCoordinator?
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var currencyManager: CurrencyManager
    
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
                    .environmentObject(localizationManager)
                    .environmentObject(currencyManager)
                    .transition(.opacity)
            } else {
                if let url = videoURL {
                    ZStack {
                        Color.black.edgesIgnoringSafeArea(.all)
                        
                        VideoPlayer(player: coordinator?.player)
                            .edgesIgnoringSafeArea(.all)
                            .disabled(true) // Disable user interaction with the video
                            .onAppear {
                                setupVideo(url: url)
                            }
                            .onDisappear {
                                // Clean up when view disappears
                                coordinator?.player?.pause()
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
        // Create coordinator if needed
        if coordinator == nil {
            coordinator = VideoPlayerCoordinator {
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
            }
        }
        
        // Setup video
        coordinator?.setupVideo(url: url, muteAudio: muteAudio)
    }
}

struct VideoSplashView_Previews: PreviewProvider {
    static var previews: some View {
        VideoSplashView()
            .environmentObject(AuthManager.shared)
            .environmentObject(FirebaseManager.shared)
            .environmentObject(LocalizationManager.shared)
            .environmentObject(CurrencyManager.shared)
    }
} 