//
//  MusicViewController.swift
//  MusicPlayer
//
//  Created by shelley on 2023/1/12.
//

import UIKit
import AVFoundation

class MusicViewController: UIViewController {
    
    var items = [StoreItem]()
    var songIndex: Int!
    
    var player = AVPlayer()
    var playerItem: AVPlayerItem!
    var timeObserverToken: Any?
    
    
    var timer = Timer()
    
    var totalTimeInSec: Double!
    var remainingTimeInSec: Double!
    var currentTimeInSec:Double!
    
    
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var trackNameLable: UILabel!
    @IBOutlet weak var artistNameLable: UILabel!
    
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var totalTimeLable: UILabel!
    @IBOutlet weak var remaingTimeLable: UILabel!
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var nextSongBtn: UIButton!
    @IBOutlet weak var prevSongBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 下載音樂
        SongController.shared.fetchItems { items in
            self.items = items!
            self.playMusic()
        }
        
        //  播放循環音樂，當通知發生時，執行AVPlayerItemDidPlayToEndTime
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [weak self] (notification) in
            if self!.songIndex == (self!.items.count) - 1 {
                self!.songIndex = 0
            } else {
                self!.songIndex += 1
            }
            self!.playMusic()
        }
        
    }
    
    // 關掉畫面時，歌曲停止播放，否則歌曲會一直無限播下去還會疊加
    override func viewDidDisappear(_ animated: Bool) {
        removePeriodicTimeObserver()
    }
    
    // 更新歌曲歌手資訊
    func updateInfo(){
        let currentSong = items[songIndex]
        trackNameLable.text = currentSong.trackName
        artistNameLable.text = currentSong.artistName
        
    }
    
    // 增加定期時間觀察
    func addPeriodicTimeObserver(){
        // 每半秒查看
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)
        
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main, using: { time in
            let duration = self.playerItem.asset.duration
            let second = CMTimeGetSeconds(duration)
            self.totalTimeInSec = Double(second)
            
            let songCurrentTime = self.player.currentTime().seconds
            self.currentTimeInSec = Double(songCurrentTime)
            
            self.setSliderValue()
        })
    }
    
    //移除定期時間觀察
    func removePeriodicTimeObserver(){
        if let timeObserverToken = timeObserverToken{
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
    }
    
    // slider value
    func setSliderValue() {
        if currentTimeInSec == totalTimeInSec {
            removePeriodicTimeObserver()
        } else {
            remainingTimeInSec = totalTimeInSec - currentTimeInSec
            totalTimeLable.text = timeFormate(currentTimeInSec)
            remaingTimeLable.text = "-\(timeFormate(remainingTimeInSec))"
            timeSlider.value = Float(currentTimeInSec / totalTimeInSec)
        }
    }
    
    // 音樂時間轉換 "分鐘：秒數"
    func timeFormate(_ timeInSec: Double) -> String {
        let minute = Int(timeInSec) / 60
        let second = Int(timeInSec) % 60
        
        return second < 10 ? "\(minute):0\(second)" : "\(minute):\(second)"
    }
    
    func playMusic() {
        
        removePeriodicTimeObserver()
        
        let songUrl = items[songIndex].previewUrl
        playerItem = AVPlayerItem(url: songUrl)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        
        // 更新歌曲資訊
        DispatchQueue.main.async {
            self.updateInfo()
        }
        // 更新圖片（讓畫質更好）
        SongController.shared.fetchImage(urlString: items[songIndex].artworkUrl100) { image in
            DispatchQueue.main.async {
                self.albumImageView.image = image
            }
        }
        
        // time observer
        addPeriodicTimeObserver()
    }
    // 播放 ＆ 暫停
    func playAndPause(){
        if player.timeControlStatus == .playing {
            playBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
            player.pause()
        } else {
            playBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            player.play()
        }
    }

    @IBAction func playBtnPressed(_ sender: UIButton) {
        playAndPause()
        
    }
    
    
    @IBAction func nextSong(_ sender: UIButton) {
        if songIndex == items.count - 1 {
            songIndex = 0
        } else {
            songIndex += 1
        }
        playMusic()
    }
    
    
    @IBAction func prevSong(_ sender: UIButton) {
        if songIndex == 0 {
            songIndex = items.count - 1
        } else {
            songIndex -= 1
        }
    }
    
    
    @IBAction func sliderControled(_ sender: UISlider) {
        //slider移動並計算秒數
        let seconds: Int64 = Int64(timeSlider.value)
        let time: CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        player.seek(to: time)
        // seek :找尋音樂區段
    }
    
    
    
}
