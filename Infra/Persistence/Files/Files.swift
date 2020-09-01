//
//  Files.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/8/5.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import Foundation
import CoreData

struct Files {
    static func cloudSyncToken() -> URL {
        let url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent(Bundle.appName,
            isDirectory: true
        )
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(
                    at: url,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                let message = "Could not create persistent container URL"
                print("###\(#function): \(message): \(error)")
            }
        }
        return url.appendingPathComponent("token.data", isDirectory: false)
    }
}
