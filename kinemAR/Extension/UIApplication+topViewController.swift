import UIKit

extension UIApplication {
    
    func topViewController() -> UIViewController {
        var topController = self.keyWindow!.rootViewController!
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
            
        return topController
    }
}
