//
//  Comlink.swift
//  Comlink
//
//  Created by Luca Torella on 12/05/2015.
//

import Foundation
import CoreFoundation

final class Comlink {

    private var applicationGroupIdentifier: String
    private var directoryName: String
    private let notificationName = "ComlinkNotificationName"
    private lazy var listeners = Dictionary<String, NSHashTable>()
    private lazy var fileManager = NSFileManager()
    private var lock : OSSpinLock = OS_SPINLOCK_INIT

    init(applicationGroupIdentifier: String, directoryName: String) {
        self.applicationGroupIdentifier = applicationGroupIdentifier
        self.directoryName = directoryName
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "didReceiveNotification:",
            name: notificationName,
            object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        COMNotificationHelper.unregisterForEveryNotification()
    }

    func sendObject(object: NSCoding, identifier: String) {
        if count(identifier) == 0 {
            return
        }
        if let filePath = filePath(identifier) {
            let data = NSKeyedArchiver.archivedDataWithRootObject(object)
            let success = data.writeToFile(filePath, atomically: true)
            if success {
                COMNotificationHelper.sendNotificationWithIdentifier(identifier)
            }
        }
    }

    func retrieveObject(identifier: String) -> AnyObject? {
        if count(identifier) == 0 {
            return nil
        }
        if let filePath = filePath(identifier), let data = NSData(contentsOfFile: filePath) {
            return NSKeyedUnarchiver.unarchiveObjectWithData(data)
        } else {
            return nil
        }
    }

    func deleteObject(identifier: String) {
        if let filePath = filePath(identifier) {
            fileManager.removeItemAtPath(filePath, error: nil)
        }
    }

    func deleteAllObjects() {
        if let directory = directoryPath(), let files = fileManager.contentsOfDirectoryAtPath(directory, error: nil) {
            for maybeFilePath in files {
                let filePath = maybeFilePath as! String
                fileManager.removeItemAtPath(filePath, error: nil)
            }
        }
    }

    func addListener(identifier: String, listener: ComlinkListener) {
        OSSpinLockLock(&lock)
        let maybeListenersHashTable = listeners[identifier]

        if maybeListenersHashTable == nil {
            COMNotificationHelper.registerForNotificationsWithIdentifier(identifier)
        }

        let listenersHashTable = maybeListenersHashTable ?? NSHashTable.weakObjectsHashTable()
        listenersHashTable.addObject(listener)

        listeners[identifier] = listenersHashTable
        OSSpinLockUnlock(&lock)
    }

    func removeListener(identifier: String, listener: ComlinkListener) {
        OSSpinLockLock(&lock)
        let maybeListenersHashTable = listeners[identifier]
        if let listenersHashTable = maybeListenersHashTable {
            listenersHashTable.removeObject(listener)

            if listenersHashTable.count == 0 {
                listeners[identifier] = nil
                COMNotificationHelper.unregisterForNotificationsWithIdentifier(identifier)
            } else {
                listeners[identifier] = listenersHashTable
            }
        }
        OSSpinLockUnlock(&lock)
    }

    dynamic func didReceiveNotification(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String : String]
        let identifier = userInfo["identifier"]!
        if let listenersHashTable = listeners[identifier] {
            let listenersArray = listenersHashTable.allObjects as! [ComlinkListener]
            for listener in listenersArray {
                if let object: AnyObject = retrieveObject(identifier) {
                    listener.objectChanged(object)
                }
            }
        }
    }

    // MARK: Private methods

    private func directoryPath() -> String? {
        let url = fileManager.containerURLForSecurityApplicationGroupIdentifier(applicationGroupIdentifier)
        let directoryPath = url?.path?.stringByAppendingPathComponent(directoryName)

        if let directoryPath = directoryPath {
            fileManager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil, error: nil)
            return directoryPath
        } else {
            return nil
        }
    }

    private func filePath(identifier: String) -> String? {
        assert(count(identifier) > 0, "identifier shouldn't be an empty string")

        let directory = directoryPath()
        return directory?.stringByAppendingPathComponent("\(identifier).archive")
    }
}
