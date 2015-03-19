


import UIKit

class SearchViewController: UIViewController {
    
    
    var searchOutputs = [SearchOutput]()
    var hasSearched = false
    
  
    struct TableViewCellIdentifiers {
        static let searchOutputCell = "SearchOutputCell"
        static let nothingThereCell = "NothingThereCell"
    }
    
   
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        searchBar.becomeFirstResponder()
        
      
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchOutputCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchOutputCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingThereCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingThereCell)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    

    
}



extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchOutputs = [SearchOutput]()
        searchBar.resignFirstResponder()
        hasSearched = true
        if searchBar.text != "lady gaga" {
            for i in 0...5 {
                let searchOutput = SearchOutput()
                searchOutput.name = String(format: "This %d result is not real for", i)
                searchOutput.NameOfArtist = searchBar.text
                searchOutputs.append(searchOutput)
            }
        }
        tableView.reloadData()
        println("The simulated search text is: '\(searchBar.text)'")
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}


extension SearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        } else if searchOutputs.count == 0 {
            return 1
        } else {
            return searchOutputs.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if searchOutputs.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingThereCell, forIndexPath: indexPath) as UITableViewCell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchOutputCell, forIndexPath: indexPath) as SearchOutputCell
            let searchOutput = searchOutputs[indexPath.row]
            cell.nameLabel.text = searchOutput.name
            cell.artistNameLabel.text = searchOutput.NameOfArtist
            return cell
        }
    }
}



extension SearchViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if searchOutputs.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
}