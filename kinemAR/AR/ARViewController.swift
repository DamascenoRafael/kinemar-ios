import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    let planeGap: Float = 0.03
    
    /// The view controller that displays the status and "restart experience" UI.
    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    /// A serial queue for thread safety when modifying the SceneKit node graph.
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".serialSceneKitQueue")
    
    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // App tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        // Hook up status view controller callback(s).
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
        
        statusViewController.showHistoryHandler = { [unowned self] in
            self.performSegue(withIdentifier: "showHistory", sender: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Start the AR experience
        resetTracking()
    }
    
    // MARK: - Session management (Image detection setup)
    
    /// Prevents restarting the session while a restart is in progress.
    var isRestartAvailable = true
    
    /// Creates a new AR configuration to run on the `session`.
    /// - Tag: ARReferenceImage-Loading
    func resetTracking() {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        let configuration = ARImageTrackingConfiguration()
        configuration.isAutoFocusEnabled = true
        configuration.trackingImages = referenceImages
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        statusViewController.scheduleMessage("Look around to detect images", inSeconds: 7.5, messageType: .contentPlacement)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    /*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {

        return ticketnNode
    }
    */
 
    
    /// MARK: ARImageAnchor-Visualizing
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        
        updateQueue.async {
            
            let movieTitle = referenceImage.name!
            node.name = movieTitle
            
            let playButton = self.playButtonNode
            
            let info = self.infoNode
            info.switchPosition(to: .insideBottomRight, imageAnchor: imageAnchor)
            
            let ticket = self.ticketNode
            ticket.switchPosition(to: .top, imageAnchor: imageAnchor)
            
            //let tomato = self.tomatoNode
            let tomato = self.badTomatoNode
            tomato.switchPosition(to: .bottomRight, imageAnchor: imageAnchor)
            
            //let popcorn = self.popcornNode
            let popcorn = self.badPopcornNode
            popcorn.switchPosition(to: .topRight, imageAnchor: imageAnchor)
            
            let imdb = self.imdbNode
            imdb.switchPosition(to: .topLeft, imageAnchor: imageAnchor)
            
            let metacritic = self.metacriticNode
            metacritic.switchPosition(to: .bottomLeft, imageAnchor: imageAnchor)
            
            node.addChildNode(imdb)
            node.addChildNode(metacritic)
            node.addChildNode(playButton)
            node.addChildNode(ticket)
            node.addChildNode(tomato)
            node.addChildNode(popcorn)
            node.addChildNode(info)
        }
        
        DispatchQueue.main.async {
            let imageName = referenceImage.name ?? ""
            self.statusViewController.cancelAllScheduledMessages()
            self.statusViewController.showMessage("Detected image “\(imageName)”")
        }
    }
    
    
    // MARK: Scene nodes
    
    func createTextNode(string: String) -> SCNNode {
        let text = SCNText(string: string, extrusionDepth: 0.1)
        text.font = UIFont.systemFont(ofSize: 1.0)
        text.flatness = 0.005
        text.firstMaterial?.diffuse.contents = UIColor.white
        
        let textNode = SCNNode(geometry: text)
        
        let fontSize = Float(0.025)
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        
        let (min, max) = text.boundingBox
        let dx = min.x + 0.5 * (max.x - min.x)
        let dy = min.y + 0.5 * (max.y - min.y)
        let dz = min.z + 0.5 * (max.z - min.z)
        textNode.pivot = SCNMatrix4MakeTranslation(dx, dy, dz)
        
        textNode.eulerAngles.x = -.pi / 2
        
        textNode.position = SCNVector3Zero
        textNode.position.y = planeGap
        
        return textNode
    }
    
    lazy var infoNode: SCNNode = {
        guard let scene = SCNScene(named: "art.scnassets/info/info.scn"),
            let node = scene.rootNode.childNode(withName: "info", recursively: false) else { return SCNNode() }
        
        let scaleFactor  = 0.01
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.position.y = planeGap
        return node
    }()
    
    lazy var imdbNode: SCNNode = {
        guard let scene = SCNScene(named: "art.scnassets/imdb/imdb.scn"),
            let node = scene.rootNode.childNode(withName: "imdb", recursively: false) else { return SCNNode() }
        
        let scaleFactor  = 0.015
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.position.y = planeGap
        return node
    }()
    
    lazy var metacriticNode: SCNNode = {
        guard let scene = SCNScene(named: "art.scnassets/metacritic/metacritic.scn"),
            let node = scene.rootNode.childNode(withName: "metacritic", recursively: false) else { return SCNNode() }
        
        let scaleFactor  = 0.0035
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.position.y = planeGap
        return node
    }()
    
    lazy var ticketNode: SCNNode = {
        guard let scene = SCNScene(named: "art.scnassets/ticket/ticket.scn"),
            let node = scene.rootNode.childNode(withName: "ticket", recursively: false) else { return SCNNode() }
        
        let scaleFactor  = 0.01
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.position.y = planeGap
        return node
    }()
    
    lazy var playButtonNode: SCNNode = {
        guard let scene = SCNScene(named: "art.scnassets/playButton/playButton.scn"),
            let node = scene.rootNode.childNode(withName: "playButton", recursively: false) else { return SCNNode() }
        
        let scaleFactor  = 0.02
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.position.y = planeGap
        node.opacity = 0.8
        return node
    }()
    
    lazy var tomatoNode: SCNNode = {
        guard let scene = SCNScene(named: "art.scnassets/tomato/tomato.scn"),
            let node = scene.rootNode.childNode(withName: "tomato", recursively: false) else { return SCNNode() }
        
        let scaleFactor  = 0.015
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.position.y = planeGap
        return node
    }()
    
    lazy var badTomatoNode: SCNNode = {
        guard let scene = SCNScene(named: "art.scnassets/tomato/badTomato.scn"),
            let node = scene.rootNode.childNode(withName: "badTomato", recursively: false) else { return SCNNode() }
        
        let scaleFactor  = 0.015
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.position.y = planeGap
        return node
    }()
    
    lazy var popcornNode: SCNNode = {
        guard let scene = SCNScene(named: "art.scnassets/popcorn/popcorn.scn"),
            let node = scene.rootNode.childNode(withName: "popcorn", recursively: false) else { return SCNNode() }
        
        let scaleFactor  = 0.02
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.position.y = planeGap
        return node
    }()
    
    lazy var badPopcornNode: SCNNode = {
        guard let scene = SCNScene(named: "art.scnassets/popcorn/badPopcorn.scn"),
            let node = scene.rootNode.childNode(withName: "badPopcorn", recursively: false) else { return SCNNode() }
        
        let scaleFactor  = 0.02
        node.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        node.position.y = planeGap
        return node
    }()
    
    
    // MARK: Handle scene nodes actions
    
    @objc
    func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        let hits = self.sceneView.hitTest(location, options: nil)
        
        guard gesture.state == .ended,
            let tappedNode = hits.first?.node,
            let movieTitle = tappedNode.parent?.parent?.name else {
                return
        }
        
        NSLog("Movie: \(movieTitle). Node tapped: \(tappedNode.name!)")
        switch tappedNode.name {
        case "playButton":
            NSLog("## play video")
            MovieService.instance.getMovie(movieTitle) { movie in
                KinemarYoutubePlayer.instance.present(videoIdentifier: movie.trailer!)
            }
        case "ticket":
            NSLog("## buy ticket")
            MovieService.instance.getMovie(movieTitle) { movie in
                guard KinemarTicketPurchase.instance.openDeepLinkIfAvailable(ingressoId: movie.ingressoID!) else {
                    self.performSegue(withIdentifier: "showTicketPurchase", sender: movie.ticket!)
                    return
                }
            }
        case "info":
            NSLog("showMovieDetail")
            MovieService.instance.getMovie(movieTitle) { movie in
                self.performSegue(withIdentifier: "showMovieDetail", sender: movie)
            }
        default:
            NSLog("Action not registered for node")
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController,
            let viewController = navVC.viewControllers.first {
            switch segue.identifier {
            case "showTicketPurchase":
                let ticketVC = viewController as! WebViewController
                ticketVC.ticketURLString = sender as? String
            case "showMovieDetail":
                let movieVC = viewController as! MovieViewController
                movieVC.movie = sender as? Movie
            default:
                return
            }
        }
    }
}
