//
//  ViewController.swift
//  taskapp2
//
//  Created by mikako kinugawa on 2019/10/16.
//  Copyright © 2019 mikako.kinugawa. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications  //通知用

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Realmインスタンスを取得する
    let realm = try! Realm()
    
    // taskArray →DB内のタスクが格納されるリスト。
    // objects(_:)メソッド でクラスを指定してデータの一覧を取得する
    // sorted(byKeyPath:ascending:)メソッドでソート（並べ替え）して配列を取得。日付近い順\順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    
    //検索ボタンをクリック（タップ）した時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        // キーボードを閉じる
        view.endEditing(true)
        
        if let seachWord = searchBar.text {
            //デバックに表示
            print(seachWord)
            //条件検索　入力された文字とカテゴリ名が一致しているものを取り出す
            taskArray = try! Realm().objects(Task.self).filter("category.text == 'seachWord'")
        }
        //テーブルのリロード
        tableView.reloadData()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        //カテゴリ検索バー
        searchBar.placeholder = "カテゴリ名を入力してください"
    }
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // tableView(_:numberOfRowsInSection:)メソッドは、データの数（＝セルの数）を返すメソッド。
    //データの配列であるtaskArrayの要素数を返す。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return taskArray.count
    }
    
    // tableView(_:cellForRowAtIndexPath:)メソッドは各セルの内容を返すメソッド。
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
         // Cellに値を設定する.
            let task = taskArray[indexPath.row] //taskに行を代入。
            cell.textLabel?.text = task.title   //cellにタイトルを設定。
            
            let formatter = DateFormatter()  //日付を表すDateクラスを任意の形の文字列に変換する
            formatter.dateFormat = "yyyy-MM-dd HH:mm" //どのような文字列にするかを指定
            
            let dateString:String = formatter.string(from: task.date) //文字列型に変換
            cell.detailTextLabel?.text = dateString
            
            return cell

    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルをタップ（選択）した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //segueのIDを指定して遷移させるメソッドperformSegue
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    //セルが削除が可能かどうか、並び替えが可能かどうかなどどのように編集ができるかを返すメソッド。
    //taskappでは削除を可能にするため、.deleteを返します
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    //データベースの実装を行う際にここに追記する
    //tableView(_:commit:forRowAt)メソッドはセルの削除を行う時に呼び出される
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]

            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

            
            // データベースから削除する　tryはSwiftのエラーハンドリングの仕組み、今回はtry!と記述してエラーを無視
            try! realm.write {
                //Realmクラスのdeleteメソッドに指定
                self.realm.delete(task)
                //deleteRows(at:with:)メソッドでセルをアニメーションさせながら削除
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    
    // segue で画面遷移する時に呼ばれる　prepare(for:sender:)メソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        //セルをタップした時　配列taskArrayから該当するTaskクラスのインスタンスを取り出してinputViewControllerのtaskプロパティに設定
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
            
        //+をタップした時
        } else {
            let task = Task()  //Taskクラスのインスタンスを作成
            task.date = Date()  //Taskクラスのdateプロパティに現在時間を設定してる？
            
            //現在のタスク情報を取り出す
            let allTasks = realm.objects(Task.self)
            //タスク数が0でなかったら
            if allTasks.count != 0 {
                //idに1を足す　taskArray.max(ofProperty: "id")ですでに存在しているタスクのidのうち最大のものを取得
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData() //読み込み直して最新の状態にする
    }

}

