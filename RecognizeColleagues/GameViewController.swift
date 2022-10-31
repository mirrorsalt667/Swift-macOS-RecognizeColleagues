//
//  GameViewController.swift
//  RecognizeColleagues
//
//  Created by Stephen on 2022/10/29.
//

// 遊戲頁面

import Cocoa
import CoreData

final class GameViewController: NSViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeWindowSize()
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        backToFrontPage()
    }
    
    //back to front page
    private func backToFrontPage() {
        if let frontPage = storyboard?.instantiateController(withIdentifier: "ViewController") as? ViewController {
        self.view.window?.contentViewController = frontPage
        }
    }
    
    // 依螢幕大小改變視窗大小
    private func changeWindowSize() {
        // 外接螢幕也可以判斷螢幕解析度
        guard let screenSize = NSScreen.main?.frame else {
            print("無法取得螢幕大小")
            return
        }
        print("螢幕大小：", screenSize)
        view.frame = screenSize
        view.window?.contentViewController?.view.frame = screenSize
    }
}
