//
//  Comlink.swift
//  Comlink
//
//  Created by Luca Torella on 12/05/2015.
//

import Foundation
import CoreFoundation

private let notificationName = "ComlinkNotificationName"

final class Comlink {

    private var applicationGroupIdentifier: String
    private var directoryName: String
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
        unregisterForEveryNotification()
    }

    func sendObject(object: NSCoding, identifier: String) {
        if identifier.characters.count == 0 {
            return
        }
        if let filePath = filePath(identifier) {
            let data = NSKeyedArchiver.archivedDataWithRootObject(object)
            let success = data.writeToFile(filePath, atomically: true)
            if success {
                sendNotificationWithIdentifier(identifier)
            }
        }
    }

    func retrieveObject(identifier: String) -> AnyObject? {
        if identifier.characters.count == 0 {
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
            do {
                try fileManager.removeItemAtPath(filePath)
            } catch _ {}
        }
    }

    func deleteAllObjects() {
        if let directory = directoryPath() {
            do {
                let files = try fileManager.contentsOfDirectoryAtPath(directory)
                for maybeFilePath in files {
                    let filePath = maybeFilePath as String
                    try fileManager.removeItemAtPath(filePath)
                }
            } catch _ {}
        }
    }

    func addListener(listener: ComlinkListener, identifier: String) {
        OSSpinLockLock(&lock)
        let maybeListenersHashTable = listeners[identifier]

        if maybeListenersHashTable == nil {
            registerForNotifications(identifier)
        }

        let listenersHashTable = maybeListenersHashTable ?? NSHashTable.weakObjectsHashTable()
        listenersHashTable.addObject(listener)

        listeners[identifier] = listenersHashTable
        OSSpinLockUnlock(&lock)
    }

    func removeListener(listener: ComlinkListener, identifier: String) {
        OSSpinLockLock(&lock)
        let maybeListenersHashTable = listeners[identifier]
        if let listenersHashTable = maybeListenersHashTable {
            listenersHashTable.removeObject(listener)

            if listenersHashTable.count == 0 {
                listeners[identifier] = nil
                unregisterForNotification(identifier)
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
            do {
                try fileManager.createDirectoryAtPath(directoryPath, withIntermediateDirectories: true, attributes: nil)
            } catch _ {}
            return directoryPath
        } else {
            return nil
        }
    }

    private func filePath(identifier: String) -> String? {
        assert(identifier.characters.count > 0, "identifier shouldn't be an empty string")

        let directory = directoryPath()
        return directory?.stringByAppendingPathComponent("\(identifier).archive")
    }

    // CFNotificationCenter

    private func registerForNotifications(identifier: String) {
        let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterAddObserver(notificationCenter,
            nil,
            { (_, _, name, _, _) -> Void in
                let identifier = String(name)
                NSNotificationCenter.defaultCenter().postNotificationName(notificationName,
                    object: nil,
                    userInfo: ["identifier" : identifier])
            },
            identifier,
            nil,
            .DeliverImmediately)
    }

    private func unregisterForNotification(identifier: String) {
        let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterRemoveObserver(notificationCenter, nil, identifier as CFString, nil)
    }

    private func unregisterForEveryNotification() {
        let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterRemoveEveryObserver(notificationCenter, nil)
    }

    private func sendNotificationWithIdentifier(identifier: String) {
        let notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
        CFNotificationCenterPostNotification(notificationCenter,
            identifier as CFString,
            nil,
            nil,
            CFBooleanGetValue(true))
    }
}
