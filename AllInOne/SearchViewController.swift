


import UIKit

class SearchViewController: UIViewController {
    
    
    var searchOutputs = [SearchOutput]()
    var hasSearched = false
    var isLoading = false
    var dataTask: NSURLSessionDataTask?
    
    
    struct TableViewCellIdentifiers {
        static let searchOutputCell = "SearchOutputCell"
        static let NothingThereCell = "NothingThereCell"
        static let loadingCell = "LoadingCell"
    }
    
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    //new
    var refreshControl:UIRefreshControl!
    //new1
    var musicOutputs = [SearchOutput]()
    var softwareOutputs = [SearchOutput]()
    var ebookOutputs = [SearchOutput]()
    var defaultOutputs = [SearchOutput]()
    var forceRefresh = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        searchBar.becomeFirstResponder()
        
        // Register the NIB files
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchOutputCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchOutputCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.NothingThereCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.NothingThereCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        //new
        //pull to refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(self.refreshControl)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //new
    func refresh(sender:AnyObject){
        //new1
        forceRefresh = true
        performSearch()
    }
    
    // Apple API Request
    func urlWithSearchText(searchText: String, category: Int) -> NSURL {
        var entityName: String
        
        switch category {
        case 1: entityName = "musicTrack"
        case 2: entityName = "software"
        case 3: entityName = "ebook"
        default: entityName = ""
        }
        
        let dealSpecialText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let urlString = String(format: "http://itunes.apple.com/search?term=%@&limit=200&entity=%@",dealSpecialText, entityName)
        //Dealling with special text that user types in the search bar
        let url = NSURL(string: urlString)
        return url!
    }
    
    
    
    
    // parse JSON using IOS JSON parser, coverting JSON search output to a Dictionary
    func parseJSON(data: NSData) -> [String: AnyObject]? {
        var error: NSError?
        if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as? [String: AnyObject] {
            return json
        } else if let error = error {
            println("JSON Error: '\(error)'")
        } else {
            println("Unknown JSON Error")
        }
        return nil
    }
    
    //Parsing Dictionary
    func parseDictionary(dictionary: [String: AnyObject]) -> [SearchOutput]{
        var searchOutputs = [SearchOutput]()
        
        if let array: AnyObject = dictionary["results"] {
            for OutputDict in array as! [AnyObject] {
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
        
        searchOutput.name = dictionary["trackName"] as! NSString as String
        searchOutput.artistName = dictionary["artistName"] as! NSString as String
        searchOutput.artworkURL60 = dictionary["artworkUrl60"] as! NSString as String
        searchOutput.artworkURL100 = dictionary["artworkUrl100"] as! NSString as String
        searchOutput.storeURL = dictionary["trackViewUrl"] as! NSString as String
        searchOutput.kind = dictionary["kind"] as! NSString as String
        searchOutput.currency = dictionary["currency"] as! NSString as String
        
        if let price = dictionary["trackPrice"] as? NSNumber {
            searchOutput.price = Double(price)
        }
        
        if let genre = dictionary["primaryGenreName"] as? NSString {
            searchOutput.genre = genre as String
        }
        
        return searchOutput
    }
    
    func parseAudioBook(dictionary: [String: AnyObject]) -> SearchOutput {
        let searchOutput = SearchOutput()
        searchOutput.name = dictionary["collectionName"] as! NSString as String
        searchOutput.artistName = dictionary["artistName"] as! NSString as String
        searchOutput.artworkURL60 = dictionary["artworkUrl60"] as! NSString as String
        searchOutput.artworkURL100 = dictionary["artworkUrl100"] as! NSString as String
        searchOutput.storeURL = dictionary["collectionViewUrl"] as! NSString as String
        searchOutput.kind = "audiobook"
        searchOutput.currency = dictionary["currency"] as! NSString as String
        
        if let price = dictionary["collectionPrice"] as? NSNumber {
            searchOutput.price = Double(price)
        }
        
        if let genre = dictionary["primaryGenreName"] as? NSString {
            searchOutput.genre = genre as String
        }
        return searchOutput
    }
    
    func parseSoftware(dictionary: [String: AnyObject]) -> SearchOutput {
        let searchOutput = SearchOutput()
        searchOutput.name = dictionary["trackName"] as! NSString as String
        searchOutput.artistName = dictionary["artistName"] as! NSString as String
        searchOutput.artworkURL60 = dictionary["artworkUrl60"] as! NSString as String
        searchOutput.artworkURL100 = dictionary["artworkUrl100"] as! NSString as String
        searchOutput.storeURL = dictionary["trackViewUrl"] as! NSString as String
        searchOutput.kind = dictionary["kind"] as! NSString as String
        searchOutput.currency = dictionary["currency"] as! NSString as String
        
        if let price = dictionary["price"] as? NSNumber {
            searchOutput.price = Double(price)
        }
        
        if let genre = dictionary["primaryGenreName"] as? NSString {
            searchOutput.genre = genre as String
        }
        
        return searchOutput
    }
    
    func parseEBook(dictionary: [String: AnyObject]) -> SearchOutput {
        let searchOutput = SearchOutput()
        searchOutput.name = dictionary["trackName"] as! NSString as String
        searchOutput.artistName = dictionary["artistName"] as! NSString as String
        searchOutput.artworkURL60 = dictionary["artworkUrl60"] as! NSString as String
        searchOutput.artworkURL100 = dictionary["artworkUrl100"] as! NSString as String
        searchOutput.storeURL = dictionary["trackViewUrl"] as! NSString as String
        searchOutput.kind = dictionary["kind"] as! NSString as String
        searchOutput.currency = dictionary["currency"] as! NSString as String
        
        if let price = dictionary["price"] as? NSNumber {
            searchOutput.price = Double(price)
        }
        
        if let genres: AnyObject = dictionary["genres"] {
            searchOutput.genre = ", ".join(genres as! [String])
        }
        
        return searchOutput
    }
    
    
    
    
    // API Request Error Handling
    func checkNetworkError() {
        let alert = UIAlertController(
            title: "Oh no",
            message: "There was somthing about the connection to the server. Please try again..",
            preferredStyle: .Alert
        )
        
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let controller = segue.destinationViewController as! DetailViewController
            let indexPath = sender as! NSIndexPath
            controller.searchResult = searchOutputs[indexPath.row]
        }
    }
    
    
    // Actions
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        println("Segment changed: '\(sender.selectedSegmentIndex)'")
        performSearch()
    }
    
}




extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //new1
        forceRefresh = true
        performSearch()
    }
    
    func performSearch() {
        if !searchBar.text.isEmpty {
            
            //new1
            if (segmentedControl.selectedSegmentIndex == 1){
                if (musicOutputs.count > 0 && forceRefresh == false) {
                    searchBar.resignFirstResponder()
                    searchOutputs = musicOutputs
                    tableView.reloadData()
                    return
                }
            } else if (segmentedControl.selectedSegmentIndex == 2){
                if (softwareOutputs.count > 0 && forceRefresh == false) {
                    searchBar.resignFirstResponder()
                    searchOutputs = softwareOutputs
                    tableView.reloadData()
                    return
                }
            } else if (segmentedControl.selectedSegmentIndex == 3){
                if (ebookOutputs.count > 0 && forceRefresh == false) {
                    searchBar.resignFirstResponder()
                    searchOutputs = ebookOutputs
                    tableView.reloadData()
                    return
                }
            } else {
                if (defaultOutputs.count > 0 && forceRefresh == false) {
                    searchBar.resignFirstResponder()
                    searchOutputs = defaultOutputs
                    tableView.reloadData()
                    return
                }
            }
            
            
            
            dataTask?.cancel()
            isLoading = true
            tableView.reloadData()
            
            hasSearched = true
            searchOutputs = [SearchOutput]()
            
            let url = self.urlWithSearchText(searchBar.text, category: segmentedControl.selectedSegmentIndex)
            let session = NSURLSession.sharedSession()
            dataTask = session.dataTaskWithURL(url, completionHandler: {
                data, response, error in
                
                println("On the main thread? " + (NSThread.currentThread().isMainThread ? "Yes" : "No"))
                
                if let error = error {
                    println("Failure ! \(error)")
                    if error.code == -999 { return }
                } else if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let dictionary = self.parseJSON(data) {
                            
                            
                            self.searchOutputs = self.parseDictionary(dictionary)
                            self.searchOutputs.sort { $0.name.localizedStandardCompare($1.name) == NSComparisonResult.OrderedAscending }
                            
                            //new1
                            forceRefresh = false
                            if (segmentedControl.selectedSegmentIndex == 1){
                                self.musicOutputs = self.parseDictionary(dictionary)
                                self.musicOutputs.sort { $0.name.localizedStandardCompare($1.name) == NSComparisonResult.OrderedAscending }
                            } else if (segmentedControl.selectedSegmentIndex == 2){
                                self.softwareOutputs = self.parseDictionary(dictionary)
                                self.softwareOutputs.sort { $0.name.localizedStandardCompare($1.name) == NSComparisonResult.OrderedAscending }
                            } else if (segmentedControl.selectedSegmentIndex == 3){
                                self.ebookOutputs = self.parseDictionary(dictionary)
                                self.ebookOutputs.sort { $0.name.localizedStandardCompare($1.name) == NSComparisonResult.OrderedAscending }
                            } else {
                                self.defaultOutputs = self.parseDictionary(dictionary)
                                self.defaultOutputs.sort { $0.name.localizedStandardCompare($1.name) == NSComparisonResult.OrderedAscending }
                            }
                            
                            
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                self.isLoading = false
                                self.tableView.reloadData()
                            }
                            return
                        }
                    } else {
                        println("Failure! \(response)")
                    }
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.hasSearched = false
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.checkNetworkError()
                }
            })
            
            dataTask?.resume()
        }
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}


extension SearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        } else if !hasSearched {
            return 0
        } else if searchOutputs.count == 0 {
            return 1
        } else {
            return searchOutputs.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if isLoading {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as! UITableViewCell
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            
            return cell
        } else if searchOutputs.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.NothingThereCell, forIndexPath: indexPath) as! UITableViewCell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchOutputCell, forIndexPath: indexPath) as! SearchOutputCell
            let searchOutput = searchOutputs[indexPath.row]
            cell.configureForSearchOutput(searchOutput)
            return cell
        }
    }
}



extension SearchViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("ShowDetail", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if searchOutputs.count == 0 || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
}
