# Comlink
Comlink allows you to send objects between the main app and the extension (i.e. Watch Extension).
Comlink persists via NSKeyedArchiver the object that needs to be sent and then post a Darwin Notification. 
The notification will be catched by Comlink which will unarchive the object and deliver it to its listeners. 
Any object can register itself to be notified whenever an object is sent.
Please note that the objects passed must conform to the NSCoding.

### Background
A comlink was a portable device that transferred voice signals from one location to another (http://starwars.wikia.com/wiki/Comlink).

### Requirements
- iOS 7.0+ / Mac OS X 10.9+
- Xcode 6.3

### Installation
Embedded frameworks require a minimum deployment target of iOS 8 or OS X Mavericks.
To use Comlink with a project targeting iOS 7, you must include all the Source files directly in your project and add COMNotificationHelper.h to your bridging header.
To use Comlink your app and its extensions must support shared app groups.

### Usage

#### Send objects
```swift
comlinkSender = ComlinkSender(applicationGroupIdentifier: "application.group.identifier", directoryName: "directory name")
comlinkSender.sendObject(object, identifier: "identifier") // object must conform to the NSCoding protocol
```

#### Receive objects
```swift
comlinkReceiver = ComlinkReceiver(applicationGroupIdentifier: "application.group.identifier", directoryName: "directory name")
comlinkReceiver.addListener(self, identifier: "identifier")
```
...
```swift
func objectChanged(object: AnyObject) {
	let obj = comlinkReceiver.retrieveObject("identifier")
	// do something with obj
}
```

#### Sending and receiving images

To send an image saved it in the shared folder and then send a notification containing the path

```swift
let path = // use containerURLForSecurityApplicationGroupIdentifier to create the path 
UIImageJPEGRepresentation(image, 100).writeToFile(path, atomically: true)
comlinkSender.sendObject(path, identifier: "image available")

```

To retrieve the image

```swift
func objectChanged(object: AnyObject) {
	let path = comlinkReceiver.retrieveObject("identifier") as! String
	let maybeData = NSData(contentsOfFile: path)
	if let data = maybeData {
		image = UIImage(data: data)
	}
}
```
