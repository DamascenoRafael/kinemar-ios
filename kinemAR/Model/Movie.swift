import RealmSwift

enum RatingSource: String {
    case imdb = "IMDb"
    case rottenTomatoesCritics = "Rotten Tomatoes Critics"
    case rottenTomatoesAudience = "Rotten Tomatoes Audience"
    case metacritic = "Metacritic"
}

class Rating: Object, Decodable {
    @objc dynamic var source: String?
    @objc dynamic var value: String?
}

class Movie: Object, Decodable {
    @objc dynamic var movieId: String?
    @objc dynamic var ingressoId: String?
    @objc dynamic var title: String?
    @objc dynamic var originalTitle: String?
    @objc dynamic var movieOutline: String?
    @objc dynamic var director: String?
    @objc dynamic var ticket: String?
    @objc dynamic var production: String?
    @objc dynamic var countryOfOrigin: String?
    @objc dynamic var contentRating: String?
    @objc dynamic var writer: String?
    @objc dynamic var actors: String?
    @objc dynamic var website: String?
    @objc dynamic var genre: String?
    @objc dynamic var language: String?
    @objc dynamic var runtime: String?
    @objc dynamic var imdbID: String?
    @objc dynamic var premiereYear: String?
    @objc dynamic var premiereDate: String?
    @objc dynamic var trailer: String?
    var ratings = [Rating]()
    var isPlaying: Bool?
    
    override static func primaryKey() -> String? {
        return "movieId"
    }
    
    private enum MovieCodingKeys: String, CodingKey {
        case movieId
        case ingressoId
        case title
        case originalTitle
        case movieOutline
        case director
        case ticket
        case production
        case countryOfOrigin
        case contentRating
        case writer
        case actors
        case website
        case genre
        case language
        case runtime
        case imdbID
        case premiereYear
        case premiereDate
        case trailer
        case ratings
        case isPlaying
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let container       = try decoder.container(keyedBy: MovieCodingKeys.self)
        title               = try container.decode(String.self, forKey: .title)
        movieId             = String(title!.hashValue)
        ingressoId          = try container.decode(String.self, forKey: .ingressoId)
        originalTitle       = try container.decode(String.self, forKey: .originalTitle)
        movieOutline        = try container.decode(String.self, forKey: .movieOutline)
        director            = try container.decode(String.self, forKey: .director)
        ticket              = try container.decode(String.self, forKey: .ticket)
        production          = try container.decodeIfPresent(String.self, forKey: .production)
        countryOfOrigin     = try container.decode(String.self, forKey: .countryOfOrigin)
        contentRating       = try container.decode(String.self, forKey: .contentRating)
        writer              = try container.decodeIfPresent(String.self, forKey: .writer)
        actors              = try container.decodeIfPresent(String.self, forKey: .actors)
        website             = try container.decodeIfPresent(String.self, forKey: .website)
        genre               = try container.decodeIfPresent(String.self, forKey: .genre)
        language            = try container.decodeIfPresent(String.self, forKey: .language)
        runtime             = try container.decodeIfPresent(String.self, forKey: .runtime)
        imdbID              = try container.decodeIfPresent(String.self, forKey: .imdbID)
        premiereYear        = try container.decodeIfPresent(String.self, forKey: .premiereYear)
        premiereDate        = try container.decodeIfPresent(String.self, forKey: .premiereDate)
        trailer             = try container.decodeIfPresent(String.self, forKey: .trailer)
        ratings             = try container.decodeIfPresent([Rating].self, forKey: .ratings) ?? [Rating]()
    }
    
    func rating(from source: RatingSource) -> String? {
        guard let rating = ratings.first(where: { $0.source == source.rawValue }),
            let value = rating.value else {
            return nil
        }
        
        return value
    }
}
