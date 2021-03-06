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
public final class ComlinkReceiver {

    private let comlink: Comlink

    /**
    The designated initializer.

    - parameter applicationGroupIdentifier:  The application group identifier
    - parameter directoryName:               The directory which holds the objects that will be sent
    */
    public init(applicationGroupIdentifier: String, directoryName: String) {
        self.comlink = Comlink(applicationGroupIdentifier: applicationGroupIdentifier, directoryName: directoryName)
    }

    /**
    This method returns the object with a specific identifier.

    - parameter identifier:  The identifier
    */
    public func retrieveObject(identifier: String) -> AnyObject? {
        return comlink.retrieveObject(identifier)
    }

    /**
    This method removes the object associated with an identifier.

    - parameter identifier:  The identifier
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

    - parameter     listener:    The listener
    - parameter     identifier:  The identifier
    */
    public func addListener(listener: ComlinkListener, identifier: String) {
        comlink.addListener(listener, identifier: identifier)
    }

    /**
    This method removes a listener associated with a specific identifier.

    - parameter     listener:    The listener
    - parameter     identifier:  The identifier
    */
    public func removeListener(listener: ComlinkListener, identifier: String) {
        comlink.removeListener(listener, identifier: identifier)
    }
}
