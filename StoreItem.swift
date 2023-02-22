//
//  StoreItem.swift
//  MusicPlayer
//
//  Created by shelley on 2023/1/12.
//

import Foundation
import UIKit

// 歌曲清單response
struct SearchResponse: Codable {
    let results: [StoreItem]
}
// 單首歌
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
// Item error物件
struct ItemError {
    let errorCode: Int
    let message: String
}


//  在不同的view controller中重複利用
internal struct SongController {
    internal static let shared = SongController()

    func fetchItems(completion: @escaping ([StoreItem]?) -> (), errorHandler: @escaping (ItemError) -> Void) {

        let urlStr = "https://itunes.apple.com/search?term=lenkakripac&media=music"
        // 先判斷網址是否正確
        guard let url = URL(string: urlStr) else {
            print("🕸️網址錯誤")
            return
        }
        //URLSession 讀取 dataTask的方法 取得資料
        let task =  URLSession.shared.dataTask(with: url) { data, response, error in
            // 先判斷是否有error
            if error != nil {
                let error = ItemError(errorCode: 0, message: "😡API錯誤")
                errorHandler(error)
                return
            }
            //檢查 https status code
            guard let urlResponse = response as? HTTPURLResponse else {
                let error = ItemError(errorCode: 0, message: "❌HTTPURLResponse錯誤")
                errorHandler(error)
                return
            }
            //檢查 status code
            if let statusCodeError = self.checkError(statusCode: urlResponse.statusCode) {
                errorHandler(statusCodeError)
                return
            }
            
            //沒有error時，再讀取data
            if let data = data {
                do {
                    // json解析器
                    let decoder = JSONDecoder()
                    // 解析 SearchResponse
                    let searchResponse = try decoder.decode(SearchResponse.self, from: data)
                    completion(searchResponse.results)
                } catch {
                    // 非同步成功 - 沒資料回傳nil
                    completion(nil)
                }
            }
            
        }
        // 開始執行Task
        task.resume()
    }
    
    // 提升畫質解析度
    func fetchImage(urlString:String, completion: @escaping (UIImage?) -> ()) {
        
        let image1000 = urlString.replacingOccurrences(of: "100x100", with: "1000x1000")
        if let url = URL(string: image1000){
            URLSession.shared.dataTask(with: url) { data, response, error in
                // 先判斷是否有error
                if let error = error {
                    print("😡\(error)")
                }else if let data = data,
                   let image = UIImage(data:data){
                    completion(image)
                } else {
                    completion(nil)
                }
            }.resume()
        }
    }
    
    private func checkError(statusCode: Int) -> ItemError? {
        // 檢查status code
        switch statusCode{
            case 200..<300:
                return nil
            
            case 400..<500:
                let error = ItemError(errorCode: statusCode, message: "Client端錯誤")
                return error
            
            case 500..<600:
                let error = ItemError(errorCode: statusCode, message: "伺服器錯誤")
                return error
            
            default:
                let error = ItemError(errorCode: statusCode, message: "未知錯誤")
                return error
        }
    }

}
