//
//  FlickrAPI.swift
//  VirtualTouristProject
//
//  Created by Marvellous Dirisu on 16/06/2022.
//

import Foundation

class FlickrClient {
    
    static let apiKey = "15e56bbb841bd04717a130697417617b"
    
    enum Endpoints {

        static let base = "https://api.flickr.com/services/rest/?method=flickr.photos.search"

        case getPhotos(Double, Double)

        var stringValue: String {
            switch self {

            case.getPhotos(let latitude, let longitude):
                return Endpoints.base + "&apiKey=\(FlickrClient.apiKey)&lat=\(latitude)&lon=\(longitude)&per_page=20&page=\(Int.random(in: 1...10))&format=json&nojsoncallback=1"

            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func taskForGetRequest <ResponseType : Decodable> (url : URL,responseType : ResponseType.Type, completion : @escaping(ResponseType?, Error?)->Void) -> URLSessionTask {
        
            let task = URLSession.shared.dataTask (with: url) { data, response, error in
                guard let data = data else{
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    return
                }
                
                let decoder = JSONDecoder()
                
                do {
                    let responseObject = try decoder.decode(ResponseType.self, from: data)
                    DispatchQueue.main.async {
                        completion(responseObject, nil)
                    }
                    
                } catch  {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
            task.resume()
            return task
        }
    
    class func getPhotos(latitude : Double, longitude : Double, completion : @escaping(FlickrResponse?, Error?)->Void){
        // discardable result
        _ = taskForGetRequest(url: Endpoints.getPhotos(latitude, longitude).url, responseType: FlickrResponse.self) { response, error in
            
                if let response = response{
                    completion(response.self, nil)
                    
//                    print(response)
                    
                }else{
                    completion(nil, error)
                }
            }
            
        }
        
        class func downloadPhotos(imageUrl : URL, completion : @escaping(Data?, Error?) throws -> Void){
            let task = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                guard let data = data else {
                    DispatchQueue.main.async {
                       try? completion(nil, error)
                    }
                    return
                }
                DispatchQueue.main.async {
                   try? completion(data, nil)
                }
            }
            task.resume()
        }
}
