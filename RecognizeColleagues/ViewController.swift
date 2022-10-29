//
//  ViewController.swift
//  RecognizeColleagues
//
//  Created by Stephen on 2022/10/29.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func startGameAction(_ sender: Any) {
        switchPages(pageID: "GameViewController")
    }
    
    private func switchPages(pageID: String) {
        if let controller = self.storyboard?.instantiateController(withIdentifier: pageID) as? GameViewController {
            self.view.window?.contentViewController = controller
        }
    }

}

