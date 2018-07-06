import UIKit

class MovieViewController: UIViewController {

    var movie: Movie!
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var originalTitleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var rtAudienceLabel: UILabel! {
        didSet {
            if let rating = Int(rtAudienceLabel.text!.dropLast()) {
                let popcornIcon = rating < 60 ? "badPopcornIc" : "popcornIc"
                rtAudienceImageView.image = UIImage(named: popcornIcon)
            }
        }
    }
    
    @IBOutlet weak var rtCriticsLabel: UILabel! {
        didSet {
            if let rating = Int(rtCriticsLabel.text!.dropLast()) {
                let tomatoIcon = rating < 60 ? "badTomatoIc" : "tomatoIc"
                rtCriticsImageView.image = UIImage(named: tomatoIcon)
            }
        }
    }
    
    @IBOutlet weak var imdbScoreLabel: UILabel!
    @IBOutlet weak var metacritcScoreLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var actorsLabel: UILabel!
    @IBOutlet weak var movieOutlineLabel: UILabel!
    @IBOutlet weak var rtAudienceImageView: UIImageView!
    @IBOutlet weak var rtCriticsImageView: UIImageView!
    @IBOutlet weak var trailerButton: UIButton!
    @IBOutlet weak var ticketsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView(for: movie)
        configureBackButton()
    }
    
    func configureView(for movie: Movie) {
        posterImageView.image       = UIImage(named: movie.title!)
        titleLabel.text             = movie.title ?? "--"
        originalTitleLabel.text     = movie.originalTitle ?? "--"
        infoLabel.text              = String(format: "%@  |  %@  |  Classificação: %@", movie.premiereYear ?? "--", movie.runtime ?? "--", movie.contentRating ?? "--")
        // TODO
        // locationLabel.text =
        
        rtAudienceLabel.text        = movie.rating(from: .rottenTomatoesAudience) ?? "--"
        rtCriticsLabel.text         = movie.rating(from: .rottenTomatoesCritics) ?? "--"
        imdbScoreLabel.text         = String(format: "%@ / 100", movie.rating(from: .imdb) ?? "--")
        metacritcScoreLabel.text    = String(format: "%@ / 100", movie.rating(from: .metacritic) ?? "--")
        
        directorLabel.text          = movie.director ?? "--"
        actorsLabel.text            = movie.actors ?? "--"
        movieOutlineLabel.text      = movie.movieOutline ?? "--"
        
        trailerButton.isHidden      = movie.trailer == nil
        ticketsButton.isHidden      = movie.ticket == nil
    }
    
    func configureBackButton() {
        if navigationController!.viewControllers.count == 1 {
            let button = UIBarButtonItem(title: "Voltar", style: .plain, target: self, action: #selector(returnToHomeScreen(_:)))
            navigationItem.leftBarButtonItem = button
        }
    }
    
    
    // MARK: IBActions
    
    @IBAction func watchTrailer(_ sender: Any) {
        KinemarYoutubePlayer.instance.present(videoIdentifier: movie.trailer!)
    }
    
    @IBAction func purchaseTickts(_ sender: Any) {
        guard KinemarTicketPurchase.instance.openDeepLinkIfAvailable(ingressoId: movie.ingressoID!) else {
            self.performSegue(withIdentifier: "showTicketPurchase", sender: movie.ticket!)
            return
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTicketPurchase" {
            let webVC = segue.destination as! WebViewController
            webVC.ticketURLString = sender as? String
        }
    }
    
    @IBAction func returnToHomeScreen(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
