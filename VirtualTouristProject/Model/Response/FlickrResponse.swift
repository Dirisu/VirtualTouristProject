//
//  FlickrResponse.swift
//  VirtualTouristProject
//
//  Created by Marvellous Dirisu on 17/06/2022.
//

import Foundation

struct FlickrResponse: Decodable {

    let photos: PhotosResult
    let stat: String
}

struct PhotosResult : Decodable {
    let page:Int
    let pages:Int
    let perpage:Int
    let total: Int
    let photo:[FlickrPhoto]

}

struct FlickrPhoto : Decodable {
    let id:String
    let owner:String
    let secret:String
    let server:String
    let farm:Int
    let title:String
    let ispublic:Int
    let isfriend:Int
    let isfamily:Int
}
