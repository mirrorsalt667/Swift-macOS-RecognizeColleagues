//
//  FileManagerObject.swift
//  RecognizeColleagues
//
//  Created by Stephen on 2022/11/6.
//

import Foundation
import Cocoa

final class FileManagerObject {
    
    func openFilePanel(window: NSWindow, handler: @escaping (URL) -> (Void) ) {
        // 1 確認視窗存在
//        guard let window = view.window else { return }
        // 2 顯示NSOpenPanel
        let panel = NSOpenPanel()
        // 檔案
        panel.canChooseFiles = true
        // 目錄
        panel.canChooseDirectories = false
        // 多選
        panel.allowsMultipleSelection = false
        // 3 閉包等待顯現結果
        panel.beginSheetModal(for: window) { (result) in
            if result == NSApplication.ModalResponse.OK {
                // 4
                let fileURL = panel.urls[0]
                print("選擇的檔案：", fileURL)
                    // 5 回傳檔案URL
                handler(fileURL)
                    // 6-1 複製並儲存圖片
//                    self?.saveToDirectoryAndSaveIndex(selectFileURL: fileURL)
                
                // 6-2 不是指定格式，不儲存
                // TODO: - 提示格式錯誤
            }
        }
    }
    
    func saveToDirectoryAndSaveIndex(selectFileURL: URL, handler: @escaping (Bool, URL) -> (Void)) {
        var isSaveSuccessed = false
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
                isSaveSuccessed = true
                handler(isSaveSuccessed, newAppDirectory)
            } catch let copyError {
                print("儲存錯誤：", copyError.localizedDescription)
                handler(isSaveSuccessed, newAppDirectory)
            }
        } else {
            // 第一張圖片
            let newAppDirectory = appDirectory.appendingPathComponent("colleagues-1").appendingPathExtension("png")
            print("now copy: ", selectFileURL.path, "to: ", newAppDirectory.path)
            do {
                try FileManager().copyItem(at: selectFileURL, to: newAppDirectory)
                // 將圖片序號存回去
                savePhotosIndex(index: 1)
                isSaveSuccessed = true
                handler(isSaveSuccessed, newAppDirectory)
            } catch let copyError {
                print("儲存錯誤：", copyError.localizedDescription)
                handler(isSaveSuccessed, newAppDirectory)
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
