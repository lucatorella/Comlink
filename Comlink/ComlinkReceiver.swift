//
//  ComlinkReceiver.swift
//  Comlink
//
//  Created by Luca Torella on 12/05/2015.
//

import Foundation

/**
This is the protocol that needs to be implemented to register for changes to an object with a specific identifier.
*/
@objc public protocol ComlinkListener {
    func objectChanged(object: AnyObject)
}

/**
Class used to receive objects.
Objects must conform to the NSCoding protocol since they will be persisited.
*/
@objc public final class ComlinkReceiver {

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
    This method returns the object with a specific identifier.

    :param: identifier  The identifier
    */
    public func retrieveObject(identifier: String) -> AnyObject? {
        return comlink.retrieveObject(identifier)
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

    /**
    This method adds a listener that will be called whenever an object with a specific identifier has been sent.

    :param:     identifier  The identifier
    :listener:  listener    The listener
    */
    public func addListener(identifier: String, listener: ComlinkListener) {
        comlink.addListener(identifier, listener: listener)
    }

    /**
    This method removes a listener associated with a specific identifier.

    :param: identifier  The identifier
    */
    public func removeListener(identifier: String, listener: ComlinkListener) {
        comlink.removeListener(identifier, listener: listener)
    }
}
