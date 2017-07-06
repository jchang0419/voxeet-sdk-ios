# Voxeet iOS SDK

<p align="center">
<img src="http://www.voxeet.com/wp-content/uploads/2016/05/SDK-API-768x180.png" alt="Voxeet SDK logo" title="Voxeet SDK logo" width="700"/>
</p>

The Voxeet SDK is a Swift library allowing users to:

  - Create demo/normal conferences
  - Join conferences
  - Change sounds angle and direction for each conference user
  - Broadcast messages to other participants
  - Send and receive video stream
  - Record and replay a conference
  - Receive call with CallKit

## Table of contents

  1. [Requirements](#requirements)
  1. [Sample Application](#sample-application)
  1. [Installing the iOS SDK](#installing-the-ios-sdk)
  1. [SDK Initialization](#sdk-initialization)
  1. [SDK Usage](#sdk-usage)
  1. [VTAudioSound Usage](#vtaudiosound-usage)
  1. [Available delegates / callbacks](#available-delegates-callbacks)
  1. [Publish your app with the Voxeet SDK](#publish-your-app-with-the-voxeet-sdk)

## Requirements

  - iOS 9.0+
  - Xcode 8.0+
  - Swift 3.1+

## Sample Application

A sample application is available on this [public repository](https://github.com/voxeet/voxeet-ios-sdk/tree/master/Sample) on GitHub.
You can also use a ready to go UI with the **VoxeetConferenceKit** available at this [link](https://github.com/voxeet/voxeet-ios-conferencekit) which use this SDK.

## Installing the iOS SDK

You need to disable **Bitcode** in your Xcode target settings: 'Build Settings' -> 'Enable Bitcode' -> No

To enable **background mode**, go to your target settings -> 'Capabilities' -> 'Background Modes'  
- Turn on 'Audio, AirPlay and Picture in Picture'  
- Turn on 'Voice over IP'

If you want to support CallKit (receiving incoming call when application is killed) and VoIP push notifications, also enable 'Push Notifications' (you will need to send your voip push certificates to Voxeet).

<p align="center">
<img src="http://cdn.voxeet.com/images/VoxeetConferenceKitCapabilitiesXCode2.png" alt="Capabilities" title="Capabilities" width="500"/>
</p>

Privacy **permissions**, in your plist add two new keys: 
- Privacy - Camera Usage Description
- Privacy - Microphone Usage Description

### Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ sudo gem install cocoapods --pre
```

To integrate VoxeetSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
use_frameworks!

target "YourTarget" do
       pod 'VoxeetSDK', '~> 1.0'
end
```

Then, run the following command:

```bash
$ pod install
```

### Installation with Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate VoxeetSDK into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "voxeet/voxeet-ios-sdk" ~> 1.0
```

Run `carthage update` to build the framework and drag the built `VoxeetSDK.framework` into your Xcode project *(needs to be dropped in 'Embedded Binaries' and 'Linked Frameworks and Libraries')*.
More information at [https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos).

### Manually

Checkout this repository and find the `VoxeetSDK.framework` inside the VoxeetSDK folder.
Drag and drop the framework inside your project and add it to 'Embedded Binaries' and 'Linked Frameworks and Libraries' sections in your main target.

## SDK Initialization

Initialize the SDK in the AppDelegate.swift of your application:

```swift
import VoxeetSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
        // Initialization of the Voxeet SDK.
        VoxeetSDK.shared.initializeSDK(consumerKey: "consumerKey", consumerSecret: "consumerSecret")

        return true
    }
    
    ...
}
```

## SDK Usage

### Initializing

```swift
VoxeetSDK.shared.initializeSDK(consumerKey: "consumerKey", consumerSecret: "consumerSecret")

// With all parameters.
VoxeetSDK.shared.initializeSDK(consumerKey: "consumerKey", consumerSecret: "consumerSecret", userInfo: nil, automaticallyOpenSession: true)
```

If you use external login like O365, LDAP, or custom login to retrieve contact details it's possible to also add your contact ID with the display name, the photo URL avatar and any kind of extra information.
This allows you to ask guest users to introduce themselves and provide their display name and for your authenticated users in your enterprise or for your clients the ID that can be retrieved from O365 (name, department, etc).

```swift
VoxeetSDK.shared.initializeSDK(consumerKey: "consumerKey", consumerSecret: "consumerSecret", userInfo: ["externalId": "1234", "externalName": "User", "externalPhotoUrl": "http://voxeet.com/voxeet-logo.jpg"])
```

### Openning a session *(manually)*

Openning a session is like a login. However you need to have initialized the SDK with `automaticallyOpenSession` sets to **false**.

```swift
VoxeetSDK.shared.initializeSDK(consumerKey: "consumerKey", consumerSecret: "consumerSecret", automaticallyOpenSession: false)
```

By passing the userID, it will log your user into our servers with your ID (you can additionally pass some extra information with the `userInfo` parameter). This method can be usefull if you want to implement **CallKit** (VoIP push notifications) because once the session is openned, you can receive notifications.

*If you don't open a session it will automatically open a new one when joinning a conference for example.*

```swift
VoxeetSDK.shared.openSession(userID: userID, userInfo: userInfo, completion: { (error) in
})
```

### Closing a session *(manually)*

Closing a session is like a logout, it will stop the socket and stop sending VoIP push notification.

```swift
VoxeetSDK.shared.closeSession(completion: { (error) in
})
```

### Creating a demo conference

```swift
VoxeetSDK.shared.conference.createDemo { (error) in 
}
```

### Creating a conference

Manually create a conference (the join method implicitly creates one if it's not already created).

```swift
VoxeetSDK.shared.conference.create(success: { (json) in
    guard let confID = json?["conferenceId"] as? String, 
          let confAlias = json?["conferenceAlias"] as? String else {
        return
    }
}, fail: { (error) in
})
```

You can also pass some optionals parameters when you create a conference such as `conferenceAlias` (examples: ["conferenceAlias": "myCustomConferenceAlias", "conferenceType": "standard", "metadata": ...]).
Those parameters are specifics to a conference (not to be confused with userInfos for a user).

```swift
VoxeetSDK.shared.conference.create(parameters: ["conferenceAlias": "myCustomConferenceAlias", "conferenceType": "standard", "metadata": ...], success: { (json) in
}, fail: { (error) in
})
```

### Joining a conference

If you join a conference that doesn't exist, it will automatically create one. Basically the join method can be used instead of the create conference method above if you don't need custom preferences.

```swift
VoxeetSDK.shared.conference.join(conferenceID: conferenceID, success: { (json) in
}, fail: { (error) in
})
```

There are some optionals parameters too:
- **video** parameter: Starts own video by default.
- **userInfo** parameter: With this dictionary, you can pass additional information linked to your user. For example if the user is only in "listener" mode you can add: `["participantType": "listener"]`. 
Other examples: ["externalName": "User", "externalPhotoUrl": "http://voxeet.com/voxeet-logo.jpg", ...] if the SDK isn't initilized with userInfo or if the session isn't openned yet.

```swift
VoxeetSDK.shared.conference.join(conferenceID: conferenceID, video: true, userInfo: ["participantType": "listener"], success: { (json) in
}, fail: { (error) in
})
```

### Leaving a conference

```swift
VoxeetSDK.shared.conference.leave { (error) in
}
```

### Sending broadcast message in a conference

```swift
VoxeetSDK.shared.conference.sendBroadcastMessage("message", completion: { (error) in
})
```

To receive a broadcast message, you can use 'messageReceived' method from VTConferenceDelegate (see below: `Available delegates / callbacks` section).

### Getting a specific conference status

```swift
VoxeetSDK.shared.conference.status(conferenceID: conferenceID, success: { (json) in
}, fail: { (error) in
})
```

### Subscribe to a conference to get its status within a notification

The goal of this method is to have the conference's status updates (participant added/removed, conference destroyed, ...) within a notification and without joinning it.

*The conference needs to be created before using this method.*

Notification's name: `VTConferenceStatusUpdated`

```swift
init() {
    NotificationCenter.default.addObserver(self, selector: #selector(conferenceStatusUpdated), name: .VTConferenceStatusUpdated, object: nil)
    
    VoxeetSDK.shared.conference.subscribe(conferenceID: conferenceID, completion: { (error) in 
    })
}

func conferenceStatusUpdated(_ notification: Notification) {
    //
}
```

### Getting the history of a specific conference

```swift
VoxeetSDK.shared.conference.history(conferenceID: conferenceID, success: { (json) in
}, fail: { (error) in
})
```

### Getting own conference histories

You can retrieve 0 to 40 events per pages.
Use lastMeetingId & lastTimestamp to handle paging.

```swift
VoxeetSDK.shared.conference.histories(nbEvents: 10, lastConferenceID: nil, lastConferenceTimestamp: nil, success: { (json) in
}, fail: { (error) in
})
```

### Inviting users

Invite some users in a conference. If CallKit is enabled, it will ring on invited users' devices with the Apple incoming call user interface.

```swift
VoxeetSDK.shared.conference.invite(conferenceID: confID, ids: userIDs, completion: { (error) in
})
```

### Declining a call

Decline a call. Others users receive a VTParticipantUpdated notification.

```swift
VoxeetSDK.shared.conference.decline(conferenceID: confID, completion: { (error) in
})
```

### Start / Stop recording the current conference

To record you need to be in the conference.

```swift
// Start recording.
VoxeetSDK.shared.conference.startRecording(conferenceID: conferenceID, completion: { (error) in
})

// Stop recording.
VoxeetSDK.shared.conference.stopRecording(conferenceID: conferenceID, completion: { (error) in
})
```

### Replay a recording conference

You need to start and stop a record before calling this method.
It works like createDemo or join methods for example, it will automatically start the recorded conference like a normal one.

```swift
VoxeetSDK.shared.conference.replay(conferenceID: conferenceID, completion: { (error) in
})
```

You can pass an additional argument to start the record conference after x milliseconds.

```swift
// Replay a conference without the first second.
VoxeetSDK.shared.conference.replay(conferenceID: conferenceID, offset: 1000, completion: { (error) in
})
```

### Getting own user

Returns a tuple of the users' ID and information.

```swift
let ownUser = VoxeetSDK.shared.conference.getOwnUser()
```

### Getting current conference users

Returns an array of tuples containing current users' ID and information.

```swift
let users = VoxeetSDK.shared.conference.getUsers()
```

### Getting a specific user's information

```swift
let infos = VoxeetSDK.shared.conference.getUserInfo("userID")
```

### Changing user position

```swift
// Values for angle and distance are between: angle = [-1, 1] and distance = [0, 1]
VoxeetSDK.shared.conference.setUserPosition(angle: 0, distance: 0, userID: "userID")
```

```swift
VoxeetSDK.shared.conference.setUserAngle(0, userID: "userID")
```

```swift
VoxeetSDK.shared.conference.setUserDistance(0, userID: "userID")
```

### Getting a specific user position

```swift
let (angle, distance) = VoxeetSDK.shared.conference.getUserPosition(userID: "userID")
```

### Muting / Unmuting a user

```swift
VoxeetSDK.shared.conference.muteUser(true, userID: "userID")
```

### Checking if a user is muted

```swift
let isMuted = VoxeetSDK.shared.conference.isUserMuted(userID: "userID")
```

### Getting the participant's voice level

```swift
VoxeetSDK.shared.conference.getVoiceLevel(userID: "userID")
```

### Switching between BuiltInSpeaker and BuildInReceiver

```swift
VoxeetSDK.shared.conference.switchDeviceSpeaker()

// You can also force the BuiltInSpeaker (true) / BuildInReceiver (false)
VoxeetSDK.shared.conference.switchDeviceSpeaker(forceBuiltInSpeaker: true)
```

You can also start the VoxeetSDK with the built in speaker enable by default or not by using this method before initializing the SDK:

```swift
VoxeetSDK.shared.defaultBuiltInSpeaker = true / false
```

### Flipping the device camera (front / back)

```swift
VoxeetSDK.shared.conference.flipCamera()
```

### Attaching a media stream to a renderer

```swift
VoxeetSDK.shared.conference.attachMediaStream(stream, renderer: videoRenderer)
```

### Unattaching a media stream to a renderer

If the video renderer is removed from the UI, there is no need to call this method.
This method can be useful to switch between several streams on the same video renderer.

```swift
VoxeetSDK.shared.conference.unattachMediaStream(stream, renderer: videoRenderer)
```

### Starting / Stopping a video stream for a specific user

You can't force starting a video from a specific user other than you. But you can "mute / unmute" the video of someone with its user ID.

```swift
// Start own video.
VoxeetSDK.shared.conference.startVideo(userID: myUserID, completion: { (error) in
})

// Stop own video.
VoxeetSDK.shared.conference.stopVideo(userID: myUserID, completion: { (error) in
})
```

### Connecting the SDK with the API *(manually)*

This optional method is automatically called before a regular request anyway. For example 'createDemo' calls internally 'connect'.

```swift
VoxeetSDK.shared.connect { (error) in
}
```

### Disonnecting the SDK with the API *(manually)*

This optional method can help to disconnect the SDK if you don't use it anymore.

```swift
VoxeetSDK.shared.disconnect { (error) in
}
```

### CallKit

CallKit is enabled by default, you can disable it before initializing the VoxeetSDK:
```swift
VoxeetSDK.shared.enableCallKit = false
```

Some notifications can be interesting using along CallKit to update UI: `VTCallKitStarted`, `VTCallKitUpdated` and `VTCallKitEnded`.

In order to handle VoIP push notifications bellow iOS 10, this AppDelegate extension is needed:

```swift
/*
 *  MARK: - Voxeet VoIP push notifications
 */

extension AppDelegate {
    /// Usefull bellow iOS 10.
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        VoxeetConferenceKit.shared.application(application, didReceive: notification)
    }
    
    /// Usefull bellow iOS 10.
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        VoxeetConferenceKit.shared.application(application, handleActionWithIdentifier: identifier, for: notification, completionHandler: completionHandler)
    }
}
```

## Available delegates / callbacks

### Session

```swift
class myClass: VTSessionStateDelegate {
    init() {
        // Session delegate.
        VoxeetSDK.shared.sessionStateDelegate = self
    }

    func sessionStateChanged(state: VTSessionState) {
    }
}
```
or
```swift
VoxeetSDK.shared.sessionStateChanged = { (state) in
}
```

### Conference

```swift
class myClass: VTConferenceDelegate {
    init() {
        // Conference delegate.
        VoxeetSDK.shared.conference.delegate = self
    }
    
    func participantAdded(userID: String, userInfo: [String: Any], stream: MediaStream) {
    }
    
    func participantUpdated(userID: String, userInfo: [String: Any], stream: MediaStream) {
    }
    
    func participantRemoved(userID: String, userInfo: [String: Any]) {
    }
    
    func messageReceived(userID: String, userInfo: [String: Any], message: String) {
    }
    
    func screenShareStarted(userID: String, stream: MediaStream) {
    }
    
    func screenShareStopped(userID: String) {
    }
}
```
or
```swift
VoxeetSDK.shared.conference.participantAdded = { (userID, userInfo, stream) in
}

VoxeetSDK.shared.conference.participantUpdated = { (userID, userInfo, stream) in
}

VoxeetSDK.shared.conference.participantRemoved = { (userID, userInfo) in
}

VoxeetSDK.shared.conference.messageReceived = { (userID, userInfo, message) in
}

VoxeetSDK.shared.conference.screenShareStarted = { (userID, stream) in
}

VoxeetSDK.shared.conference.screenShareStopped = { (userID) in
}
```

## Available enums

### Session state:

```swift
public enum VTSessionState {
    case disconnected
    case connecting
    case connected
    case reconnecting
}
```

### Error handler:

```swift
public enum VTErrorType: ErrorType {
    case credential(String)
    case internalServer
    case accessToken
    case noLiveConference
    case leaveConference
    case createConference
    case joinConference
    case sendBroadcastMessage
    case fileNotFound
    case statusCode(Int?)
    case serverError(String?)
    case error(Error?)
}
```

### Notification handler:

Here is an example to handle the notification pushed by the Voxeet SDK (each time a notification is pushed, a log display the name of this one):

```bash
[VoxeetSDK] Voxeet notification: \(NotificationName) (you can register to this notification to handle it)
```

```swift
init() {
    NotificationCenter.default.addObserver(self, selector: #selector(myFunc), name: Notification.Name("NotificationName"), object: nil)
}

dynamic func myFunc(notification: Notification) {
    // Get JSON.
    guard let userInfo = notification.userInfo?.values.first as? Data else {
        return
    }
    let json = try? JSONSerialization.jsonObject(with: userInfo, options: .mutableContainers)
}
```

Voxeet's notifications can be handled easily like this: Notification.Name.VTConferenceStatusUpdated.
This extension is not exhaustive.

```swift
extension Notification.Name {
    public static let VTOwnConferenceCreatedEvent = Notification.Name("OwnConferenceCreatedEvent")
    public static let VTConferenceStatusUpdated = Notification.Name("ConferenceStatusUpdated")
    public static let VTConferenceDestroyedPush = Notification.Name("ConferenceDestroyedPush")
    public static let VTBroadcastMessageReceived = Notification.Name("ConferenceMessageReceived")
    public static let VTOwnUserInvitedEvent = Notification.Name("OwnUserInvitedEvent")
    public static let VTInvitationReceivedEvent = Notification.Name("InvitationReceivedEvent")
    
    public static let VTOfferCreated = Notification.Name("OfferCreated")
    public static let VTParticipantAdded = Notification.Name("ParticipantAdded")
    public static let VTParticipantUpdated = Notification.Name("ParticipantUpdated")
    public static let VTParticipantSwitched = Notification.Name("ParticipantSwitched")

    public static let VTCallKitStarted = Notification.Name("VTCallKitStarted")
    public static let VTCallKitUpdated = Notification.Name("VTCallKitUpdated")
    public static let VTCallKitEnded = Notification.Name("VTCallKitEnded")
}
```

## VTAudioSound Usage

VTAudioSound helps you to play a 3D audio sound into your application.  
The sound must be encoded in **mono** to be played spatialized.

### Initializing

```swift
var sound: VTAudioSound?

// Initializes VTAudioSound.
sound = try? VTAudioSound(forResource: "myFile", ofType: "mp3")
```

### Playing sound

```swift
try? sound?.play() {
    // Debug.
    print("::DEBUG:: The sound has finished being played.")
}
```

### Stopping sound

```swift
sound?.stop()
```

### Looping on the current sound

```swift
sound?.loop = true
```

### Setting / Getting volume

```swift
// The range of valid values are from 0.0 to 1.0.
sound?.volume = 1
```

```swift
let volume = sound?.volume
```

### Setting / Getting angle

```swift
// The range of valid values are from -1.0 to 1.0.
sound?.angle = 0
```

```swift
let angle = sound?.angle
```

### Setting / Getting distance

```swift
// The range of valid values are from 0.0 to 1.0.
sound?.distance = 0
```

```swift
let distance = sound?.distance
```

## Publish your app with the Voxeet SDK

The SDK is built to compile with the simulator **AND** generic iOS device.
Since november 2016, Apple has stopped supporting "Fat libraries" (simulator and device compiled together) like this one.
So when you want to publish your app, you will need to execute a script that delete the simulator support:

```bash
APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

# This script loops through the frameworks embedded in the application and
# removes unused architectures.
find "$APP_PATH" -name '*.framework' -type d | while read -r FRAMEWORK
do
    FRAMEWORK_EXECUTABLE_NAME=$(defaults read "$FRAMEWORK/Info.plist" CFBundleExecutable)
    FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME"
    echo "Executable is $FRAMEWORK_EXECUTABLE_PATH"

    EXTRACTED_ARCHS=()

    for ARCH in $ARCHS
    do
        echo "Extracting $ARCH from $FRAMEWORK_EXECUTABLE_NAME"
        lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH"
        EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH")
    done

    echo "Merging extracted architectures: ${ARCHS}"
    lipo -o "$FRAMEWORK_EXECUTABLE_PATH-merged" -create "${EXTRACTED_ARCHS[@]}"
    rm "${EXTRACTED_ARCHS[@]}"

    echo "Replacing original executable with thinned version"
    rm "$FRAMEWORK_EXECUTABLE_PATH"
    mv "$FRAMEWORK_EXECUTABLE_PATH-merged" "$FRAMEWORK_EXECUTABLE_PATH"

done
```

You can add this script in the `Build Phases` of your project.
Here is a tutorial if you want more details: http://ikennd.ac/blog/2015/02/stripping-unwanted-architectures-from-dynamic-libraries-in-xcode/

## Version

1.0.5

## Tech

The Voxeet iOS SDK uses a number of open source projects to work properly:

* [Starscream](https://github.com/daltoniam/Starscream) - Starscream is a conforming WebSocket (RFC 6455) client library in Swift for iOS and OSX.
* [Alamofire](https://github.com/Alamofire/Alamofire) - Alamofire is an HTTP networking library written in Swift.
* [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) - SwiftyJSON makes it easy to deal with JSON data in Swift.
* [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift) - Crypto related functions and helpers for Swift implemented in Swift.

© Voxeet, 2017