//
//  FavoriteViewController.swift
//  Clima
//
//  Created by p10p093 on 2024/12/15.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit

// strictとは、値のグループを一つの複合的なデータ型として扱うこと
struct rail {
    var isShown: Bool
    var railName: String
    var stationArray: [String]
}

class FavoriteViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var tableView: UITableView! {
        didSet {
                    tableView.dataSource = self
                    tableView.delegate = self
                }
    }
    
    // privateはclassの中でしか実行できない。
    private let headerArray: [String] = ["山手線", "東横線", "田園都市線", "常磐線"]
    private let yamanoteArray: [String] = ["渋谷", "新宿", "池袋"]
    private let toyokoArray: [String] = ["自由ヶ丘", "日吉"]
    private let dentoArray: [String] = ["溝の口", "二子玉川"]
    private let jobanArray: [String] = ["上野"]
    
    //今回使用するモデルの配列
    private lazy var courseArray = [
        rail(isShown: true, railName: self.headerArray[0], stationArray: self.yamanoteArray),
        rail(isShown: false, railName: self.headerArray[1], stationArray: self.toyokoArray),
        rail(isShown: false, railName: self.headerArray[2], stationArray: self.dentoArray),
        rail(isShown: false, railName: self.headerArray[3], stationArray: self.jobanArray)
    ]

}

extension FavoriteViewController: UITableViewDataSource {
    //各セッションの中のcellの数をここでセットする。courseArrayの中のstationArrayの中の駅名がいくつあるか数えている。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if courseArray[section].isShown {
            return courseArray[section].stationArray.count
        } else {
            return 0
        }
    }

    //ここでは、cellのなかに何が入るのかを設定しています。cellはtitleLabelを元々持っているのでそのまま使ってしまいましょう！
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = courseArray[indexPath.section].stationArray[indexPath.row]
        
        return cell
    }

    //ここではセクションの数を設定しています。今回は、路線の数だけ、セクションが必要になります。
    func numberOfSections(in tableView: UITableView) -> Int {
        return courseArray.count
    }

    //ここでは、セクションのタイトルに何を入れるかをセットしています。
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return courseArray[section].railName
    }
}

extension FavoriteViewController: UITableViewDelegate {
    //HeaderのViewに対して、タップを感知できるようにして行きます。
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView()
        //UITapGestureを定義する。Tapされた際に、headertappedを呼ぶようにしています。
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(headertapped(sender:)))
        //ここで、実際に、HeaderViewをセットします。
        headerView.addGestureRecognizer(gesture)

        headerView.tag = section
        return headerView
    }

    //タップされるとこのメソッドが呼ばれます。
    @objc func headertapped(sender: UITapGestureRecognizer) {
        //tagを持っていない場合は、guardします。
                guard let section = sender.view?.tag else {
                    return
                }
                //courseArray[section].isShownの値を反転させます。
                courseArray[section].isShown.toggle()
               
                //これ以降で表示、非表示を切り替えます。
                tableView.beginUpdates()
                tableView.reloadSections([section], with: .automatic)
                tableView.endUpdates()
    }
}
