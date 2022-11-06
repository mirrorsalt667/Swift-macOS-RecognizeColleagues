//
//  FileViewController.swift
//  RecognizeColleagues
//
//  Created by Stephen on 2022/10/30.
//

import Cocoa

final class FileViewController: NSViewController {
    
    // MARK: - Outlets
    
    @IBOutlet var moveUpButton: NSButton!
    @IBOutlet var saveInfoButton: NSButton!
    @IBOutlet var infoTextView: NSTextView!
    @IBOutlet var tableView: NSTableView!
    
    // MARK: - Properties
    
    var filesList: [URL] = []
    var showInvisibles = false
    
    var selectedFolder: URL? {
        didSet {
            if let selectedFolder = selectedFolder {
                print("載入資料")
                filesList = contentsOf(folder: selectedFolder)
                selectedItem = nil
                self.tableView.reloadData()
                self.tableView.scrollRowToVisible(0)
                moveUpButton.isEnabled = true
                view.window?.title = selectedFolder.path
            } else {
                moveUpButton.isEnabled = false
                view.window?.title = "FileSpy"
            }
        }
    }
    
    var selectedItem: URL? {
        didSet {
            infoTextView.string = ""
            saveInfoButton.isEnabled = false
            
            guard let selectedUrl = selectedItem else {
                return
            }
            
            let infoString = infoAbout(url: selectedUrl)
            if !infoString.isEmpty {
                let formattedText = formatInfoText(infoString)
                infoTextView.textStorage?.setAttributedString(formattedText)
                saveInfoButton.isEnabled = true
            }
        }
    }
    
    var selectedFileURL: URL?
    
    
    // MARK: - View Lifecycle & error dialog utility
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        restoreCurrentSelections()
    }
    
    func showErrorDialogIn(window: NSWindow, title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .critical
        alert.beginSheetModal(for: window, completionHandler: nil)
    }
    
}

// MARK: - Getting file or folder information

extension FileViewController {
    
    private func contentsOf(folder: URL) -> [URL] {
        // 1 初始化檔案管理
        let fileManager = FileManager.default
        
        // 2
        do {
            // 3
            let contents = try fileManager.contentsOfDirectory(atPath: folder.path)
            
            // 4
            let urls = contents
                .filter { return showInvisibles ? true : $0.first != "." }
                .map { return folder.appendingPathComponent($0) }
            return urls
        } catch {
            // 5 失敗時回傳空
            return []
        }
    }
    
    func infoAbout(url: URL) -> String {
        // 1 檔案管理
        let fileManager = FileManager.default
        
        // 2
        do {
            // 3
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            var report: [String] = ["\(url.path)", ""]
            
            // 4
            for (key, value) in attributes {
                // ignore NSFileExtendedAttributes as it is a messy dictionary
                if key.rawValue == "NSFileExtendedAttributes" { continue }
                report.append("\(key.rawValue):\t \(value)")
            }
            // 5
            return report.joined(separator: "\n")
        } catch {
            // 6
            return "No information available for \(url.path)"
        }
    }
    
    func formatInfoText(_ text: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        paragraphStyle?.minimumLineHeight = 24
        paragraphStyle?.alignment = .left
        paragraphStyle?.tabStops = [ NSTextTab(type: .leftTabStopType, location: 240) ]
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 14),
            NSAttributedString.Key.paragraphStyle: paragraphStyle ?? NSParagraphStyle.default,
            NSAttributedString.Key.foregroundColor: NSColor.white
        ]
        
        let formattedText = NSAttributedString(string: text, attributes: textAttributes)
        return formattedText
    }
}

// MARK: - Actions

extension FileViewController {
    
    @IBAction func selectFolderClicked(_ sender: Any) {
        // 1 確認視窗存在
        guard let window = view.window else { return }
        // 2 顯示NSOpenPanel
        let panel = NSOpenPanel()
        // 檔案
        panel.canChooseFiles = true
        // 目錄
        panel.canChooseDirectories = false
        // 多選
        panel.allowsMultipleSelection = false
        // 3 閉包等待顯現結果
        panel.beginSheetModal(for: window) { [weak self] (result) in
            if result == NSApplication.ModalResponse.OK {
                // 4
                let fileURL = panel.urls[0]
                print("選擇的檔案：", fileURL)
                self?.saveToDirectoryAndSaveIndex(selectFileURL: fileURL)
            }
        }
    }
    
    @IBAction func toggleShowInvisibles(_ sender: NSButton) {
        // 1
        showInvisibles = (sender.state == NSControl.StateValue.on)

        // 2
        if let selectedFolder = selectedFolder {
          filesList = contentsOf(folder: selectedFolder)
          selectedItem = nil
          tableView.reloadData()
        }

    }
    @IBAction func tableViewDoubleClicked(_ sender: Any) {
        // 1 沒選到的話 不動作
        if tableView.selectedRow < 0 { return }
        // 2
        let selectedItem = filesList[tableView.selectedRow]
        print("選擇item: ", selectedItem)
        // exten
        selectedFileURL = selectedItem
        let fileExtension = selectedFileURL!.pathExtension
        let fileName = selectedFileURL!.lastPathComponent
        print("檔案副檔名：", fileExtension) // 不含點
        print("檔案名稱：", fileName) // 含副檔名
        
        // 3
        if selectedItem.hasDirectoryPath {
            selectedFolder = selectedItem
        }
    }
    
