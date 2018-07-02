import UIKit

class KinemarTicketPurchase {
    static let instance = KinemarTicketPurchase()
    
    private init() {
        // This prevents others from using the default '()' initializer for this class.
    }
    
    func openDeepLinkIfAvailable(ingressoId: String) -> Bool {
        let deepLinkString = String(format: "ingressocinema://showtime/movie/%@", ingressoId)
        if let deepLinkUrl = URL(string: deepLinkString), UIApplication.shared.canOpenURL(deepLinkUrl) {
            UIApplication.shared.open(deepLinkUrl, options: [:], completionHandler: nil)
            return true
        }
        return false
    }
}
