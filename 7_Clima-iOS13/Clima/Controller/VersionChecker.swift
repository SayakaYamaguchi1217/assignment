//
//  VersionChecker.swift
//  Clima
//
//  Created by p10p093 on 2025/04/19.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import UIKit
import Firebase
import FirebaseRemoteConfig

// バージョンのチェックと必要ならばアップデートのアラートを表示するためのクラス
class VersionChecker {
    // ①　下記のコードでは、Firebase Remote Config（リモート設定）を使うための「インスタンス」を作成している。
    // Firebase Remote Config は、アプリをアップデートしなくても設定をサーバーからリアルタイムで変えられる仕組みのことである。
    // 下記のコードでは、インスタンス化がされているが、Firebaseが用意してくれた「Remote Configの入り口（＝インスタンス）」を呼び出すことにより、Remote Configの値（current_versionなど）を取り出すことができるようにしている。
    // また、privateが書かれているが、これは外のクラスからこのRemote Configインスタンスを勝手にいじれないようにするためである（カプセル化という）
    // FirebaseのRemoteConfigには、「キー」と「値」のセットでデータが保存されている。例えば、キー：current_version、値："1.2.0"などなど。この「設定の箱」がFirebaseのサーバー上にあって、アプリはそれを取り出します。
    private let remoteConfig = RemoteConfig.remoteConfig()
    
    // ②　VersionCheckerのシングルトンインスタンスを作成
    // シングルトンとは、一言でいうと「アプリ内にたった1つだけ作られる特別なインスタンス」のこと
    // 例えるなら…「アプリの中に1人だけいる管理者（店長）」みたいな存在！
    // 店にはバイトがたくさんいるけど、店長は1人だけ。→ この「店長」がシングルトンのインスタンスである。
    // staticをつけると「そのクラス全体で1つだけのもの」という意味になる。
    static let sharedChecker = VersionChecker()
    
    // ③　UIApplicationがアクティブになった時に呼ばれる関数
    // アプリを起動したとき、一度ホームボタンで閉じた後にもう一回アプリを前面に出したときにこのタイミングで Firebase Remote Config の情報を取得して「バージョン古いからアップデートしてね！」って言いたいわけです。
    // それを検知するために、NotificationCenter ＋ UIApplication.didBecomeActiveNotificationを使います。
    // NotificationCenterでは、キーボードが表示されたよ！アプリがバックグラウンドに行ったよ！アプリがアクティブになったよ！というような「システムからのお知らせ」を設定できます。
    public func setApplicationDidBecomeActive() {
        NotificationCenter.default.addObserver(
            self, // このクラス自身が通知を受け取る
            selector: #selector(applicationDidBecomeActive), // 処理（Selector）：通知を受け取ったら何をするかを自分で決める（例：バージョンチェックする）
            name: UIApplication.didBecomeActiveNotification, // アプリがアクティブ（前面）になったとき
            object: nil) // 通知の送り主の制限。nilで「誰でもOK」
    }
    
    // ④　UIApplicationがアクティブになった時にRemote Configを取得し、バージョンのチェックを行う
    // @objcとは、Swiftのコードを Objective-Cからも呼べるようにするための印です。
    // 何故そんなことが必要なのかというと→ NotificationCenter は 内部で Objective-C を使ってる からです。
    // この関数は NotificationCenter に登録されてて、通知が来たときに Objective-C経由で呼び出されます。
    // @objc が必要な場面として、NotificationCenterでは、Objective-Cの通知機能を使っていると覚えておくと良いです。
    @objc private func applicationDidBecomeActive() {
        fetchRemoteConfigAndCheckVersion()
    }
    
    // ⑤　Remote Configを取得し、バージョンのチェックを行う関数
    // private func fetchRemoteConfigAndCheckVersion()
    // この関数の目的はズバリ：
    // Firebase Remote Config から最新の「強制アップデート用バージョン情報」を取得して、アプリのバージョンと違ったらアップデートアラートを出すというもの。
    private func fetchRemoteConfigAndCheckVersion() {
        // ここは「Remote Configのデータを取りにいく」という意味
        // fetch() は Firebase のサーバーから設定を取得する命令。
        // withExpirationDuration: 0 なので、キャッシュせず毎回サーバーから取得する。
        // status や error は結果を見るための変数。
        remoteConfig.fetch(withExpirationDuration: 0) { (status, error) in
            // error があれば print() して、この先には進まない。エラーがなければ次のステップへ
            guard error == nil else {
                print("error in fetching. value: \(error)")
                return
            }
            // 🔹取得したデータを「使えるようにする」
            // fetch() しただけでは、まだアプリ側で「有効（activate）」されていません。
            // fetchAndActivate() を呼ぶことで、サーバーから取得した値を「今から使っていいよ！」とアプリに反映します。
            // イメージ：fetch() は「荷物を受け取った」状態、fetchAndActivate() は「荷物を開けて使えるようにする」感じです📦🧰
            // このアンダーバー（_）は Swift の「使わない引数を無視するための記号」です。
            // 本来であれば、{ status, error in ... }のように2つ引数を書くことができるが、使わないような場合はアンダーバー（_）を書き、「この引数は無視します」という意味になる。
            self.remoteConfig.fetchAndActivate { _, _ in
                // 🔹 バージョン比較して、違ってたらアラート
                // checkVersion() 関数で、アプリの現在バージョンと Firebase 上の設定を比べて、バージョンが違ったら → アップデートのアラートを出す
                // 下記のコードは、checkVersion() の戻り値（返ってくる値）が true のときだけ、self.showUpdateAlertIfNeeded() が実行されるという意味。
                // Swiftでは、if 文の条件に Bool（真偽値）型の関数や変数 を書くと、それが true か false か自動的に判断してくれる
                if self.checkVersion() {
                    self.showUpdateAlertIfNeeded()
                }
            }
        }
    }
    
