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

        SongController.shared.fetchItems { items in
            self.items = items!
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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
        cell.albumImageView.image = UIImage(systemName: "Photo")
        
        let item = items[indexPath.row]
        URLSession.shared.dataTask(with: item.artworkUrl60) { data, response, error in
            if let data = data {
                DispatchQueue.main.async {
                    cell.albumImageView.image = UIImage(data: data)
                }
            }
        }.resume()
        
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
