


import UIKit

class SearchViewController: UIViewController {
    
   
    var searchOutputs = [SearchOutput]()
    var hasSearched = false
    var isLoading = false
    
    struct TableViewCellIdentifiers {
        static let searchOutputCell = "SearchOutputCell"
        static let NothingThereCell = "NothingThereCell"
        static let loadingCell = "LoadingCell"
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
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.NothingThereCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.NothingThereCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    // Apple API Request
    func urlWithSearchText(searchText: String) -> NSURL {
        let dealSpecialText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let urlString = String(format: "http://itunes.apple.com/search?term=%@&limit=200", dealSpecialText)
        //Dealling with special text that user types in the search bar
        let url = NSURL(string: urlString)
        return url!
    }
    
    //Call to String method and return a new string object
    func performStoreRequestWithURL(url: NSURL) -> String? {
        var error : NSError?
        if let OutputString = String(contentsOfURL: url, encoding: NSUTF8StringEncoding, error: &error) {
            return OutputString
        } else if let error = error {
            println("Download Error: \(error)")
        } else {
            println("Unknown Download Error")
        }
        return nil
    }
    
    // parse JSON using IOS JSON parser, coverting JSON search output to a Dictionary
    func parseJSON(jsonString: String) -> [String: AnyObject]? {
        if let output = jsonString.dataUsingEncoding(NSUTF8StringEncoding) {
            var error: NSError?
            if let json = NSJSONSerialization.JSONObjectWithData(output, options: NSJSONReadingOptions(0), error: &error) as? [String: AnyObject] {
                return json
            } else if let error = error {
                println("JSON Error: '\(error)'")
            } else {
                println("Unknown JSON Error")
            }
        }
        return nil
    }
    
    // Parsing Dictionary
    func parseDictionary(dictionary: [String: AnyObject]) -> [SearchOutput]{
        var searchOutputs = [SearchOutput]()
        
        if let array: AnyObject = dictionary["results"] {
            for OutputDict in array as [AnyObject] {
                if let OutputDict = OutputDict as? [String: AnyObject] {
                    var searchOutput: SearchOutput?
                    
                    if let wrapperType = OutputDict["wrapperType"] as? NSString {
                        switch wrapperType {
                        case "track":
                            searchOutput = parseTrack(OutputDict)
                        case "audiobook":
                            searchOutput = parseAudioBook(OutputDict)
                        case "software":
                            searchOutput = parseSoftware(OutputDict)
                        default:
                            break
                        }
                    } else if let kind = OutputDict["kind"] as? NSString {
                        if kind == "ebook" {
                            searchOutput = parseEBook(OutputDict)
                        }
                    }
                    
                    if let Output = searchOutput {
                        searchOutputs.append(Output)
                    }
                } else {
                    println("Expected a dictionary")
                }
            }
        } else {
            println("Expected 'Outputs' array")
        }
        return searchOutputs
    }
    
    // Parse API return data
    func parseTrack(dictionary: [String: AnyObject]) -> SearchOutput {
        let searchOutput = SearchOutput()
        
        searchOutput.name = dictionary["trackName"] as NSString
        searchOutput.artistName = dictionary["artistName"] as NSString
        searchOutput.artworkURL60 = dictionary["artworkUrl60"] as NSString
        searchOutput.artworkURL100 = dictionary["artworkUrl100"] as NSString
        searchOutput.storeURL = dictionary["trackViewUrl"] as NSString
        searchOutput.kind = dictionary["kind"] as NSString
        searchOutput.currency = dictionary["currency"] as NSString
        
        if let price = dictionary["trackPrice"] as? NSNumber {
            searchOutput.price = Double(price)
        }
        
        if let genre = dictionary["primaryGenreName"] as? NSString {
            searchOutput.genre = genre
        }
        
        return searchOutput
    }
    
    func parseAudioBook(dictionary: [String: AnyObject]) -> SearchOutput {
        let searchOutput = SearchOutput()
        searchOutput.name = dictionary["collectionName"] as NSString
        searchOutput.artistName = dictionary["artistName"] as NSString
        searchOutput.artworkURL60 = dictionary["artworkUrl60"] as NSString
        searchOutput.artworkURL100 = dictionary["artworkUrl100"] as NSString
        searchOutput.storeURL = dictionary["collectionViewUrl"] as NSString
        searchOutput.kind = "audiobook"
        searchOutput.currency = dictionary["currency"] as NSString
        
        if let price = dictionary["collectionPrice"] as? NSNumber {
            searchOutput.price = Double(price)
        }
        
        if let genre = dictionary["primaryGenreName"] as? NSString {
            searchOutput.genre = genre
        }
        return searchOutput
    }
    
