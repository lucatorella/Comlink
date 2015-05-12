//
//  ComlinkSender.swift
//  Comlink
//
//  Created by Luca Torella on 12/05/2015.
//

import Foundation

/**
Class used to send objects.
Objects must conform to the NSCoding protocol since they will be persisited.
*/
@objc public final class ComlinkSender {

    private let comlink: Comlink

    /**
    The designated initializer.

    :param: applicationGroupIdentifier  The application group identifier
    :param: directoryName               The directory which holds the objects that will be sent
    */
    public init(applicationGroupIdentifier: String, directoryName: String) {
        self.comlink = Comlink(applicationGroupIdentifier: applicationGroupIdentifier, directoryName: directoryName)
    }

    /**
    This method passes an object associated to an identifier.

    :param: object      The message object to be passed
    :param: identifier  The identifier
    */
    public func sendObject(object: NSCoding, identifier: String) {
        comlink.sendObject(object, identifier: identifier)
    }

    /**
    This method removes the object associated with an identifier.

    :param: identifier  The identifier
    */
    public func deleteObject(identifier: String) {
        comlink.deleteObject(identifier)
    }

    /**
    This method removes all the objects inside the directory provided during the initialization.
    */
    public func deleteAllObjects() {
        comlink.deleteAllObjects()
    }
}
