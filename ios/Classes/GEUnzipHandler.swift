import Foundation
import SSZipArchive
import GalaceanEffects

/**
 * GEUnzipProtocol 的实现类
 * 使用 SSZipArchive 来处理 ZIP 文件解压
 */
class GEUnzipHandler: NSObject, GEUnzipProtocol {
    
    private var currentZipPath: String?
    
    func unzipOpenFile(_ zipFile: String!) -> Bool {
        currentZipPath = zipFile
        // SSZipArchive 不需要显式打开文件，只需要在解压时提供路径
        return FileManager.default.fileExists(atPath: zipFile)
    }
    
    func unzipFile(to path: String!, overWrite overwrite: Bool) -> Bool {
        guard let zipPath = currentZipPath else {
            print("GEUnzipHandler: No zip file opened")
            return false
        }
        
        do {
            try SSZipArchive.unzipFile(atPath: zipPath, toDestination: path, overwrite: overwrite, password: nil)
            print("GEUnzipHandler: Successfully unzipped to \(path ?? "")")
            return true
        } catch {
            print("GEUnzipHandler: Failed to unzip - \(error.localizedDescription)")
            return false
        }
    }
    
    func unzipCloseFile() -> Bool {
        currentZipPath = nil
        return true
    }
}

/**
 * 初始化 GEUnzipManager
 * 在插件加载时调用
 */
class GEUnzipSetup {
    static let shared = GEUnzipSetup()
    private var handler: GEUnzipHandler?
    
    private init() {}
    
    func setup() {
        if handler == nil {
            handler = GEUnzipHandler()
            GEUnzipManager.shared().unzipDelegate = handler
            print("GEUnzipManager configured with SSZipArchive handler")
        }
    }
}

