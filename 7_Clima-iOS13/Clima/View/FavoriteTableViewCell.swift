//
//  FavoriteTableViewCell.swift
//  Clima
//
//  Created by p10p093 on 2025/01/18.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        label.text = loadLabel()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadLabel() -> String {
        
        let headerArray: [String] = ["EU", "アジア", "オセアニア", "アフリカ"]
        let EuropeArray: [String] = ["ベルリン", "アムステルダム", "ロンドン"]
        let AsiaArray: [String] = ["東京", "バンコク"]
        let OceaniaArray: [String] = ["シドニー", "メルボルン"]
        let AfricaArray: [String] = ["ケープタウン"]
        
        // 任意のデータを返す（ここでは一例として EU の最初の都市を返します）
        return EuropeArray.first ?? "データなし"
    }
    
}
