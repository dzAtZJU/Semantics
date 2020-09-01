//
//  RealmSyncErrorHandler.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/9/1.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//
import RealmSwift

let realmSyncErrorHandler: ErrorReportingBlock = { error, session in
    let syncError = error as! SyncError
    switch syncError.code {
    case .clientResetError:
        let (path, clientResetToken) = syncError.clientResetInfo()!
        let partitionValue = session!.configuration()!.partitionValue as! String
        SemUserDefaults.setRealmPath(partitionValue: partitionValue, path)
//        RealmSpace.invalidate(partitioinValue: partitionValue)
//        SyncSession.immediatelyHandleError(clientResetToken)
        print("[ClientReset] local realm\(session!.configuration()!.partitionValue) will be at \(path)")
        
        let alert = UIAlertController(title: "Data ReSync", message: "Restart App", preferredStyle: .alert)
        alert.addAction(title: "OK", style: .default, isEnabled: true) { _ in
            exit(-1)
        }
        UIApplication.shared.windows.first!.rootViewController!.present(alert, animated: true)
    default:
        fatalError()
    }
}
