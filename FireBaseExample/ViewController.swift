//
//  ViewController.swift
//  FireBaseExample
//
//  Created by sae hun chung on 2022/10/05.
//

import UIKit
import FirebaseAnalytics

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Analytics.logEvent("setID", parameters: [
//          "name": "고래밥",
//          "full_text": "안녕하세요"
//        ])
//
//        Analytics.setDefaultEventParameters([
//            "level_Name": "3"
//        ])
    }

//    @IBAction func crashClicked11(_ sender: UIButton) {
//
//    }
//
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewController viewWillAppear")
    }
    
    @IBAction func profileButtonTapped(_ sender: UIButton) {
        present(ProfileViewController(), animated: true)
    }
    
    @IBAction func settingButtonTapped(_ sender: UIButton) {
        navigationController?.pushViewController(SettingViewController(), animated: true)
    }
}

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ProfileViewController viewWillAppear")
    }
    
}

class SettingViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .brown
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("SettingViewController viewWillAppear")
    }

}



extension UIViewController {
    
    var topViewController: UIViewController? {
        return self.topViewController(currentViewController: self)
    }
    
    // 최상단 뷰컨트롤러를 판단해주는 메서드
    func topViewController(currentViewController: UIViewController) -> UIViewController {
        
        // 1. Tabbar
        // 2. Navigation
        // 3. rootViewController 가 아닌 VC
        
        if let tabBarController = currentViewController as? UITabBarController, let selectedViewController = tabBarController.selectedViewController {
            // 1. Tabbar Controller 일 경우
            
            return self.topViewController(currentViewController: selectedViewController)
        } else if let navigationController = currentViewController as? UINavigationController, let visibleViewController = navigationController.visibleViewController {
            // 2. Navigation ViewController 일 경우
            
            return self.topViewController(currentViewController: visibleViewController)
        } else if let presentedViewController = currentViewController.presentedViewController {
            // 3. rootViewController 가 아닌 VC
            
            return self.topViewController(currentViewController: presentedViewController)
        } else {
            return currentViewController
        }
    }
}

extension UIViewController {
    
    class func swizzleMethod() {
        
        let origin = #selector(viewWillAppear)
        let change = #selector(changeViewWillAppear)
        
        guard let originMethod = class_getInstanceMethod(UIViewController.self, origin),
              let changeMethod = class_getInstanceMethod(UIViewController.self, change) else {
            print("함수를 찾을 수 없거나, 오류발생!!")
            return
        }
        
        method_exchangeImplementations(originMethod, changeMethod) // 두 메서드 교체하는 코드
    }
    
    @objc func changeViewWillAppear() {
        print("Method Swizzled SUCCEED")
    }
}
