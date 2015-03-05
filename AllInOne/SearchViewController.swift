//
//  ViewController.swift
//  AllInOne
//
//  Created by Sichong Huang on 15/3/4.
//  Copyright (c) 2015年 All in one. All rights reserved.
//

import UIKit


class SearchViewController: UIViewController {
    var searchResults = [String]()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchResults = [String]()
    for i in 0...2 {
    searchResults.append(String(format: "Fake Result %d for '%@'", i,
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
        cell = UITableViewCell(style: .Default,reuseIdentifier: cellIdentifier)
        }
        cell.textLabel!.text = searchResults[indexPath.row]
        return cell
        }
extension SearchViewController: UITableViewDelegate { }