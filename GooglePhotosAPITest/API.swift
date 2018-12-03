//
//  API.swift
//  GooglePhotosAPITest
//
//  Created by Christman, Aurelien (BCG Platinion) on 22/11/2018.
//  Copyright © 2018 Christman, Aurelien. All rights reserved.
//

import Foundation
import UIKit

let SharedAPI = API()

class API {
    var accessToken = ""
    
    func getAlbums(completion: @escaping (AlbumsList) -> Void) {
        
        var urlRequest = URLRequest.init(url: URL(string: "https://photoslibrary.googleapis.com/v1/albums")!)
        
        urlRequest.addValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            do {
                completion(try JSONDecoder().decode(AlbumsList.self, from: data!))
            } catch let jsonError {
                print(jsonError)
            }
            
        }.resume()
    }
    
    func getAlbum(albumId: String, nextToken: String?, completion: @escaping (AlbumItems) -> Void) {
        var urlRequest = URLRequest.init(url: URL(string: "https://photoslibrary.googleapis.com/v1/mediaItems:search")!)
        
        urlRequest.addValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        
        var body = ["albumId" : albumId, "pageSize": "30"]
        
        if (nextToken != nil) { body["pageToken"] = nextToken }

        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        urlRequest.httpBody = jsonData
        
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(String(jsonData!.count), forHTTPHeaderField: "Content-Length")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                print(error!.localizedDescription)
            }
            
            do {
                completion(try JSONDecoder().decode(AlbumItems.self, from: data!))
            } catch let jsonError {
                print(jsonError)
            }
            
            }.resume()
    }
}
