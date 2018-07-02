import Foundation
import AVKit
import XCDYouTubeKit

class KinemarYoutubePlayer {
    static let instance = KinemarYoutubePlayer()
    
    private init() {
        // This prevents others from using the default '()' initializer for this class.
    }
    
    struct YouTubeVideoQuality {
        static let hd720 = NSNumber(value: XCDYouTubeVideoQuality.HD720.rawValue)
        static let medium360 = NSNumber(value: XCDYouTubeVideoQuality.medium360.rawValue)
        static let small240 = NSNumber(value: XCDYouTubeVideoQuality.small240.rawValue)
    }
    
    func present(videoIdentifier: String) {
        let playerVC = AVPlayerViewController()
        if let topViewController = UIApplication.shared.keyWindow?.rootViewController {
            topViewController.present(playerVC, animated: true, completion: nil)
        }
        
        XCDYouTubeClient.default().getVideoWithIdentifier(videoIdentifier) { [unowned playerVC] (video: XCDYouTubeVideo?, error: Error?) in
            if let streamURLs = video?.streamURLs,
                let streamURL = (streamURLs[YouTubeVideoQuality.hd720] ?? streamURLs[YouTubeVideoQuality.medium360]) {
                playerVC.player = AVPlayer(url: streamURL)
                playerVC.player?.play()
                playerVC.allowsPictureInPicturePlayback = true
            } else {
                playerVC.dismiss(animated: true, completion: nil)
            }
        }
    }
}
