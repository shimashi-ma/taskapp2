//
//  InputViewController.swift
//  taskapp2
//
//  Created by mikako kinugawa on 2019/10/16.
//  Copyright © 2019 mikako.kinugawa. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications //通知用

class InputViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let realm = try! Realm()
    var task: Task!
    //var category: Category!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景をタップしたらdismissKeyboardメソッド(キーボードを閉じる)を呼ぶように設定する
        // UITapGestureRecognizerクラスの初期化時にタップされたときにどのクラスのどのメソッドが呼ばれるかを指定
        // 今回はself(=InputViewController自身)のdismissKeyboard()メソッドを指定
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        
        //viewプロパティが背景に該当するので、addGestureRecognizer(_:)メソッドを使ってviewにUITapGestureRecognizerを登録
        self.view.addGestureRecognizer(tapGesture)
        
        //UIに値を反映するには最初にUIを作成した時に設定したアウトレットにそれぞれの値を設定します
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        categoryTextField.text = task.category
        datePicker.date = task.date
    }
    
    //viewWillDisappear(_:)メソッドは遷移する際に、画面が非表示になるとき呼ばれるメソッド。
    //ここでRealmのwrite(_:)メソッドを使う。削除の時と同じようにtry!を付ける。
    //realm.write~add(_:update:)　→オブジェクトを更新する。{}の中でプロパティをセットする。
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.category = self.categoryTextField.text!
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: true)
        }
        
        setNotification(task: task)
        
        super.viewWillDisappear(animated)
    }
    
    // タスクのローカル通知を登録する --- ここから ---
    func setNotification(task: Task) {
        
        //UNMutableNotificationContentクラスのインスタンス作成
        let content = UNMutableNotificationContent()
        // タイトルと内容とカテゴリを設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        
        if task.category == "" {
            content.categoryIdentifier = "(カテゴリなし)"
        } else {
            content.categoryIdentifier = task.category
        }
        
        content.sound = UNNotificationSound.default
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
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
    
    
    //♯selectorで指定したメソッドには頭に@objcを付ける
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
