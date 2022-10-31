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

    @IBOutlet weak var pageTitleLabel: NSTextField!
    @IBOutlet weak var backButton: NSButton!
    @IBOutlet weak var listStackView: NSStackView!
    @IBOutlet weak var chineseNameTextField: NSTextField!
    @IBOutlet weak var englishNameTextField: NSTextField!
    @IBOutlet weak var birthMonthTextField: NSTextField!
    @IBOutlet weak var birthDateTextField: NSTextField!
    @IBOutlet weak var constellationTextField: NSTextField!
    @IBOutlet weak var departmentTextField: NSTextField!
    @IBOutlet weak var jobTitleTextField: NSTextField!
    @IBOutlet weak var comeFromTextField: NSTextField!
    @IBOutlet weak var photoButton: NSButton!
    @IBOutlet weak var confirmNewDataButton: NSButton!
    
    // MARK: init variables
    
    private let mCoreDateClass = CoreDataClass()
    private let mConstellation = ConstellationsClass()
    
//    let mHome = FileManager.default.homeDirectoryForCurrentUser
    
    
    // MARK: - View Lifecycle & error dialog utility
    
    override func viewDidLoad() {
        super.viewDidLoad()
        componentLayout()
        
        birthMonthTextField.delegate = self
        birthDateTextField.delegate = self
    }
    
    // MARK: Action
    @IBAction func backFrontPageAction(_ sender: Any) {
        backToFrontPage()
    }
    
    @IBAction func saveDataAction(_ sender: NSButton) {
        saveNewData()
    }
    
    
    
    //back to front page
    private func backToFrontPage() {
        if let frontPage = storyboard?.instantiateController(withIdentifier: "ViewController") as? ViewController {
        self.view.window?.contentViewController = frontPage
        }
    }
    
    // check Text field detail
    private func checkTextFieldDetail() -> Colleagues {
        let newData = Colleagues(context: mCoreDateClass.mContext)
        newData.uuid = UUID()
        if chineseNameTextField.stringValue != "" {
            newData.chineseName = chineseNameTextField.stringValue
        }
        if englishNameTextField.stringValue != "" {
            newData.englishName = englishNameTextField.stringValue
        }
        if birthMonthTextField.stringValue != "" &&
            birthDateTextField.stringValue != ""
        {
            let month = birthMonthTextField.stringValue
            let date = birthDateTextField.stringValue
            newData.birthString = month + "/" + date
        }
        if constellationTextField.stringValue != "" {
            newData.constellations = constellationTextField.stringValue
        }
        if departmentTextField.stringValue != "" {
            newData.department = departmentTextField.stringValue
        }
        if jobTitleTextField.stringValue != "" {
            newData.jobTitle = jobTitleTextField.stringValue
        }
        if comeFromTextField.stringValue != "" {
            newData.from = comeFromTextField.stringValue
        }
        return newData
    }
    
    // save data
    private func saveNewData() {
        mCoreDateClass.newDataBase(new: checkTextFieldDetail())
    }
    
    // open file manager
    private func openFile() {
    }
    
    // layout
    private func componentLayout() {
        let toTopHeight: CGFloat = 12
        let viewWidth = view.frame.size.width
        
        pageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        pageTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageTitleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: toTopHeight).isActive = true
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: toTopHeight).isActive = true
        backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12).isActive = true
        
        listStackView.translatesAutoresizingMaskIntoConstraints = false
        listStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        listStackView.trailingAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        listStackView.widthAnchor.constraint(equalToConstant: (viewWidth / 2) - 12).isActive = true
        
        photoButton.translatesAutoresizingMaskIntoConstraints = false
        photoButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 12).isActive = true
        photoButton.widthAnchor.constraint(equalToConstant: (viewWidth / 2) - 24).isActive = true
        photoButton.topAnchor.constraint(equalTo: listStackView.topAnchor).isActive = true
        photoButton.bottomAnchor.constraint(equalTo: listStackView.bottomAnchor).isActive = true
        
        confirmNewDataButton.translatesAutoresizingMaskIntoConstraints = false
        confirmNewDataButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        confirmNewDataButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: (toTopHeight * -1)).isActive = true
    }
    
    // Style
    private func viewStyle() {
    }
}

extension UpdateViewController: NSTextFieldDelegate {
    func controlTextDidEndEditing(_ obj: Notification) {
        print("結束編輯")
    }
}

// MARK: file manager

extension UpdateViewController: FileManagerDelegate {
    
}
