//
//  DotEnv.swift
//
//
//  Created by Noah Kamara on 03.05.21.
//

import Foundation

#if os(Linux)
import Glibc
#else
import Darwin
#endif


public struct DotEnv {
    public let filePath: String
    
    public init(fileAt path: String = "\(FileManager.default.currentDirectoryPath)/.env") throws {
        self.filePath = try DotEnv.buildFileUrl(from: path)
        load(path)
    }
    
    private static func buildFileUrl(from path: String) throws -> String {
        let fileManager = FileManager.default
        var path = path
        if path.first != "/" {
            path = fileManager.currentDirectoryPath + "/" + path
        }
        
        if !fileManager.fileExists(atPath: path) {
            throw Errors.FileNotFound(path)
        }
        
        return path
    }
    
    /// Load .env file and set variables
    /// - Parameter path: FilePath
    private func load(_ path: String) {
        if let contents = try? String(contentsOfFile: filePath) {
            // Split Contents into lines
            let lines = contents.split(whereSeparator: ["\n", "\r\n"].contains).map(String.init)
            
            for line in lines {
                var line = line
                
                // Ignore Comments
                if line.contains("#") {
                    if line.first == "#" {
                        continue
                    }
                    line.removeSubrange(line.firstIndex(of: "#")!..<line.endIndex)
                }
                
                // Ignore Empty Lines
                if line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                    continue
                }
                
                // Extract key & value
                let parts = line.split(separator: "=", maxSplits: 1).map(String.init)
                let key = parts[0].trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                var value = parts[1].trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                
                if value.first == "\"" && value.last == "\"" {
                    value.remove(at: value.startIndex)
                    value.remove(at: value.index(before: value.endIndex))
                }
                
//                // remove surrounding quotes from value & convert remove escape character before any embedded quotes
//                if value[value.startIndex] == "\"" && value[value.index(before: value.endIndex)] == "\"" {
//                    value.remove(at: value.startIndex)
//                    value.remove(at: value.index(before: value.endIndex))
//                    value = value.replacingOccurrences(of:"\\\"", with: "\"")
//                }
                
                // Set Environment Variable
                setenv(key, value, 1)
            }
        }
    }
    
    
    /// Returns the value for `key` in the environment, returning the default if not present
    /// - Parameter key: key
    /// - Returns: value for `key`
    public func value(_ key: String, _ default: String? = nil) -> String? {
        guard let value = getenv(key) else {
            return `default`
        }
        return String(validatingUTF8: value)
    }
    
    
    /// Returns the integer value for `key` in the environment, returning default if not present
    /// - Parameter key: key
    /// - Parameter key: key
    /// - Returns: value for `key`
    public func int(for key: String, _ default: Int? = nil) -> Int? {
        guard let value = value(key) else {
            return `default`
        }
        return Int(value) ?? `default`
    }
    
    /// Returns the boolean value for `key` in the environment, returning default if not present
    /// - Parameter key: key
    /// - Parameter key: key
    /// - Returns: value for `key`
    public func bool(for key: String, _ default: Bool? = nil) -> Bool? {
        guard let value = value(key) else {
            return `default`
        }
        
        // Parse Boolean Value
        switch value.lowercased() {
            case let v where ["true", "yes", "1"].contains(v): return true
            case let v where ["false", "no", "0"].contains(v): return false
            default: return `default`
        }
    }
    
    /// Array subscript access
    public subscript(key: String) -> String? {
        get {
            return value(key)
        }
    }
    
    
    
    /// Retrieve all variables
    /// - Returns: Dictionary of env variables
    public func all() -> [String: String] {
        return ProcessInfo.processInfo.environment
    }
}