    func parseSoftware(dictionary: [String: AnyObject]) -> SearchOutput {
        let searchOutput = SearchOutput()
        searchOutput.name = dictionary["trackName"] as NSString
        searchOutput.artistName = dictionary["artistName"] as NSString
        searchOutput.artworkURL60 = dictionary["artworkUrl60"] as NSString
        searchOutput.artworkURL100 = dictionary["artworkURL100"] as NSString
        searchOutput.storeURL = dictionary["trackViewIUrl"] as NSString
        searchOutput.kind = dictionary["kind"] as NSString
        searchOutput.currency = dictionary["currency"] as NSString
        
        if let price = dictionary["price"] as? NSNumber {
            searchOutput.price = Double(price)
        }
        
        if let genre = dictionary["primaryGenreName"] as? NSString {
            searchOutput.genre = genre
        }
        
        return searchOutput
    }
    
    func parseEBook(dictionary: [String: AnyObject]) -> SearchOutput {
        let searchOutput = SearchOutput()
        searchOutput.name = dictionary["trackName"] as NSString
        searchOutput.artistName = dictionary["artistName"] as NSString
        searchOutput.artworkURL60 = dictionary["artworkUrl60"] as NSString
        searchOutput.artworkURL100 = dictionary["artworkUrl100"] as NSString
        searchOutput.storeURL = dictionary["trackViewUrl"] as NSString
        searchOutput.kind = dictionary["kind"] as NSString
        searchOutput.currency = dictionary["currency"] as NSString
        
        if let price = dictionary["price"] as? NSNumber {
            searchOutput.price = Double(price)
        }
        
        if let genres: AnyObject = dictionary["genres"] {
            searchOutput.genre = ", ".join(genres as [String])
        }
        
        return searchOutput
    }
    
    
    //return data: Kind
    func kindForDisplay(kind: String) -> String {
        switch kind {
        case "album": return "Album"
        case "audiobook": return "Audio Book"
        case "book": return "Book"
        case "ebook": return "E-Book"
        case "feature-movie": return "Movie"
        case "music-video": return "MusicVideo"
        case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        default: return kind
        }
    }
    
    // API Request Error Handling
    func checkNetworkError() {
        let alert = UIAlertController(
            title: "Oh no",
            message: "There was somthing about the connection to the server. Please try again.",
            preferredStyle: .Alert
        )
        
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
}



extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !searchBar.text.isEmpty {
            searchBar.resignFirstResponder()
            isLoading = true
            tableView.reloadData()
            hasSearched = true
            searchOutputs = [SearchOutput]()
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            
            dispatch_async(queue) {
                let url = self.urlWithSearchText(searchBar.text)
                
                if let jsonString = self.performStoreRequestWithURL(url) {
                    if let dictionary = self.parseJSON(jsonString) {
                        println("Dictionary \(dictionary)")
                        self.searchOutputs = self.parseDictionary(dictionary)
                        self.searchOutputs.sort { $0.name.localizedStandardCompare($1.name) == NSComparisonResult.OrderedAscending }
                        dispatch_async(dispatch_get_main_queue()) {
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                        return
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.checkNetworkError()                }
            }
            
        }
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}


extension SearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading{
            return 1
        }else if !hasSearched {
            return 0
        } else if searchOutputs.count == 0 {
            return 1
        } else {
            return searchOutputs.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if isLoading {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as UITableViewCell
            
            let spinner = cell.viewWithTag(100) as UIActivityIndicatorView
            spinner.startAnimating()
            
            return cell
        } else if searchOutputs.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.NothingThereCell, forIndexPath: indexPath) as UITableViewCell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchOutputCell, forIndexPath: indexPath) as SearchOutputCell
            let searchOutput = searchOutputs[indexPath.row]
            cell.nameLabel.text = searchOutput.name
            if searchOutput.artistName.isEmpty {
                cell.artistNameLabel.text = "No idea"
            } else {
                cell.artistNameLabel.text = String(format: "%@ (%@)", searchOutput.artistName, searchOutput.kind)
            }
            return cell
        }
    }
}



extension SearchViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if searchOutputs.count == 0 || isLoading{
            return nil
        } else {
            return indexPath
        }
    }
}