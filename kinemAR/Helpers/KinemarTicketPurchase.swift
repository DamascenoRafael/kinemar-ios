import UIKit

class KinemarTicketPurchase {
    static let instance = KinemarTicketPurchase()
    
    private init() {
        // This prevents others from using the default '()' initializer for this class.
    }
    
    func openDeepLinkIfAvailable(movieId: String) -> Bool {
        let deepLinkString = String(format: "ingressocinema://showtime/movie/%@", movieId)
        if let deepLinkUrl = URL(string: deepLinkString), UIApplication.shared.canOpenURL(deepLinkUrl) {
            UIApplication.shared.open(deepLinkUrl, options: [:], completionHandler: nil)
            return true
        }
        return false
    }
}
