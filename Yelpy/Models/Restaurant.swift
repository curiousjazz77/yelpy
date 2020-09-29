//
//  Restaurant.swift
//  Yelpy
//
//  Created by Omeke, Jasmine on 9/28/20.
//  Copyright © 2020 memo. All rights reserved.
//

import Foundation

class Restaurant {
    var imageURL: URL?
    var url: URL?
    var name: String
    var mainCategory: String
    var phone: String
    var rating: Double
    var reviews: Int
    
    init(dict: [String: Any]) {
        imageURL = URL(string: dict["image_url"] as! String)
        name = dict["name"] as! String
        rating = dict["rating"] as! Double
        reviews = dict["review_count"] as! Int
        phone = dict["name"] as! String
        url = URL(string: dict["url"] as! String)
        mainCategory = Restaurant.getMainCategory(dict: dict)
    }
    
    //Helper function to get the first category from the restaurant
    static func getMainCategory(dict: [String:Any]) -> String{
        let categories = dict["categories"] as! [[String: Any]]
        return categories[0]["title"] as! String
    }
}
