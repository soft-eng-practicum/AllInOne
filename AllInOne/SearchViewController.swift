

import UIKit

class SearchViewController: UIViewController {
    

    var searchOutputs = [SearchOutput]()
    var hasSearched = false
    
    

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
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
        if searchBar.text != "sam smith" {
            for i in 0...5 {
                let searchOutput = SearchOutput()
                searchOutput.name = String(format: "This %d result is not real for", i)
                searchOutput.NameOfArtist = searchBar.text
                searchOutputs.append(searchOutput)
            }
        }
        tableView.reloadData()
        println("The search text is: '\(searchBar.text)'")
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
        let cellIdentifier = "SearchOutputCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if searchOutputs.count == 0 {
            cell.textLabel!.text = "Nothing matches the database :("
            cell.detailTextLabel!.text = ""
        } else {
            let searchOutput = searchOutputs[indexPath.row]
            cell.textLabel!.text = searchOutput.name
            cell.detailTextLabel!.text = searchOutput.NameOfArtist
        }
        return cell
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