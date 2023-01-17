//
//  SongListTableViewCell.swift
//  MusicPlayer
//
//  Created by shelley on 2023/1/12.
//

import UIKit

class SongListTableViewCell: UITableViewCell {

    @IBOutlet weak var trackNameLable: UILabel!
    
    @IBOutlet weak var artistNameLable: UILabel!
    
    @IBOutlet weak var albumImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
