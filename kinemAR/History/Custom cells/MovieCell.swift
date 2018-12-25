import UIKit

class MovieCell: UITableViewCell {
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(withMovie movie: Movie, place: String, date: String) {
        posterImageView.image       = UIImage(named: movie.title!)
        titleLabel.text             = movie.title ?? "--"
        infoLabel.text              = String(format: "%@  |  %@  |  ", movie.premiereYear ?? "--", movie.runtime ?? "--")
        dateLabel.text              = date
        if let contentRating = movie.contentRating {
            if contentRating.contains("Consulte") {
                infoLabel.text = infoLabel.text! + contentRating
            } else {
                infoLabel.text = infoLabel.text! + "Classificação: " + contentRating
            }
        }
    }
}
