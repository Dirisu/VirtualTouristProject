//
//  FlickrResponse.swift
//  VirtualTouristProject
//
//  Created by Marvellous Dirisu on 17/06/2022.
//

import Foundation

struct FlickrResponse: Codable {
    
    let photos: Photos
    let stat: String
    
//    enum CodingKeys: String, CodingKey{
//        case photos = "photos"
//        case status = "stat"
//    }

struct Photos : Codable{
    let page : Int
    let pages : Int
    let total : Int
    let perpage : Int
    let photo : [FlickrPhoto]
    
}

struct FlickrPhoto : Codable{
    let id : String
    let owner : String
    let secret : String
    let server : String
    let farm : Int
    let title : String
    let ispublic : Int
    let isfriend : Int
    let isfamily : Int
}

}
