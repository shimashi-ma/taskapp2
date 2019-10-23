//
//  Task.swift
//  taskapp2
//
//  Created by mikako kinugawa on 2019/10/19.
//  Copyright © 2019 mikako.kinugawa. All rights reserved.
//


import RealmSwift

class Task: Object {
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0
    
    // タイトル
    @objc dynamic var title = ""
    
    // 内容
    @objc dynamic var contents = ""
    
    /// 日時
    @objc dynamic var date = Date()
    
    // カテゴリ
    @objc dynamic var category = ""
    
    /**
     id をプライマリーキーとして設定。プライマリーキーとはデータベースでそれぞれのデータを一意に識別するためのID
     */
    override static func primaryKey() -> String? {
        return "id"
    }
}
