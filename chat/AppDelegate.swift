//
//  AppDelegate.swift
//  chat
//
//  Created by Christian Ayscue on 12/16/14.
//  Copyright (c) 2014 coayscue. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        return true
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Parse.setApplicationId("Itk7vLzjpOy9Si8dLymTgge5FrofknrxlsY4FB9A", clientKey: "gaGYvIqmK6mU6D0BYQtqFW1eUEcbSqO3ONfMWOyw")
        
        //makes sure the user is not a chat creator
        
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "chatCreator")
        
            //creates and saves the lock info to get past the lock screen on launch
            var lockInfo: [String: AnyObject] = ["locked": true, "password": "", "hint": ""]
            NSUserDefaults.standardUserDefaults().setObject(lockInfo, forKey: "lockInfo")
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "chatOrder")
        
        
        //creates a new "test" chat
        var date: NSDate = NSDate(timeIntervalSinceNow: 0)
        NSUserDefaults.standardUserDefaults().setObject(["People": "You, P1", "Messages": [["date": date, "string": "Yo wasup", "person": "P1"]], "YourID":"P2", "Password":"pword", "Seen":false], forKey: "Test Chat")
        
        //insert the chat ID at the head of the charOrder array
        var chatOrder = [String]()
        chatOrder.insert("Test Chat", atIndex: 0)
        NSUserDefaults.standardUserDefaults().setObject(chatOrder, forKey: "chatOrder")
        NSUserDefaults.standardUserDefaults().synchronize()
        //_________________________________________
        
        //makes the status bar light
        application.setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Store the deviceToken in the current installation and save it to Parse.
        var currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["global"]
        currentInstallation.saveInBackgroundWithBlock(nil)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        
        //reloads the tableView of the present view controller
        var navController = self.window!.rootViewController as UINavigationController
        var viewController  = navController.visibleViewController as UIViewController
        for view in viewController.view.subviews{
            //if the view has a tableview
            if view.isKindOfClass(UITableView){
                if view.isKindOfClass(UIBubbleTableView){
                    //if notification is sent to this chat, reload the data, else show an alert
                    if userInfo["chatID"] as String == selectedChat{
                        (view.parentViewController as MessagingViewController).incomingMessage()
                    }else{
                        var alert = UIAlertController(title: "New Message", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                        var action = UIAlertAction(title: "View", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                            navController.popViewControllerAnimated(true)
                            view.dismissViewControllerAnimated(true, completion: nil)
                        })
                        var action2 = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action2) -> Void in
                            view.dismissViewControllerAnimated(true, completion: nil)
                        })
                        alert.addAction(action)
                        alert.addAction(action)
                        view.presentViewController(alert, animated: true, completion: nil)
                    }
                }else{
                    //we are on chats view - refresh the table
                    (view.parentViewController as ChatsViewController).refreshTable()
                }
            }
        }
        
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        var lockInfos: Dictionary<String, AnyObject>? = NSUserDefaults.standardUserDefaults().dictionaryForKey("lockInfo") as Dictionary<String, AnyObject>?
        
        if var locked: Bool = lockInfos?["locked"] as? Bool{
            if locked == true {
                var navController = self.window!.rootViewController as UINavigationController
                var viewController  = navController.visibleViewController as UIViewController
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                var lockViewController = mainStoryboard.instantiateViewControllerWithIdentifier("lockScreen") as LockScreenViewController
                viewController.presentViewController(lockViewController, animated: false, completion: nil)
            }
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

