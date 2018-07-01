import RealmSwift

class MovieService {
    static let instance = MovieService()
    private let userDefaults = UserDefaults.standard
    
    private init() {
        // This prevents others from using the default '()' initializer for this class.
    }
    
    private lazy var dataFromMoviesFile: Data? = {
        guard let path = Bundle.main.path(forResource: moviesFile, ofType: "json") else {
            return nil
        }
        do {
            return try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        } catch let err {
            NSLog("Error reading data from json: \(err)")
            return nil
        }
    }()
    
    private func isNewMoviesFileHash() -> Bool {
        let hash = userDefaults.integer(forKey: KinemarPreference.moviesFileHashKey)
        guard hash != 0 else {
            return true
        }
        
        if let data = dataFromMoviesFile {
            let newHash = data.hashValue
            if newHash != hash {
                userDefaults.set(newHash, forKey: KinemarPreference.moviesFileHashKey)
                return true
            }
        }
        return false
    }
    
    func loadMoviesFileIfNeeded() {
//        guard isNewMoviesFileHash(), let data = dataFromMoviesFile else {
//            return
//        }
        let data = dataFromMoviesFile!
        
        var movies = [Movie]()
        do {
            movies = try JSONDecoder().decode([Movie].self, from: data)
        } catch let err {
            NSLog("Error decoding json: \(err)")
        }
        
        do {
            let realm = try Realm()
            try realm.write {
                realm.deleteAll()
                realm.add(movies, update: true)
            }
        } catch {
            NSLog("Error creating movies: \(error.localizedDescription)")
        }
    }
}
