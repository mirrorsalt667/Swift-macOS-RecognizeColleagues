//
//  ListCollectionViewItem.swift
//  RecognizeColleagues
//
//  Created by Stephen on 2022/11/13.
//

import Cocoa

final class ListCollectionViewItem: NSCollectionViewItem {
    
    @IBOutlet weak var presonImageView: NSImageView!
    @IBOutlet weak var nameLabel: NSTextField!
    
    // MARK: Public Properties
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.cornerRadius = 8.0
        view.window?.backgroundColor = .blue
    }
}
