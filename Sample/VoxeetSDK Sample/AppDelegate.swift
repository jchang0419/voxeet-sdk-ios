//
//  AppDelegate.swift
//  VoxeetSDK Sample
//
//  Created by Corentin Larroque on 22/04/16.
//  Copyright © 2016 Voxeet. All rights reserved.
//

import UIKit
import VoxeetSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, VTSessionDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Voxeet SDK initialization.
        VoxeetSDK.shared.initialize(consumerKey: "YOUR_CONSUMER_KEY", consumerSecret: "YOUR_CONSUMER_SECRET")
        
        // Example of public variables to change the conference behavior.
        VoxeetSDK.shared.notification.push.type = .none
        VoxeetSDK.shared.conference.defaultBuiltInSpeaker = true
        VoxeetSDK.shared.conference.defaultVideo = false
        VoxeetSDK.shared.conference.audio3D = true
        
        // Session delegate.
        VoxeetSDK.shared.session.delegate = self
        
        return true
    }
    
    /*
     *  MARK: VTSessionDelegate example
     */
    
    func sessionUpdated(state: VTSessionState) {
        // Debug.
        print("[Sample] \(String(describing: AppDelegate.self)).\(#function).\(#line) - State: \(state.rawValue)")
    }
}