    // ⑥　Firebaseから取得したバージョンとローカルのアプリのバージョンを比較し、一致しなければtrueを返す
    private func checkVersion() -> Bool {
        // remoteConfig.configValue(forKey: "current_version")→ Firebase に登録した "current_version"（例: "1.0.1"）を取得
        let currentVersion = remoteConfig.configValue(forKey: "current_version").stringValue ?? ""
        // Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")→ 今このアプリにインストールされてる 自分のバージョン番号 を取得
        let localVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        // この2つを 比較して違ってたら true を返す（＝アップデートが必要）
        print(currentVersion)
        print(localVersionString)
        return currentVersion != localVersionString
    }
    
    //⑦-1 バージョンが一致しない場合にアップデートを促すアラートを表示
    private func showUpdateAlertIfNeeded() {
        // getTopViewController() で 「現在表示されている画面」 を取得する。もし「画面に表示できるViewController」が取れたら rootViewController という名前で使う。もし取れなかったら、ここで関数を終わらせる（returnする）。
        // guard を使う理由。Swiftでは、失敗しそうな処理（nilになるかもしれない処理） は先にガードしておくとコードが読みやすくなります。
        guard let rootViewController = getTopViewController() else { return }
        
        //⑦-2  ここでポップアップの本体を作っています。
        // UIAlertController で
        // タイトル：「アップデートが必要です」
        // メッセージ：「新しいバージョンがApp Storeにあります。アップデートしてください。」
        // スタイル：.alert（画面の中央に出るタイプ）
        let alertController = UIAlertController(title: "アップデートが必要です", message: "新しいバージョンがApp Storeにあります。アップデートしてください。", preferredStyle: .alert)

        //⑦-3 ボタン（アクション）を作成
        // 「アップデート」ボタンの作成
        // UIAlertAction を使って「アップデート」ボタンを作る
        // title: "アップデート" → ボタンのテキスト、style: .default → 普通のボタンのスタイル
        let updateAction = UIAlertAction(title: "アップデート", style: .default) { _ in
            //⑦-4 アップデートボタンを押したら、App Store を開く
            // URL(string: "https://www.apple.com/jp/app-store/") で App Store のURLを作る
            guard let url = URL(string: "https://www.apple.com/jp/app-store/"),
                  // UIApplication.shared.canOpenURL(url) で URLが開けるか確認
                  UIApplication.shared.canOpenURL(url) else { return }
            // UIApplication.shared.open(url, options: [:], completionHandler: nil) で App Store を開く
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        //⑦-5 「あとで」ボタンの作成
        let laterAction = UIAlertAction(title: "あとで", style: .cancel, handler: nil)
        
        //⑦-6 ボタンをアラートに追加
        // 先ほど作った updateAction と laterAction を アラートに登録します。
        // これで、アラートに2つのボタンが表示されます。
        alertController.addAction(updateAction)
        alertController.addAction(laterAction)
        //⑦-7 アラートを画面に表示
        // present　意味：「別の画面（ViewController）を、今の画面の上に表示する」
        rootViewController.present(alertController, animated: true, completion: nil)
    }
    //⑧ 今、画面に「一番手前に表示されているViewController」を見つけたい！
    // →それがアラート（アップデート通知）を表示するための「土台」になるから
    // この関数は、「一番手前の画面はどこだ〜？」と階段を登っていくようなもの
    
    // 🍰 層構造のイメージ（ケーキみたいな重なり）：
    // rootViewController（アプリの一番最初の画面）
    // UINavigationController（画面を次々に push していける入れ物）
    // UITabBarController（下にタブがある入れ物）
    // presentedViewController（モーダルで表示された画面）
    
    // 引数： デフォルトでアプリの一番下の画面（rootViewController）からスタートします。
    // UIApplication.shared.windows.first? で現在表示中のウィンドウを取得し、その中の rootViewController を基点にします。
    private func getTopViewController(_ viewController: UIViewController? = UIApplication.shared.windows.first?.rootViewController) -> UIViewController? {
        // 今のViewControllerはナビゲーションコントローラ？→ 中で今表示されてる画面（visibleViewController）をチェック！
        if let navigationController = viewController as? UINavigationController {
            return getTopViewController(navigationController.visibleViewController)
            // 今のViewControllerはタブバーコントローラ？→ 今選ばれてる画面（selectedViewController）をチェック！
        } else if let tabBarController = viewController as? UITabBarController, let selected = tabBarController.selectedViewController {
            return getTopViewController(selected)
            // さらに上に「モーダルで表示された画面」がある？→ それをチェック！
        } else if let presented = viewController?.presentedViewController {
            return getTopViewController(presented)
            // それらがないなら、それが一番上の画面！
        } else {
            return viewController
        }
    }
}

