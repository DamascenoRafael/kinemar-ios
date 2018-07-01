enum RatingSource: String {
    case imdb = "IMDb"
    case rottenTomatoes = "Rotten Tomatoes"
    case metacritic = "Metacritic"
}

class Ratting {
    var source: RatingSource!
    var value: String!
}

class Movie {
    var title: String!
    var originalTitle: String!
    var description: String!
    var director: String!
    var ticket: String!
    var production: String!
    var countryOfOrigin: String!
    var contentRating: String!
    var ratings: [Ratting]!
    var writer: String!
    var actors: String!
    var website: String!
    var genre: String!
    var language: String!
    var runtime: String!
    var imdbID: String!
    var year: String!
    var trailer: String!
}
