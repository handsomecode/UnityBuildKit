import Foundation

public final class UBKit {
    private let arguments: [String]
    private let kitManager: UBKitManager

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
        guard arguments.count == 3 else {
            print("FAILURE: Invalid number of arguments.")
            exit(1)
        }
        let projectName = arguments[1]
        let iOSBundleIdentifier = arguments[2]
        kitManager = UBKitManager(projectName: projectName, bundleIdentifier: iOSBundleIdentifier)
    }

    public func run(_ completion: @escaping ((Error?) -> Void)) {
        let taskResult = kitManager.performTasks()
        guard taskResult == .success else {
            completion(taskResult.error)
            return
        }

        completion(nil)
    }

    class func validatePath(_ path: String, isDirectory: Bool) -> Bool {
        if isDirectory {
            var directory = ObjCBool(false)
            let folderExists = FileManager.default.fileExists(atPath: path, isDirectory: &directory)
            return folderExists && directory.boolValue
        } else {
            return FileManager.default.fileExists(atPath: path)
        }
    }
}
