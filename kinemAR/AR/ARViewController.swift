import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    let planeGap: Float = 0.03
    let textGap: Float = 0.01
    
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        // sceneView.showsStatistics = true
        
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
        let movieTitle = referenceImage.name!
        
        node.name = movieTitle
        
        updateQueue.async {
            
            let info = self.infoNode
            info.switchPosition(to: .insideBottomRight, imageAnchor: imageAnchor)
            node.addChildNode(info)
            
            MovieService.instance.getMovie(movieTitle, success: { movie in
                if movie.trailer != nil {
                    let playButton = self.playButtonNode
                    node.addChildNode(playButton)
                }
                
                if movie.ticket != nil {
                    let ticket = self.ticketNode
                    ticket.switchPosition(to: .top, imageAnchor: imageAnchor)
                    node.addChildNode(ticket)
                }
                
                if let rating = movie.rating(from: .rottenTomatoesAudience) {
                    let popcorn = Int(rating.dropLast())! < 60 ? self.badPopcornNode : self.popcornNode
                    popcorn.switchPosition(to: .topRight, imageAnchor: imageAnchor)
                    node.addChildNode(popcorn)
                    let textNode = self.createTextNode(string: rating)
                    textNode.switchPosition(to: .right, nodeReference: popcorn, plus: self.textGap)
                    node.addChildNode(textNode)
                    
                }
                
                if let rating = movie.rating(from: .rottenTomatoesCritics) {
                    let tomato = Int(rating.dropLast())! < 60 ? self.badTomatoNode : self.tomatoNode
                    tomato.switchPosition(to: .bottomRight, imageAnchor: imageAnchor)
                    node.addChildNode(tomato)
                    let textNode = self.createTextNode(string: rating)
                    textNode.switchPosition(to: .right, nodeReference: tomato, plus: self.textGap)
                    node.addChildNode(textNode)
                }
                
                if let rating = movie.rating(from: .imdb) {
                    let imdb = self.imdbNode
                    imdb.switchPosition(to: .topLeft, imageAnchor: imageAnchor)
                    node.addChildNode(imdb)
                    let textNode = self.createTextNode(string: rating)
                    textNode.switchPosition(to: .left, nodeReference: imdb, plus: self.textGap)
                    node.addChildNode(textNode)
                }
                
                if let rating = movie.rating(from: .metacritic) {
                    let metacritic = self.metacriticNode
                    metacritic.switchPosition(to: .bottomLeft, imageAnchor: imageAnchor)
                    node.addChildNode(metacritic)
                    let textNode = self.createTextNode(string: rating)
                    textNode.switchPosition(to: .left, nodeReference: metacritic, plus: self.textGap)
                    node.addChildNode(textNode)
                }
                
                // TODO: get movie theater of detection
                
                let historyItem = HistoryItem()
                historyItem.movieID = movie.id
                historyItem.movie = movie
                historyItem.date = Date()
                historyItem.place = "Cinema da Cidade Universitária"
                
                HistoryService.instance.insertItem(historyItem)
            })
        }
        
        DispatchQueue.main.async {
            self.statusViewController.cancelAllScheduledMessages()
            self.statusViewController.showMessage("Detected “\(movieTitle)”")
        }
    }
    
    
    // MARK: Scene nodes
    
    func createTextNode(string: String) -> SCNNode {
        let text = SCNText(string: string, extrusionDepth: 0.1)
        text.font = UIFont.systemFont(ofSize: 1.0)
        text.flatness = 0.005
        text.firstMaterial?.diffuse.contents = UIColor.white
        
        let textNode = SCNNode(geometry: text)
        
        let fontSize = Float(0.02)
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
    
    // TODO: better load from items
    // TODO: scale items inside .dae files
    
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
        
        let scaleFactor  = 0.015
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
            NSLog("## movie detail")
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
