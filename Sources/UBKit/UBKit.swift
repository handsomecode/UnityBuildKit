import Foundation

public final class UBKit {

    private let arguments: [String]
    private var kitManager: UBKitManager!

    private let fileManager = FileManager.default

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run(_ completion: @escaping ((Error?) -> Void)) {
        let workingPath = fileManager.currentDirectoryPath
        do {
            if let fileData = fileManager.contents(atPath: workingPath.appending("/ubconfig.json")) {
                if let configJSON = try JSONSerialization.jsonObject(with: fileData, options: .allowFragments) as? [String : String] {
                    guard let config = Config(json: configJSON) else {
                            completion(UBKitError.invalidConfigFile)
                            return
                    }
                    kitManager = UBKitManager(config: config)
                }

            }
        } catch {
            completion(UBKitError.invalidFolder(workingPath.appending("/ubconfig.json")))
        }

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
