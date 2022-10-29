//
//  CoreDataClass.swift
//  RecognizeColleagues
//
//  Created by Stephen on 2022/10/29.
//

import Foundation
import CoreData
import Cocoa

final class CoreDataClass {
    let context = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // read and load data
    private func loadDataBase() {
        let fetchRequestRead = NSFetchRequest<Colleagues>(entityName: "Colleagues")
        fetchRequestRead.fetchLimit = 1
        fetchRequestRead.predicate = NSPredicate(format: "", "")
        
        do {
            let colleaguesData = try context.fetch(fetchRequestRead)
            print(colleaguesData[0])
        } catch let readError {
            print(readError)
        }
    }
    
    // 新增資料
    private func newDataBase(name: String) {
        let colleagues = NSEntityDescription.insertNewObject(forEntityName: "Colleagues", into: context) as! Colleagues
        colleagues.chineseName = name
        do {
            try context.save()
            print(colleagues)
        } catch let catchError {
            print(catchError)
        }
    }
    
    // 更新
    private func uploadDataBase(chineseName: String) {
        let fetchRequestUpdate = NSFetchRequest<Colleagues>(entityName: "Colleagues")
        fetchRequestUpdate.fetchLimit = 1
        fetchRequestUpdate.predicate = NSPredicate(format: "", "")
        
        do {
            let colleaguesUpdate = try context.fetch(fetchRequestUpdate)
            colleaguesUpdate[0].chineseName = chineseName
            // 存回去
            do {
                try context.save()
            } catch let savrError {
                print("update save error: ", savrError)
            }
        } catch let fetchError {
            print(fetchError)
        }
    }
    
    // delete
    private func deleteDataBase() {
        let fetchRequestDelete = NSFetchRequest<Colleagues>(entityName: "Colleagues")
        fetchRequestDelete.fetchLimit = 1
        fetchRequestDelete.predicate = NSPredicate(format: "", "")
        
        do {
            let colleaguesDelete = try context.fetch(fetchRequestDelete)
            context.delete(colleaguesDelete[0])
            // 存回去
            do {
                try context.save()
            } catch let savrError {
                print("update save error: ", savrError)
            }
        } catch let fetchError {
            print(fetchError)
        }
    }
}
