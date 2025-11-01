import Foundation

enum StorageManagerError: Error {
    case cannotCreateDirectory
    case failedWritingIndex
}

struct StorageResult {
    let folderURL: URL
    let approxSizeBytes: Int64
}

struct StorageManager {
    private let fileManager: FileManager
    private let session: URLSession

    init(fileManager: FileManager = .default, session: URLSession = .shared) {
        self.fileManager = fileManager
        self.session = session
    }

    func baseDirectory() throws -> URL {
        let appSupport = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let base = appSupport.appendingPathComponent("PagePocket", isDirectory: true)
        if !fileManager.fileExists(atPath: base.path) {
            try fileManager.createDirectory(at: base, withIntermediateDirectories: true)
        }
        return base
    }

    func pageDirectory(for id: UUID) throws -> URL {
        let dir = try baseDirectory().appendingPathComponent(id.uuidString, isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    func assetsDirectory(for id: UUID) throws -> URL {
        let dir = try pageDirectory(for: id).appendingPathComponent("assets", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    func saveIndexHTML(_ data: Data, for id: UUID) throws -> URL {
        let indexURL = try pageDirectory(for: id).appendingPathComponent("index.html", isDirectory: false)
        do {
            try data.write(to: indexURL, options: .atomic)
            return indexURL
        } catch {
            throw StorageManagerError.failedWritingIndex
        }
    }

    func downloadAssets(id: UUID, mapping: [URL: String]) async throws -> Int64 {
        let pageDir = try pageDirectory(for: id)
        var totalBytes: Int64 = 0

        // Limit concurrency to avoid spikes
        let semaphore = AsyncSemaphore(value: 4)

        try await withThrowingTaskGroup(of: Int64.self) { group in
            for (remoteURL, relativePath) in mapping {
                group.addTask {
                    await semaphore.wait()
                    do {
                        let destination = pageDir.appendingPathComponent(relativePath)
                        let (bytes, _) = try await download(remoteURL: remoteURL, to: destination)
                        await semaphore.signal()
                        return bytes
                    } catch {
                        await semaphore.signal()
                        throw error
                    }
                }
            }

            for try await bytes in group {
                totalBytes += bytes
            }
        }

        return totalBytes
    }

    func assetFileURL(for id: UUID, relativePath: String) throws -> URL {
        try pageDirectory(for: id).appendingPathComponent(relativePath)
    }

    private func download(remoteURL: URL, to destination: URL) async throws -> (Int64, URL) {
        var request = URLRequest(url: remoteURL)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        let (tempURL, response) = try await session.download(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            // Non-fatal: treat as zero-byte and skip move
            return (0, destination)
        }
        // Ensure parent exists
        let parent = destination.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: parent.path) {
            try fileManager.createDirectory(at: parent, withIntermediateDirectories: true)
        }
        // Replace if exists
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        try fileManager.moveItem(at: tempURL, to: destination)
        let attr = try? fileManager.attributesOfItem(atPath: destination.path)
        let bytes = (attr?[.size] as? NSNumber)?.int64Value ?? 0
        return (bytes, destination)
    }
}

// Simple async semaphore for concurrency limiting
private actor AsyncSemaphore {
    private let maxPermits: Int
    private var permits: Int

    init(value: Int) {
        self.maxPermits = value
        self.permits = value
    }

    func wait() async {
        while permits == 0 {
            await Task.yield()
        }
        permits -= 1
    }

    func signal() {
        permits = min(permits + 1, maxPermits)
    }
}


