//
//  File.swift
//  
//
//  Created by Zhou Wei Ran on 2021/1/4.
//

import Sentry

public enum SemLog {
    public static func capture(message: String) {
        print(message)
        SentrySDK.capture(message: message)
    }
    
    public static func capture(error: Error) {
        print("\(error)")
        SentrySDK.capture(error: error)
    }
}


