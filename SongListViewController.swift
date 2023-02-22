//
//  SongListViewController.swift
//  MusicPlayer
//
//  Created by shelley on 2023/1/16.
//

import UIKit

class SonglistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var items = [StoreItem]()
    var songIndex: Int?
    
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var shuffleBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SongController.shared.fetchItems { (items) in
            guard let items = items else {
                print("❌抓取失敗")
                return
            }
            self.items = items
            // UI 一定要回main thread
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            print("✅成功抓取音樂清單")
        } errorHandler: { (error) in
            self.displayError(error, title: "❌ 檔案抓取失敗")
            print("😡\(error)")
        }
    }
    
    // 檔案抓取失敗跳出警告視窗
    func displayError(_ error: ItemError, title: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: error.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    //MARK: - Actions
    @IBSegueAction func playMusic(_ coder: NSCoder) -> MusicViewController? {
       let controller = MusicViewController(coder: coder)
        controller?.songIndex = songIndex
        return controller
    }
    
    @IBAction func playBtnPressed(_ sender: UIButton) {
        songIndex = 0
        performSegue(withIdentifier: "playMusic", sender: self)
    }
    
    @IBAction func shuffleBtnPressed(_ sender: UIButton) {
        songIndex = Int.random(in: 0...items.count-1)
        performSegue(withIdentifier: "playMusic", sender: self)
    }
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SongListTableViewCell.reuseIdentifier , for: indexPath) as! SongListTableViewCell
    
        cell.artistNameLable.text = items[indexPath.row].artistName
        cell.trackNameLable.text = items[indexPath.row].trackName
        cell.albumImageView.image = UIImage(systemName: "Photo") //若尚未下載完畢先出現內建的SFsymbol
        
        let item = items[indexPath.row]
        let imageUrl = item.artworkUrl100
        
        // 改用SongController.shared的方式來呼叫抓照片的功能
        SongController.shared.fetchImage(urlString: imageUrl ) { (image) in
            guard let image = image else { return }
            DispatchQueue.main.async {
                cell.albumImageView.image = image
            }
        }
        
        // 設定cell高度
        tableView.rowHeight = 95
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        songIndex = tableView.indexPathForSelectedRow?.row
        performSegue(withIdentifier: "playMusic", sender: self)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    


}
