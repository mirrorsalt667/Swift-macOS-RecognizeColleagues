//
//  CoreDataClass.swift
//  RecognizeColleagues
//
//  Created by Stephen on 2022/10/29.
//

import Foundation
import CoreData
import Cocoa

protocol CoreDataDelegate: AnyObject {
    func saveDataSuccessed(_ object: CoreDataClass)
}

final class CoreDataClass: NSObject, NSFetchedResultsControllerDelegate {
    
    let mContainer = (NSApplication.shared.delegate as! AppDelegate).persistentContainer
    let mContext = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var mDelegate: CoreDataDelegate?
    
    
    
    // read and load data
    func loadDataBase(callBack: @escaping ([Colleagues]) -> (Void)) {
        let fetchRequestRead = NSFetchRequest<Colleagues>(entityName: "Colleagues")
//        fetchRequestRead.fetchLimit = 1
//        fetchRequestRead.predicate = NSPredicate(format: "", "")
        
        do {
            let colleaguesData = try mContext.fetch(fetchRequestRead)
            print("資料庫資料", colleaguesData)
            callBack(colleaguesData)
        } catch let readError {
            print("讀取資料庫發生錯誤：", readError)
        }
    }
    
    // 新增資料
    func newDataBase(new: Colleagues) {
        let colleagues = NSEntityDescription.insertNewObject(forEntityName: "Colleagues", into: mContext) as! Colleagues
        colleagues.uuid = new.uuid
        colleagues.chineseName = new.chineseName
        colleagues.englishName = new.englishName
        colleagues.birthString = new.birthString
        colleagues.constellations = new.constellations
        colleagues.department = new.department
        colleagues.jobTitle = new.jobTitle
        colleagues.from = new.from
        colleagues.photo = new.photo
        do {
            try mContext.save()
            print("存入資料", colleagues)
            mDelegate?.saveDataSuccessed(self)
        } catch let catchError {
            print(catchError)
        }
    }
    
    // 更新
    func uploadDataBase(chineseName: String) {
        let fetchRequestUpdate = NSFetchRequest<Colleagues>(entityName: "Colleagues")
        fetchRequestUpdate.fetchLimit = 1
        fetchRequestUpdate.predicate = NSPredicate(format: "", "")
        
        do {
            let colleaguesUpdate = try mContext.fetch(fetchRequestUpdate)
            colleaguesUpdate[0].chineseName = chineseName
            // 存回去
            do {
                try mContext.save()
            } catch let savrError {
                print("update save error: ", savrError)
            }
        } catch let fetchError {
            print(fetchError)
        }
    }
    
    // delete
    func deleteDataBase() {
        let fetchRequestDelete = NSFetchRequest<Colleagues>(entityName: "Colleagues")
//        fetchRequestDelete.fetchLimit = 1
//        fetchRequestDelete.predicate = NSPredicate(format: "", "")
        
        do {
            let colleaguesDelete = try mContext.fetch(fetchRequestDelete)
            mContext.delete(colleaguesDelete[0])
            // 存回去
            do {
                try mContext.save()
            } catch let savrError {
                print("update save error: ", savrError)
            }
        } catch let fetchError {
            print(fetchError)
        }
    }
}
