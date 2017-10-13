import Foundation
import UBKit

let kit = UBKit()
kit.run { (error) in
    guard error == nil else {
        print("\n----------")
        print("💥 An error was encountered while creating your projects")
        print(error!.localizedDescription)
        exit(1)
    }

    print("\n----------")
    print("👍 Successfully created your iOS and Unity projects!")
    print("The iOS project is located under iOS/")
    print("The Unity project is located under Unity/")
    print("For more information, visit <https://github.com/handsomecode/UnityBuildKit>\n\n")
    exit(0)
}

dispatchMain()
