//
//  DetailCollectionViewItem.swift
//  RecognizeColleagues
//
//  Created by Stephen on 2022/11/13.
//

import Cocoa

final class DetailCollectionViewItem: NSCollectionViewItem {

    @IBOutlet weak var peopleImageView: NSImageView!
    @IBOutlet weak var peopleLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.cornerRadius = 8.0
        view.window?.backgroundColor = .blue
        view.layer?.backgroundColor = .init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        view.layer?.borderColor = .white
        view.layer?.borderWidth = 1
    }
    
}
