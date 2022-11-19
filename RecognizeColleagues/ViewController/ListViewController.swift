//
//  ListViewController.swift
//  RecognizeColleagues
//
//  Created by Stephen on 2022/10/30.
//

// 檢視現有同事資料
// 取得資料庫資料及圖片，塞進表格

import Cocoa

final class ListViewController: NSViewController {

    @IBOutlet private weak var collectionView: NSCollectionView!
    
    let itemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ListItemIdentifier")
    let detailArray = ["123", "456", "678"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureFlowLayout()
    }
    
    
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isSelectable = true
        collectionView.allowsEmptySelection = true
        collectionView.allowsMultipleSelection = true
        collectionView.enclosingScrollView?.borderType = .noBorder
        collectionView.register(DetailCollectionViewItem.self, forItemWithIdentifier: itemIdentifier)
    }
    
    func configureFlowLayout() {
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        flowLayout.sectionInset = NSEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
        flowLayout.itemSize = NSSize(width: 280, height: 200)
        collectionView.collectionViewLayout = flowLayout
    }
}

extension ListViewController: NSCollectionViewDelegate {}

extension ListViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        print("數量: ", detailArray.count)
        return detailArray.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: itemIdentifier, for: indexPath) as! DetailCollectionViewItem
        item.peopleLabel.stringValue = detailArray[indexPath.item]
        item.peopleImageView.image = NSImage(systemSymbolName: "circle", accessibilityDescription: nil)
        return item
    }
}
