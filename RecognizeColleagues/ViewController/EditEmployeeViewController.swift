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
    private var mWillDeleteFileURL: URL?
    
    // MARK: - View Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        birthMonthTextField.delegate = self
        birthDateTextField.delegate = self
        mCoreDateClass.mDelegate = self
        constellationTextField.isEnabled = false
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
            } else {
                self?.showAlert(message: "圖片格式錯誤。", iconName: "exclamationmark.triangle").runModal()
            }
        }
    }
    // 儲存圖片，成功後儲存資料
    @IBAction private func saveDataAction(_: Any) {
        // 1 檢查必填輸入框都有輸入
        guard isTtextFieldEmpty() == false else {
            showAlert(message: "*輸入框請勿空白。", iconName: "exclamationmark.triangle").runModal()
            return
        }
        // 2 先判斷圖片是不是有更新
        if mPhotoURL == nil {
            // 3 圖片沒更新，儲存其他資料
            print("圖片沒更新")
            saveNewDataWithoutNewPhoto()
        } else {
            // 圖片更新
            print("圖片更新")
            mFileManager.saveToDirectoryAndSaveIndex(selectFileURL: mPhotoURL!) { [weak self] isSuccess, url  in
                if isSuccess {
                    // 3 儲存到資料庫
                    self?.saveNewData(fileURL: url)
                    // 4 刪除舊的檔案，在儲存成功後才刪除
                } else {
                    self?.showAlert(message: "儲存失敗", iconName: "exclamationmark.triangle").runModal()
                }
            }
        }
    }
}

// MARK: - Methods
extension EditEmployeeViewController {
    // 警告提示框
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
            // TODO: 取得舊圖片名稱，以便儲存時刪掉舊圖片
            if let url = URL(string: urlStr) {
                mWillDeleteFileURL = url
            }
        }
    }
    // 檢查輸入框
    private func isTtextFieldEmpty() -> Bool {
        if chineseNameTextField.stringValue != "",
           englishNameTextField.stringValue != "" {
            return false
        }
        return true
    }
    // 儲存輸入框內容及圖片url
    private func setDataToSave(file: URL) -> Colleagues {
        let newData = Colleagues(context: mCoreDateClass.mContext)
        // uuid 不變
        newData.uuid = mEmployeeData!.uuid!
        newData.chineseName = chineseNameTextField.stringValue
        newData.englishName = englishNameTextField.stringValue
        let month = birthMonthTextField.stringValue
        let date = birthDateTextField.stringValue
        newData.birthString = month + "/" + date
        newData.constellations = constellationTextField.stringValue
        newData.department = departmentTextField.stringValue
        newData.jobTitle = jobTitleTextField.stringValue
        newData.from = comeFromTextField.stringValue
        // 圖片位置
        newData.photo = file.path
        return newData
    }
    // 儲存輸入框內容 不含圖片
    private func setDataToSaveWithoutPhoto() -> Colleagues {
        let newData = Colleagues(context: mCoreDateClass.mContext)
        // uuid 不變
        newData.uuid = mEmployeeData!.uuid!
        // 依照輸入框
        newData.chineseName = chineseNameTextField.stringValue
        newData.englishName = englishNameTextField.stringValue
        let month = birthMonthTextField.stringValue
        let date = birthDateTextField.stringValue
        newData.birthString = month + "/" + date
        newData.constellations = constellationTextField.stringValue
        newData.department = departmentTextField.stringValue
        newData.jobTitle = jobTitleTextField.stringValue
        newData.from = comeFromTextField.stringValue
        // 圖片不變
        newData.photo = mEmployeeData!.photo
        return newData
    }
    // 儲存資料到資料庫
    private func saveNewData(fileURL: URL) {
        mCoreDateClass.updateItemInDataBase(
            uuid: mEmployeeData!.uuid!, newName: englishNameTextField.stringValue
        )
    }
    private func saveNewDataWithoutNewPhoto() {
        mCoreDateClass.updateItemInDataBase(uuid: mEmployeeData!.uuid!, newName: englishNameTextField.stringValue)
    }
    // 若有新圖片時，刪除舊圖片
    private func deleteNotUseFile(fileURL: URL) {
        mFileManager.deleteFileInDirectory(fileURL: fileURL) { isSuccessed in
            if isSuccessed {
                print("刪除檔案成功")
            } else {
                print("刪除檔案失敗")
            }
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
    func saveDataSuccessed(_ object: CoreDataClass, isPhotoDelete: Bool) {
        if isPhotoDelete {
            // 新圖片儲存成功，刪除舊圖片
            if let willDeleteFileURL = mWillDeleteFileURL {
                deleteNotUseFile(fileURL: willDeleteFileURL)
            }
        }
        showAlert(message: "儲存更新資料成功。", iconName: "checkmark.square").runModal()
    }
}
