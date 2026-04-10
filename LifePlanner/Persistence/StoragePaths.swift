import Foundation

struct StoragePaths {
    let baseDirectory: URL

    var remindersURL: URL {
        baseDirectory.appendingPathComponent("reminders.json")
    }

    var trainingDataURL: URL {
        baseDirectory.appendingPathComponent("training-data.json")
    }

    static var `default`: StoragePaths {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let directory = appSupport.appendingPathComponent("LifePlanner", isDirectory: true)
        return StoragePaths(baseDirectory: directory)
    }
}