    // 上一頁
    @IBAction func moveUpClicked(_ sender: Any) {
        if selectedFolder?.path == "/" { return }
        selectedFolder = selectedFolder?.deletingLastPathComponent()
    }
    // 儲存
    @IBAction func saveInfoClicked(_ sender: Any) {
        
//        // 1
//        guard let window = view.window else { return }
//        guard let selectedItem = selectedItem else { return }
//
//        // 2
//        let panel = NSSavePanel()
//        // 3
//        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
//        // 4
//        panel.nameFieldStringValue = selectedItem
//            .deletingPathExtension()
//            .appendingPathExtension("fs.txt")
//            .lastPathComponent
//
//        // 5
//        panel.beginSheetModal(for: window) { (result) in
//            if result == NSApplication.ModalResponse.OK,
//               let url = panel.url {
//                // 6
//                do {
//                    let infoAsText = self.infoAbout(url: selectedItem)
//                    try infoAsText.write(to: url, atomically: true, encoding: .utf8)
//                } catch {
//                    self.showErrorDialogIn(window: window,
//                                           title: "Unable to save file",
//                                           message: error.localizedDescription)
//                }
//            }
//        }
    }
    
    func saveToDirectoryAndSaveIndex(selectFileURL: URL) {
        let appDirectory = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask).first!
        // 先製造application資料夾
        do {
            try FileManager().createDirectory(at: appDirectory, withIntermediateDirectories: false, attributes: nil)
        } catch let createError {
            print("生成application資料夾錯誤：", createError)
        }
        // 取檔案名稱
        // 先取得檔案序號
        if let index = readPhotoIndex() {
            // 已有圖片
            let newAppDirectory = appDirectory.appendingPathComponent("colleagues-\(index)").appendingPathExtension("png")
            print("now copy: ", selectFileURL.path, "to: ", newAppDirectory.path)
            do {
                try FileManager().copyItem(at: selectFileURL, to: newAppDirectory)
                // 將圖片序號存回去
                savePhotosIndex(index: (index + 1))
            } catch let copyError {
                print("儲存錯誤：", copyError.localizedDescription)
            }
        } else {
            // 第一張圖片
            let newAppDirectory = appDirectory.appendingPathComponent("colleagues-1").appendingPathExtension("png")
            print("now copy: ", selectFileURL.path, "to: ", newAppDirectory.path)
            do {
                try FileManager().copyItem(at: selectFileURL, to: newAppDirectory)
                // 將圖片序號存回去
                savePhotosIndex(index: 1)
            } catch let copyError {
                print("儲存錯誤：", copyError.localizedDescription)
            }
        }
    }
    
    private func savePhotosIndex(index: Int) {
        let userdefault = UserDefaults()
        userdefault.setValue(index, forKey: "last_photo_index")
    }
    
    private func readPhotoIndex() -> Int? {
        let userdefault = UserDefaults()
        if let index = userdefault.value(forKey: "last_photo_index") as? Int {
            return index
        }
        return nil
    }
}

// MARK: - NSTableViewDataSource

extension FileViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filesList.count
    }
}

// MARK: - NSTableViewDelegate

extension FileViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // 1 顯示的item
        let item = filesList[row]
        
        // 2 顯示檔案中的icon
        let fileIcon = NSWorkspace.shared.icon(forFile: item.path)
        
        // 3 建立自訂table cell view
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FileCell"), owner: nil) as? NSTableCellView {
            // 4
            cell.textField?.stringValue = item.lastPathComponent
            cell.imageView?.image = fileIcon
            return cell
        }
        // 5
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if tableView.selectedRow < 0 {
            selectedItem = nil
            return
        }
        selectedItem = filesList[tableView.selectedRow]
    }
}

// MARK: - Save & Restore previous selection

extension FileViewController {
    func saveCurrentSelections() {
        guard let dataFileUrl = urlForDataStorage() else { return }
        
        let parentForStorage = selectedFolder?.path ?? ""
        let fileForStorage = selectedItem?.path ?? ""
        let completeData = "\(parentForStorage)\n\(fileForStorage)\n"
        
        try? completeData.write(to: dataFileUrl, atomically: true, encoding: .utf8)
    }
    
    func restoreCurrentSelections() {
        guard let dataFileUrl = urlForDataStorage() else { return }
        
        do {
            let storedData = try String(contentsOf: dataFileUrl)
            let storedDataComponents = storedData.components(separatedBy: .newlines)
            if storedDataComponents.count >= 2 {
                if !storedDataComponents[0].isEmpty {
                    selectedFolder = URL(fileURLWithPath: storedDataComponents[0])
                    if !storedDataComponents[1].isEmpty {
                        selectedItem = URL(fileURLWithPath: storedDataComponents[1])
                        selectUrlInTable(selectedItem)
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    private func selectUrlInTable(_ url: URL?) {
        guard let url = url else {
            tableView.deselectAll(nil)
            return
        }
        
        if let rowNumber = filesList.index(of: url) {
            let indexSet = IndexSet(integer: rowNumber)
            DispatchQueue.main.async {
                self.tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
            }
        }
    }
    
    private func urlForDataStorage() -> URL? {
        return nil
    }
}
