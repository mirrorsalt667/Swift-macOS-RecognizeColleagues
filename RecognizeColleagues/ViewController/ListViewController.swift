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
    // MARK: - Properties
    
    @IBOutlet private weak var collectionView: NSCollectionView!
    
    private let mCoreData = CoreDataClass()
    private let mItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ListItemIdentifier")
    private var mEmployeesDetails: [Colleagues] = []
    
    //MARK: - ViewLifeCircle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureFlowLayout()
        loadEmployeeData()
    }
    
    // MARK: Action
    
    @IBAction private func backFrontPageAction(_: Any) {
        if let frontPage = storyboard?.instantiateController(withIdentifier: "ViewController") as? ViewController {
            self.view.window?.contentViewController = frontPage
        }
    }
    
    private func loadEmployeeData() {
        mCoreData.loadDataBase { dataArray in
            self.mEmployeesDetails = dataArray
            self.collectionView.reloadData()
        }
    }
    
    // 設置 collection view
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isSelectable = true
        collectionView.allowsEmptySelection = true
        collectionView.allowsMultipleSelection = true
        collectionView.enclosingScrollView?.borderType = .noBorder
        collectionView.register(DetailCollectionViewItem.self, forItemWithIdentifier: mItemIdentifier)
    }
    // collection view 佈局
    private func configureFlowLayout() {
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 10.0
        flowLayout.minimumLineSpacing = 10.0
        flowLayout.sectionInset = NSEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
        flowLayout.itemSize = NSSize(width: 280, height: 200)
        collectionView.collectionViewLayout = flowLayout
    }
}

// MARK: - Collection View Data Source

extension ListViewController: NSCollectionViewDelegate {}

extension ListViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        print("數量: ", mEmployeesDetails.count)
        return mEmployeesDetails.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: mItemIdentifier, for: indexPath) as! DetailCollectionViewItem
        item.peopleLabel.stringValue = mEmployeesDetails[indexPath.item].englishName!
        item.mDelegate = self
        item.mIndexPathRow = indexPath.item
        if let imageFileURL = mEmployeesDetails[indexPath.item].photo {
            let image = NSImage(contentsOfFile: imageFileURL)
            item.peopleImageView.image = image
        } else {
            item.peopleImageView.image = NSImage(systemSymbolName: "questionmark.square", accessibilityDescription: nil)
        }
        return item
    }
}

// MARK: - Detail Collection View Delegate

extension ListViewController: DetailCollectionViewDelegate {
    func selectEditItem(_ item: DetailCollectionViewItem, selectItem: Int) {
        // TODO: 跳轉頁面到編輯資料的地方
        print("換到編輯頁面")
        let viewController = EditEmployeeViewController()
        viewController.mEmployeeData = mEmployeesDetails[selectItem]
        view.window?.contentViewController = viewController
    }
}
