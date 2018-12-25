import RealmSwift

// TODO: handle history without storing the movie, only a key

class HistoryItem: Object {
    @objc dynamic var movieID: String!
    @objc dynamic var movie: Movie!
    @objc dynamic var date: Date!
    @objc dynamic var place: String!
    
    override static func primaryKey() -> String? {
        return "movieID"
    }
    
    var elapsedTime: String {
        // TODO: create extension to transform date
        
        return "1 dia atrás"
    }
}
