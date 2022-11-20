//
//  DetailCollectionViewItem.swift
//  RecognizeColleagues
//
//  Created by Stephen on 2022/11/13.
//

import Cocoa

protocol DetailCollectionViewDelegate: AnyObject {
    func selectEditItem(_ item: DetailCollectionViewItem, selectItem: Int)
}

final class DetailCollectionViewItem: NSCollectionViewItem {
    // MARK: - Properties
    
    @IBOutlet weak var peopleImageView: NSImageView!
    @IBOutlet weak var peopleLabel: NSTextField!
    
    public var mDelegate: DetailCollectionViewDelegate?
    public var mIndexPathRow: Int?
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.cornerRadius = 8.0
        view.window?.backgroundColor = .blue
        view.layer?.backgroundColor = .init(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        view.layer?.borderColor = .white
        view.layer?.borderWidth = 1
    }
    
    @IBAction private func editItemClickAction(_: Any) {
        if let indexPathRow = mIndexPathRow {
            print("點擊的item：", indexPathRow)
            mDelegate?.selectEditItem(self, selectItem: indexPathRow)
        }
    }
}
