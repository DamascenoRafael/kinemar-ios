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
            
            node.name = referenceImage.name
            
            let playButton = self.playButtonNode
            
            let ticket = self.ticketNode
            ticket.switchPosition(to: .top, imageAnchor: imageAnchor)
            
            let tomato = self.tomatoNode
            tomato.switchPosition(to: .left, imageAnchor: imageAnchor)
            
            let popcorn = self.popcornNode
            popcorn.switchPosition(to: .right, imageAnchor: imageAnchor)
            
            node.addChildNode(playButton)
            node.addChildNode(ticket)
            node.addChildNode(tomato)
            node.addChildNode(popcorn)
            
             /*
             // Create a plane to visualize the initial position of the detected image.
             let plane = SCNPlane(width: referenceImage.physicalSize.width,
             height: referenceImage.physicalSize.height)
             let planeNode = SCNNode(geometry: plane)
             planeNode.opacity = 0.25
             
             /*
             `SCNPlane` is vertically oriented in its local coordinate space, but
             `ARImageAnchor` assumes the image is horizontal in its local space, so
             rotate the plane to match.
             */
             planeNode.eulerAngles.x = -.pi / 2
             
             /*
             Image anchors are not tracked after initial detection, so create an
             animation that limits the duration for which the plane visualization appears.
             */
             planeNode.runAction(self.imageHighlightAction)
             
             // Add the plane visualization to the scene.
             node.addChildNode(planeNode)
             */
        }
        
        DispatchQueue.main.async {
            let imageName = referenceImage.name ?? ""
            self.statusViewController.cancelAllScheduledMessages()
            self.statusViewController.showMessage("Detected image “\(imageName)”")
        }
    }
    
    
    // MARK: Scene nodes
    
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
    
    lazy var popcornNode: SCNNode = {
        guard let scene = SCNScene(named: "art.scnassets/popcorn/popcorn.scn"),
            let node = scene.rootNode.childNode(withName: "popcorn", recursively: false) else { return SCNNode() }
        
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
                guard KinemarTicketPurchase.instance.openDeepLinkIfAvailable(ingressoId: movie.ingressoId!) else {
                    self.performSegue(withIdentifier: "showTicketPurchase", sender: movie.ticket!)
                    return
                }
            }
        default:
            NSLog("Action not registered for node")
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navVC = segue.destination as? UINavigationController,
            let webVC = navVC.viewControllers.first as? WebViewController {
            webVC.ticketURLString = sender as? String
        }
    }
}
