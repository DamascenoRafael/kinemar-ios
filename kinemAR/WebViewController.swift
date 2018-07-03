import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var ticketURLString: String!
    
    var webView: WKWebView = {
        var webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutWebView()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        configureBackButton()
        loadPage(ticketURLString)
    }
    
    func layoutWebView() {
        view.addSubview(webView)
        webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func configureBackButton() {
        if navigationController!.viewControllers.count == 1 {
            let button = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(returnToHomeScreen(_:)))
            navigationItem.leftBarButtonItem = button
        }
    }
    
    func loadPage(_ urlString: String) {
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        webView.load(request)
    }
    
    
    // MARK: - Navigation
    
    @IBAction func returnToHomeScreen(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
