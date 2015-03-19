//
//  ViewController.swift
//  AllInOne
//
//  Created by Tony on 3/15/15.
//  Copyright (c) 2015 Tony. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    var searchResults = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0,
            right: 0)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
@IBOutlet weak var searchBar: UISearchBar!
@IBOutlet weak var tableView: UITableView!

}

extension SearchViewController: UISearchBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition { return .TopAttached
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) { searchResults = [String]()
    for i in 0...5 {
    searchResults.append(String(format: "This is not the real result  %d for '%@'", i,
    searchBar.text))
    }
    tableView.reloadData() }
}

extension SearchViewController: UITableViewDataSource {
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count }
        
        
        func tableView(tableView: UITableView,
            cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
          let cellIdentifier = "SearchResultCell"
        
          var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
        
          if cell == nil {
            cell = UITableViewCell(style: .Default,
                                    reuseIdentifier: cellIdentifier)
        }
          
          cell.textLabel!.text = searchResults[indexPath.row]
          return cell
        
        
}
}
extension SearchViewController: UITableViewDelegate { }