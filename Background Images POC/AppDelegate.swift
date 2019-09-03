//
//  AppDelegate.swift
//  Background Images POC
//
//  Created by Felipe Correa on 8/26/19.
//  Copyright © 2019 Felipe Correa. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.applicationIconBadgeNumber = 0
        let _ = NotificationManager.shared
//        let _ = BackgroundDownloader.shared
        // Override point for customization after application launch.
        printBackgroundItems()
//        SessionWatcher.shared.purge()
//        let context = BackgroundDownloaderContext<BackgroundItem>()
//        let values = context.loadAllPendingItems()
//        let valuie = BackgroundDownloaderContext<BackgroundItem>()
//        let item = valuie.loadItem(withURL: URL(string: "/id/8/2000/2000")!)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        killApp()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        BackgroundUploader.shared.backgroundCompletionHandler = completionHandler
        BackgroundDownloader.shared.backgroundCompletionHandler = completionHandler
    }

}

extension AppDelegate {
    private func killApp() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            print("App is about to quit")
            if let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
                debugPrint("Gallery assets will be saved to: \(documentsPath)")
            }
            exit(0)
        }
    }
}
