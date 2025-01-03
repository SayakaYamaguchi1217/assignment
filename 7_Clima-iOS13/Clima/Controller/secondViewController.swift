//
//  SecondViewController.swift
//  Clima
//
//  Created by p10p093 on 2024/12/31.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    // ↓追加
    private var CityName: String = ""

    // ↓追加
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showThirdView") {
            let thirdVC = segue.destination as! ThirdViewController
            thirdVC.getName = self.CityName
        }
    }
    
    // ↓追加 <セクション表示データ>
    let sectionData = ["EU", "アジア","オセアニア","アフリカ"]
    // ↓修正 <テーブル表示データ>
    let tableData = [
        ["Berlin", "Amsterdam", "London"],
        ["Tokyo", "Bangkok"],
        ["Sydney", "Melbourne"],
        ["Capetown"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "都市一覧"

        // ↓追加　<tableview初期設定>
        tableView.frame = view.frame
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
    }

}

// セクションやセル値を管理する
extension SecondViewController: UITableViewDataSource {

    // セクション毎の行数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].count
    }
    
    // ↓追加 セクション数を返す
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionData.count
    }
    
    // ↓追加 セクションヘッダの高さ
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    // 各行に表示するセルを返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // StoryBoradで定義したTableViewCellを取得する
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "NameCell", for: indexPath)
        cell.textLabel?.text = tableData[indexPath.section][indexPath.row]
        return cell
    }
}

// テーブルのイベントを管理する
extension SecondViewController: UITableViewDelegate {
    // ↓追加 セクションヘッダを返す
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionData[section]
    }
    
    // セルタップ時のイベント
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.CityName = tableData[indexPath.section][indexPath.row]
        performSegue(withIdentifier: "showThirdView",sender: nil)
    }
}
