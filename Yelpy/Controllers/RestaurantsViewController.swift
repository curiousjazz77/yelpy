//
//  ViewController.swift
//  Yelpy
//
//  Created by Memo on 5/21/20.
//  Copyright © 2020 memo. All rights reserved.
//

import UIKit
import AlamofireImage

class RestaurantsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    
    // ––––– TODO: Add storyboard Items (i.e. tableView + Cell + configurations for Cell + cell outlets)
    
    // ––––– TODO: Next, place TableView outlet here
    @IBOutlet weak var tableView: UITableView!
   
    @IBOutlet weak var searchBar: UISearchBar!
    // –––––– TODO: Initialize restaurantsArray
    var restaurantsArray: [Restaurant] = []
    
    // –––––– TODO: Add search bar outlet + Variable for filtered Results
    // add outlet
    var filteredRestaurants: [Restaurant] = []
    
    // infinite scross
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    
    // ––––– TODO: Add tableView datasource + delegate
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        
        //Search bar delegate
        searchBar.delegate = self
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
            
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
        getAPIData()
        

    }
    
    
    // ––––– TODO: Get data from API helper and retrieve restaurants
    func getAPIData(){
        API.getRestaurants() { (restaurants) in
            guard let restaurants = restaurants else {
                return
            }
            // print(restaurants)
            self.restaurantsArray = restaurants
            self.filteredRestaurants = restaurants
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return restaurantsArray.count
        return filteredRestaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath) as! RestaurantCell

        //let restaurant = restaurantsArray[indexPath.row]
        
        let restaurant = filteredRestaurants[indexPath.row]
        //Set label to restaurant name for each cell
        //cell.label.text = restaurant["name"] as? String ?? ""
        //cell.phoneLabel.text = restaurant["display_phone"] as? String ?? ""
        
        
        //let categories = restaurant["categories"] as! [[String: Any]]
        //cell.categoryLabel.text = categories[0]["title"] as? String
        
        
        //let reviews = restaurant["review_count"] as? Int
        //cell.reviewCountLabel.text = String(reviews!)
        
        // Get stars
        //let reviewDouble = restaurant["rating"] as! Double
        //cell.starsImage.image = Stars.dict[reviewDouble]!
        
        //Set image of restaurant
        //if let imageUrlString = restaurant["image_url"] as? String {
        //    let imageUrl = URL(string: imageUrlString)
        //    cell.restaurantImage.af_setImage(withURL: imageUrl!)
        //}
        cell.r = restaurant
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let scrollOffsetThreshold = tableView.contentSize.height - tableView.bounds.size.height
        if (!isMoreDataLoading){
            if offsetY >  scrollOffsetThreshold && tableView.isDragging {
                isMoreDataLoading = true
                let frame = CGRect(x:0, y: tableView.contentSize.height,
                                   width:tableView.bounds.size.width,
                                   height: InfiniteScrollActivityView.defaultHeight)
                
                
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                fetchMoreData()
            
        }
        }
    }
    
    func fetchMoreData(){

            API.getRestaurants() { (restaurants) in
                    guard let restaurants = restaurants else {
                        return
                    }
                        
                        // Update flag
                        self.isMoreDataLoading = false

                        // Stop the loading indicator
                        self.loadingMoreView!.stopAnimating()
                        
                        self.restaurantsArray.append(contentsOf: restaurants)
                        self.filteredRestaurants = self.restaurantsArray
                        self.tableView.reloadData()
                    }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell) {
            // let r = restaurantsArray[indexPath.row]
            let r = filteredRestaurants[indexPath.row]
            let detailViewController = segue.destination as! RestaurantDetailViewController
            detailViewController.r = r
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }

}

// ––––– TODO: Create tableView Extension and TableView Functionality
extension RestaurantsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText != "" {
            filteredRestaurants = restaurantsArray.filter{(r: Restaurant) -> Bool in
                return r.name.lowercased().contains(searchText.lowercased())
            }
        }
        else {
            filteredRestaurants = restaurantsArray
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    // when search bar cancel button is clicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder() //remove keyboard
        filteredRestaurants = restaurantsArray
        tableView.reloadData()
    }
}


class InfiniteScrollActivityView: UIView {
    var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
    static let defaultHeight:CGFloat = 60.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupActivityIndicator()
    }
    
    override init(frame aRect: CGRect) {
        super.init(frame: aRect)
        setupActivityIndicator()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicatorView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
    }
    
    func setupActivityIndicator() {
        activityIndicatorView.style = .medium
        activityIndicatorView.hidesWhenStopped = true
        self.addSubview(activityIndicatorView)
    }
    
    func stopAnimating() {
        self.activityIndicatorView.stopAnimating()
        self.isHidden = true
    }
    
    func startAnimating() {
        self.isHidden = false
        self.activityIndicatorView.startAnimating()
    }
}

