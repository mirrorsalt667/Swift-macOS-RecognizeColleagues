//
//  UpdateViewController.swift
//  RecognizeColleagues
//
//  Created by Stephen on 2022/10/30.
//

// 新增同事資料
import Cocoa
import CoreData

final class UpdateViewController: NSViewController {

    @IBOutlet private weak var pageTitleLabel: NSTextField!
    @IBOutlet private weak var backButton: NSButton!
    @IBOutlet private weak var listStackView: NSStackView!
    @IBOutlet private weak var chineseNameTextField: NSTextField!
    @IBOutlet private weak var englishNameTextField: NSTextField!
    @IBOutlet private weak var birthMonthTextField: NSTextField!
    @IBOutlet private weak var birthDateTextField: NSTextField!
    @IBOutlet private weak var constellationTextField: NSTextField!
    @IBOutlet private weak var departmentTextField: NSTextField!
    @IBOutlet private weak var jobTitleTextField: NSTextField!
    @IBOutlet private weak var comeFromTextField: NSTextField!
    @IBOutlet private weak var photoButton: NSButton!
    @IBOutlet private weak var confirmNewDataButton: NSButton!
    
    // MARK: init variables
    
    private let mCoreDateClass = CoreDataClass()
    private let mConstellation = ConstellationsClass()
    private let mFileManager = FileManagerObject()
    private var mIsFirstTimeLoad = true
    private var mPhotoURL: URL?
    
    
    // MARK: - View Lifecycle & error dialog utility
    
    override func viewDidLoad() {
        super.viewDidLoad()
        birthMonthTextField.delegate = self
        birthDateTextField.delegate = self
        mCoreDateClass.mDelegate = self
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        if mIsFirstTimeLoad {
            componentLayout()
            mIsFirstTimeLoad = false
        }
    }
}

// MARK: Action

extension UpdateViewController {
    // 回到前一頁
    @IBAction private func backFrontPageAction(_ sender: Any) {
        backToFrontPage()
    }
    // 儲存新員工資料
    @IBAction private func saveDataAction(_ sender: NSButton) {
        // 1 檢查必填輸入框都有輸入
        guard isTtextFieldEmpty() == false else {
            showAlert(message: "*輸入框請勿空白。", iconName: "exclamationmark.triangle").runModal()
            return
        }
        // 2 先將圖片複製到app裡面
        guard let photoURL = mPhotoURL else { return }
        mFileManager.saveToDirectoryAndSaveIndex(selectFileURL: photoURL) { [weak self] isSuccess, url  in
            if isSuccess {
                // 3 儲存到資料庫
                let month = self!.birthMonthTextField.stringValue
                let date = self!.birthDateTextField.stringValue
                self?.mCoreDateClass.newItemInDataBase(
                    uuid: UUID(),
                    chinese: self!.chineseNameTextField.stringValue,
                    english: self!.englishNameTextField.stringValue,
                    birth: month+"/"+date,
                    constellation: self!.constellationTextField.stringValue,
                    department: self!.departmentTextField.stringValue,
                    job: self!.jobTitleTextField.stringValue,
                    from: self!.comeFromTextField.stringValue,
                    photo: url.path
                )
            } else {
                self?.showAlert(message: "儲存失敗", iconName: "exclamationmark.triangle").runModal()
            }
        }
    }
    // 開啟檔案頁面，選擇圖片
    @IBAction private func selectFileAction(_ sender: Any) {
        guard let window = view.window else { return }
        mFileManager.openFilePanel(window: window) { [weak self] fileURL in
            let fileExtension = fileURL.pathExtension.lowercased()
            if fileExtension == "png"
                || fileExtension == "jpg"
                || fileExtension == "jpeg"
            {
                self?.photoButton.image = NSImage(contentsOf: fileURL)
                self?.mPhotoURL = fileURL
            } else {
                // 不是指定格式
                self?.showAlert(message: "圖片格式錯誤。", iconName: "exclamationmark.triangle").runModal()
            }
        }
    }
}

// MARK: functions

extension UpdateViewController {
    
    //back to front page
    private func backToFrontPage() {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let frontPage = storyboard.instantiateController(withIdentifier: "ViewController") as? ViewController {
            self.view.window?.contentViewController = frontPage
        }
    }
    
    // 檢查輸入框
    private func isTtextFieldEmpty() -> Bool {
        if chineseNameTextField.stringValue != "",
           englishNameTextField.stringValue != "" {
//           birthMonthTextField.stringValue != "",
//           birthDateTextField.stringValue != "",
//           constellationTextField.stringValue != "",
//           departmentTextField.stringValue != "",
//           jobTitleTextField.stringValue != "",
//           comeFromTextField.stringValue != "" {
            return false
        }
        return true
    }
    
    // alert
    private func showAlert(message: String, iconName: String) -> NSAlert {
        let alertController = NSAlert()
        alertController.icon = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)
        alertController.addButton(withTitle: "確定")
        alertController.messageText = message
        return alertController
    }
    
    // 儲存成功後，清空顯示的資料
    private func cleanTextFieldAndImage() {
        chineseNameTextField.stringValue = ""
        englishNameTextField.stringValue = ""
        birthMonthTextField.stringValue = ""
        birthDateTextField.stringValue = ""
        constellationTextField.stringValue = ""
        departmentTextField.stringValue = ""
        jobTitleTextField.stringValue = ""
        comeFromTextField.stringValue = ""
        photoButton.image = NSImage(systemSymbolName: "photo", accessibilityDescription: nil)
    }
    
    // layout
    private func componentLayout() {
        let toTopHeight: CGFloat = 12
        let space: CGFloat = 12
        let viewWidth = view.window!.frame.width
        let windowHeight = view.window!.frame.height
        
        constellationTextField.isEnabled = false
        
        pageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        pageTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: toTopHeight).isActive = true
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: toTopHeight).isActive = true
        backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: space).isActive = true
        
        listStackView.translatesAutoresizingMaskIntoConstraints = false
        listStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        listStackView.trailingAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        listStackView.widthAnchor.constraint(equalToConstant: (viewWidth / 2) - space).isActive = true
        
        photoButton.translatesAutoresizingMaskIntoConstraints = false
        photoButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: space).isActive = true
        photoButton.centerYAnchor.constraint(equalTo: listStackView.centerYAnchor).isActive = true
        photoButton.widthAnchor.constraint(equalToConstant: (viewWidth / 2) - (space * 2)).isActive = true
        photoButton.heightAnchor.constraint(equalToConstant: windowHeight * 2 / 3).isActive = true
        
        confirmNewDataButton.translatesAutoresizingMaskIntoConstraints = false
        confirmNewDataButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        confirmNewDataButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: (toTopHeight * -1)).isActive = true
    }
}

// MARK: Text Field

extension UpdateViewController: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        let monthStr = birthMonthTextField.stringValue
        let dateStr = birthDateTextField.stringValue
        if monthStr != "",
           dateStr != "" {
            if let date = mConstellation.turnStringToDate(input: monthStr + "/" + dateStr) {
                constellationTextField.stringValue = mConstellation.checkPersonConstellation(birth: date)
            }
            
        }
    }
}


// MARK: - Delegate

extension UpdateViewController: CoreDataDelegate {
    // 儲存資料成功
    func saveDataSuccessed(_ object: CoreDataClass, isPhotoDelete: Bool) {
        showAlert(message: "儲存成功。", iconName: "checkmark.square").runModal()
        // 清空內容
        cleanTextFieldAndImage()
    }
    func isDeleteDataSuccessed(_ object: CoreDataClass, isSuccessed: Bool) {}
}
