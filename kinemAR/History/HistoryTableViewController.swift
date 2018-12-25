import UIKit

class HistoryTableViewController: UITableViewController {
    
    var history = [HistoryItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HistoryService.instance.getHistory(success: { history in
            self.history = history
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieCell
        let historyItem = history[indexPath.row]
        
        cell.configureCell(withMovie: historyItem.movie, place: historyItem.place, date: historyItem.elapsedTime)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let historyItem = history[indexPath.row]
        performSegue(withIdentifier: "showMovieDetail", sender: historyItem.movie)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is MovieViewController {
            let movieVC = segue.destination as! MovieViewController
            movieVC.movie = sender as? Movie
        }
    }
    
    @IBAction func returnToHomeScreen(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
