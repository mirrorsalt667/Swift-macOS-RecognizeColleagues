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
    func saveDataSuccessed(_ object: CoreDataClass, isPhotoDelete: Bool)
    func isDeleteDataSuccessed(_ object: CoreDataClass, isSuccessed: Bool)
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
    func newItemInDataBase(uuid: UUID,
                           chinese: String,
                           english: String,
                           birth: String,
                           constellation: String,
                           department: String,
                           job: String,
                           from: String,
                           photo: String,
                           time: String
    ) {
//        let colleagues = NSEntityDescription.insertNewObject(forEntityName: "Colleagues", into: mContext) as! Colleagues
        let colleague = Colleagues(context: mContext)
        colleague.uuid = uuid
        colleague.chineseName = chinese
        colleague.englishName = english
        colleague.birthString = birth
        colleague.constellations = constellation
        colleague.department = department
        colleague.jobTitle = job
        colleague.from = from
        colleague.photo = photo
        colleague.timeString = time
        do {
            try mContext.save()
            print("存入資料：", colleague)
            mDelegate?.saveDataSuccessed(self, isPhotoDelete: false)
        } catch let catchError {
            print("存入資料錯誤：", catchError)
        }
    }
    
    // 更新
    func updateItemInDataBase(uuid: UUID,
                              chinese: String,
                              english: String,
                              birth: String,
                              constellation: String,
                              department: String,
                              job: String,
                              from: String,
                              photo: String,
                              time: String,
                              needDeletePhoto: Bool
    ) {
        let request = NSFetchRequest<Colleagues>(entityName: "Colleagues")
        request.predicate = NSPredicate(format: "uuid == %@", uuid as CVarArg)
        do {
            let result = try mContext.fetch(request)
            print("取得更新前資料：", result)
            if result.count > 0 {
                result[0].chineseName = chinese
                result[0].englishName = english
                result[0].birthString = birth
                result[0].constellations = constellation
                result[0].department = department
                result[0].jobTitle = job
                result[0].from = from
                result[0].photo = photo
                result[0].timeString = time
            }
            do {
                try mContext.save()
                mDelegate?.saveDataSuccessed(self, isPhotoDelete: needDeletePhoto)
            } catch let saveError {
                print("更新後儲存錯誤：", saveError)
            }
        } catch let checkError {
            print("更新前取得資料失敗：", checkError)
        }
    }
//    func updateDataBase(uuid: UUID, updateItem: Colleagues) {
//        let fetchRequestUpdate = NSFetchRequest<Colleagues>(entityName: "Colleagues")
//        fetchRequestUpdate.fetchLimit = 1
//        fetchRequestUpdate.predicate = NSPredicate(format: "uuid = \(uuid)")
//        do {
//            let colleaguesUpdate = try mContext.fetch(fetchRequestUpdate)
//            print("讀取部分資料庫：", colleaguesUpdate)
//            if colleaguesUpdate.count == 1 {
//                colleaguesUpdate[0].chineseName = updateItem.chineseName
//                colleaguesUpdate[0].englishName = updateItem.englishName
//                colleaguesUpdate[0].birthString = updateItem.birthString
//                colleaguesUpdate[0].constellations = updateItem.constellations
//                colleaguesUpdate[0].department = updateItem.department
//                colleaguesUpdate[0].jobTitle = updateItem.jobTitle
//                colleaguesUpdate[0].from = updateItem.from
//                colleaguesUpdate[0].photo = updateItem.photo
//                print("更新的資料：", colleaguesUpdate)
//                // 存回去
//                do {
//                    try mContext.save()
//                    mDelegate?.saveDataSuccessed(self)
//                } catch let savrError {
//                    print("更新資料儲存時錯誤：", savrError)
//                }
//            } else {
//                print("檔案不只一個")
//            }
//        } catch let fetchError {
//            print("更新資料讀取時錯誤：", fetchError)
//        }
//    }
    
    // delete
    func deleteDataBase(uuid: UUID) {
        let fetchRequestDelete = NSFetchRequest<Colleagues>(entityName: "Colleagues")
        fetchRequestDelete.predicate = NSPredicate(format: "uuid == %@", uuid as CVarArg)
        do {
            let colleaguesDelete = try mContext.fetch(fetchRequestDelete)
            if colleaguesDelete.count > 0 {
                mContext.delete(colleaguesDelete[0])
            }
            do {
                try mContext.save()
                mDelegate?.isDeleteDataSuccessed(self, isSuccessed: true)
            } catch let saveError {
                print("刪除後儲存失敗：", saveError)
                mDelegate?.isDeleteDataSuccessed(self, isSuccessed: false)
            }
        } catch let deleteError {
            print("刪除時發生錯誤：", deleteError)
            mDelegate?.isDeleteDataSuccessed(self, isSuccessed: false)
        }
    }
}
