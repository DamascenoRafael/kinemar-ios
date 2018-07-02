import UIKit

class MovieViewController: UIViewController {

    var movie: Movie!
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var originalTitleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var rtAudienceLabel: UILabel!
    @IBOutlet weak var rtCriticsLabel: UILabel!
    @IBOutlet weak var imdbScoreLabel: UILabel!
    @IBOutlet weak var metacritcScoreLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var actorsLabel: UILabel!
    @IBOutlet weak var movieOutlineLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView(for: movie)
    }
    
    func configureView(for movie: Movie) {
        posterImageView.image       = UIImage(named: movie.title!)
        titleLabel.text             = movie.title!
        originalTitleLabel.text     = movie.originalTitle!
        infoLabel.text              = String(format: "%@ | %@ | %@", movie.premiereYear!, movie.runtime!, movie.contentRating!)
        locationLabel.text          = "" // TODO
        rtAudienceLabel.text        = movie.rating(from: .rottenTomatoesAudience) ?? "--"
        rtCriticsLabel.text         = movie.rating(from: .rottenTomatoesCritics) ?? "--"
        imdbScoreLabel.text         = movie.rating(from: .imdb) ?? "--"
        metacritcScoreLabel.text    = movie.rating(from: .metacritic) ?? "--"
        directorLabel.text          = movie.director!
        actorsLabel.text            = movie.actors!
        movieOutlineLabel.text      = movie.movieOutline!
    }
    
    
    // MARK: IBActions
    
    @IBAction func watchTrailer(_ sender: Any) {
        KinemarYoutubePlayer.instance.present(videoIdentifier: movie.trailer!)
    }
    
    @IBAction func purchaseTickts(_ sender: Any) {
        guard KinemarTicketPurchase.instance.openDeepLinkIfAvailable(ingressoId: movie.ingressoId!) else {
            self.performSegue(withIdentifier: "showTicketPurchase", sender: movie.ticket!)
            return
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
