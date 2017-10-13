//
//  viewControllerFile.swift
//  UEKit
//
//  Created by Eric Miller on 10/11/17.
//

import Foundation

extension File {

    class func viewControllerFile() -> Data? {
        let file = """
        import UIKit

        class ViewController: UIViewController {

            private var unityView: UIView?

            override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.startUnity()

                    if let newUnityView = UnityGetGLView() {
                        newUnityView.translatesAutoresizingMaskIntoConstraints = false
                        self.view.addSubview(newUnityView)

                        let leading = newUnityView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor)
                        let trailing = newUnityView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
                        let top = newUnityView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
                        let bottom = newUnityView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
                        NSLayoutConstraint.activate([leading, trailing, top, bottom])
                        self.unityView = newUnityView
                    }
                }
            }
        }
        """.data(using: .utf8)
        return file
    }
}
