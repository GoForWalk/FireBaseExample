//
//  AppDelegate.swift
//  FireBaseExample
//
//  Created by sae hun chung on 2022/10/05.
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        aboutRealmMigration()
        
        UIViewController.swizzleMethod()
        
        FirebaseApp.configure()
        
        // 알림 시스템에 앱을 등록
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        // Message Delegate 설정
        Messaging.messaging().delegate = self
        
        // 현재 등록된 토큰 가져오기
        // 실제 유저는 항상 필요한 코드는 아니다.
//        Messaging.messaging().token { token, error in
//          if let error = error {
//            print("Error fetching FCM registration token: \(error)")
//          } else if let token = token {
//            print("FCM registration token: \(token)")
//          }
//        }
//
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


extension AppDelegate {
    
    func aboutRealmMigration() {
//        let config = Realm.Configuration(schemaVersion: 1, deleteRealmIfMigrationNeeded: false) // 앱의 Realm 구조가 바뀌었을때 -> 마이그레이션이 필요한 경우 모든 Data 삭제
        // 출시때는 deleteRealmIfMigrationNeeded = false
        // Realm Browser 닫고 다시 열기
        
        let config = Realm.Configuration(schemaVersion: 6) { migration, oldSchemaVersion in
            
            if oldSchemaVersion < 1 {
                // 컬럼 단순 추가, 삭제의 경우에는 별도의 코드는 필요 없다.
            }
            
            if oldSchemaVersion < 2 {
                // 컬럼 단순 추가, 삭제의 경우에는 별도의 코드는 필요 없다.
            }
            
            if oldSchemaVersion < 3 {
                // Rename
                migration.renameProperty(onType: Todo.className(), from: "importance", to: "favorite")
            }
            
            if oldSchemaVersion < 4 {
                // 두 데이터를 합쳐서 새로운 데이터를 만들어서 columm을 추가
                migration.enumerateObjects(ofType: Todo.className()) { oldObject, newObject in
                    
                    guard let newObject, let oldObject else { return }
                    
                    
                    newObject["userDescription"] = "안녕하세요 \(oldObject["title"]!) 의 중요도는 \(oldObject["favorite"]!) 입니다!"
                }
            }
            
            if oldSchemaVersion < 5 {
                // 새로 생성된 columm에 초기값 넣기
                migration.enumerateObjects(ofType: Todo.className()) { _, newObject in
                    
                    guard let newObject else { return }
                    newObject["count"] = 100
                }
            }
            
            if oldSchemaVersion < 6 {
                // columm의 타입 변경
                migration.enumerateObjects(ofType: Todo.className()) { oldObject, newObject in
                    guard let newObject, let oldObject else { return }
                    
                    // new optional, old optional
                    newObject["favorite"] = oldObject["favorite"]
                    
                    // new required, old optional
                    //                    newObject["favorite"] = oldObject["favorite"] ?? 0.0
                }
                
            }
            
        }
        
        Realm.Configuration.defaultConfiguration = config
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // 포그라운드 알림 수신: 로컬/푸시
    // 카카오톡: 푸시마다 설정, 화면마다 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // 특정화면에 있다면, 포그라운드 푸시 띄우기 금지~~
        
        guard let viewContoller = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController?.topViewController else { return }
        
        if viewContoller is SettingViewController {
            // 셋팅뷰 일때는 포그라운드 상태에서는 알람이 울리지 않는다.
            completionHandler([])
        } else {
            // .banner, .list: iOS14+
            completionHandler([.badge, .sound, .banner, .list])
        }
        
        
    }
    
    // 푸시 클릭: 앱 내에서 화면 전환 & 이벤트 실행
    // 사용자가 푸시를 클릭했을 경우, 수신 확인 가능
    // 푸시를 클릭한 순간!! 동작하는 메서드
    
    // 특정 푸시를 클릭하면, 특정 상세 화면으로 화면 전환
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("사용자가 푸시를 클릭했습니다.")
        
        print(response.notification.request.content.body) // 알림 메세지 정보
        print(response.notification.request.content.userInfo)
        
        let userInfo = response.notification.request.content.userInfo
        
        // 미리 설정한 키값들에 대해서 이후 처리과정을 등록할 수 있다.
        if userInfo[AnyHashable("sesac")] as? String == "project" {
            print("새싹프로젝트 입니다.")
        } else {
            print("Nothing")
        }
        
        // 최상단 뷰를 확인하는 코드
        guard let viewController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController?.topViewController else { return }
        
        print(viewController)
        
        if viewController is ViewController { // is,as TypeCasting
            viewController.navigationController?.pushViewController(SettingViewController(), animated: true)
        }
        
        if viewController is ProfileViewController {
            viewController.dismiss(animated: true)
        }
        
        if viewController is SettingViewController {
            viewController.navigationController?.popViewController(animated: true)
        }
        
        
    }
    
    
}

extension AppDelegate: MessagingDelegate {
    
    // 토큰 갱신 모니터링: 토큰 정보가 언제 바뀌는지
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")

      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

}
