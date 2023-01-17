//
//  StoreItem.swift
//  MusicPlayer
//
//  Created by shelley on 2023/1/12.
//

import Foundation
import UIKit

struct StoreItem: Codable {
    let kind: String
    let trackName: String
    let artistName: String
    let previewUrl: URL
    let artworkUrl60: URL
    let artworkUrl100: String
    
//    var artworkUrl500: URL {
//        artworkUrl100.deletingLastPathComponent().appendingPathComponent("500x500bb.jpg")
//    }
    
}

struct SearchResponse: Codable {
    let results: [StoreItem]
}

//  在不同的view controller中重複利用
internal struct SongController {
    internal static let shared = SongController()

    func fetchItems(completion: @escaping ([StoreItem]?) -> ()) {

        let urlStr = "https://itunes.apple.com/search?term=lenkakripac&media=music"
        if let url = URL(string: urlStr) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        let searchResponse = try decoder.decode(SearchResponse.self, from: data)
                        completion(searchResponse.results)
                    } catch  {
                        completion(nil)
                    }
                }else {

                }
            }.resume()
        }
    }

    func fetchImage(urlString:String, completion: @escaping (UIImage?) -> ()) {

        let image1000 = urlString.replacingOccurrences(of: "100x100", with: "1000x1000")
        if let url = URL(string: image1000){
            URLSession.shared.dataTask(with: url) { data, response, erroe in
                if let data = data,
                   let image = UIImage(data:data){
                    completion(image)
                } else {
                    completion(nil)
                }
            }.resume()

        }


    }

}
