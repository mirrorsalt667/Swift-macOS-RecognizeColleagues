//
//  EditEmployeeViewController.swift
//  RecognizeColleagues
//
//  Created by Stephen on 2022/11/19.
//

import Cocoa

final class EditEmployeeViewController: NSViewController {
    // MARK: - Properties
    
    public var mEmployeeData: Colleagues?
    
    @IBOutlet private var pageTitleLabel: NSTextField!
    @IBOutlet private var backButton: NSButton!
    @IBOutlet private var listStackView: NSStackView!
    @IBOutlet private var chineseNameTextField: NSTextField!
    @IBOutlet private var englishNameTextField: NSTextField!
    @IBOutlet private var birthMonthTextField: NSTextField!
    @IBOutlet private var birthDateTextField: NSTextField!
    @IBOutlet private var constellationTextField: NSTextField!
    @IBOutlet private var departmentTextField: NSTextField!
    @IBOutlet private var jobTitleTextField: NSTextField!
    @IBOutlet private var comeFromTextField: NSTextField!
    @IBOutlet private var photoButton: NSButton!
    @IBOutlet private var confirmNewDataButton: NSButton!
    
    private let mCoreDateClass = CoreDataClass()
    private let mConstellation = ConstellationsClass()
    private let mFileManager = FileManagerObject()
    private var mIsFirstTimeLoad = true
    private var mPhotoURL: URL?
    
    // MARK: - View Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        birthMonthTextField.delegate = self
        birthDateTextField.delegate = self
        mCoreDateClass.mDelegate = self
        guard let employeeData = mEmployeeData else { return }
        setTextFieldContent(detail: employeeData)
    }
}

// MARK: - Action

extension EditEmployeeViewController {
    // 返回清單頁面
    @IBAction private func backToLastPageAction(_: Any) {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let lastPage = storyboard.instantiateController(withIdentifier: "ListViewController") as? ListViewController {
            self.view.window?.contentViewController = lastPage
        }
    }
    
    // 載入新圖片
    @IBAction private func selectFileAction(_: Any) {
        guard let window = view.window else { return }
        mFileManager.openFilePanel(window: window) { [weak self] fileURL in
            // 取得副檔名，並統一轉成小寫字母
            let fileExtension = fileURL.pathExtension.lowercased()
            if fileExtension == "png"
                || fileExtension == "jpg"
                || fileExtension == "jpeg"
            {
                self?.photoButton.image = NSImage(contentsOf: fileURL)
                self?.mPhotoURL = fileURL
                // TODO: 取得舊圖片名稱，以便儲存時刪掉舊圖片
            } else {
                self?.showAlert(message: "圖片格式錯誤。", iconName: "exclamationmark.triangle").runModal()
            }
        }
    }
}

// MARK: - Methods
extension EditEmployeeViewController {
    // alert
    private func showAlert(message: String, iconName: String) -> NSAlert {
        let alertController = NSAlert()
        alertController.icon = NSImage(systemSymbolName: iconName, accessibilityDescription: nil)
        alertController.addButton(withTitle: "確定")
        alertController.messageText = message
        return alertController
    }
    
    // 設定輸入框內容
    private func setTextFieldContent(detail input: Colleagues) {
        chineseNameTextField.stringValue = input.chineseName ?? ""
        englishNameTextField.stringValue = input.englishName ?? ""
        if let birthString = input.birthString {
            let dateArray = birthString.components(separatedBy: "/")
            if dateArray.count > 1 {
                birthMonthTextField.stringValue = dateArray[0]
                birthDateTextField.stringValue = dateArray[1]
            }
        }
        constellationTextField.stringValue = input.constellations ?? ""
        departmentTextField.stringValue = input.department ?? ""
        jobTitleTextField.stringValue = input.jobTitle ?? ""
        comeFromTextField.stringValue = input.from ?? ""
        if let urlStr = input.photo {
            print("有url嗎？")
            let image = NSImage(contentsOfFile: urlStr)
            photoButton.image = image
        }
    }
}

// MARK: - Text Field
extension EditEmployeeViewController: NSTextFieldDelegate {
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

// MARK: - Core Data Delegate
extension EditEmployeeViewController: CoreDataDelegate {
    func saveDataSuccessed(_ object: CoreDataClass) {
        showAlert(message: "儲存成功。", iconName: "checkmark.square").runModal()
//        cleanTextFieldAndImage()
    }
}
