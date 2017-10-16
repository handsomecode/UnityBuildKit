//
//  viewControllerFile.swift
//
//  Copyright (c) 2017 Handsome
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
