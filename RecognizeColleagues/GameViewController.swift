//
//  GameViewController.swift
//  RecognizeColleagues
//
//  Created by Stephen on 2022/10/29.
//

import Cocoa
import CoreData

final class GameViewController: NSViewController {

    let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
}
