//
//  ViewController.swift
//  RecognizeColleagues
//
//  Created by Stephen on 2022/10/29.
//

// 首頁
import Cocoa

final class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    override func viewDidLayout() {
//        super.viewDidLayout()
//        if let size = NSScreen.main?.frame {
//            print("螢幕尺寸: ", size)
//            self.view.frame = size
//        }
//    }

    override var representedObject: Any? {
        didSet {}
    }

    @IBAction func startGamePageAction(_ sender: Any) {
        switchPages(pageID: "GameViewController")
    }
    
    @IBAction func updatePageAction(_ sender: Any) {
        switchPages(pageID: "UpdateViewController")
    }
    
    @IBAction func listPageAction(_ sneder: Any) {
        switchPages(pageID: "ListViewController")
    }
    
    private func switchPages(pageID: String) {
        if let controller = self.storyboard?.instantiateController(withIdentifier: pageID) as? NSViewController {
                self.view.window?.contentViewController = controller
        }
    }
}

