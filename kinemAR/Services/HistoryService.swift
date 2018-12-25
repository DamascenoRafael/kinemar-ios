import RealmSwift

class HistoryService {
    static let instance = HistoryService()
    
    private init() {
        // This prevents others from using the default '()' initializer for this class.
    }
    
    func insertItem(_ historyItem: HistoryItem) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(historyItem, update: true)
            }
        } catch {
            NSLog("Error creating historyItem: \(error.localizedDescription)")
        }
    }
    
    func getHistory(success: @escaping (_ history: [HistoryItem]) -> Void) {
        do {
            let realm = try Realm()
            let history = realm.objects(HistoryItem.self).sorted(byKeyPath: "date")
            success(Array(history))
        } catch {
            NSLog("Error getting history: \(error.localizedDescription)")
        }
    }
}
