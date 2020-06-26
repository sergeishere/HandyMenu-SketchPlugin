//
//  OSLog.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 29/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//
import os.log

extension OSLog {
    static public var handyMenuLog: OSLog {
        return OSLog(subsystem: "com.sergeishere.plugins", category: "Handy Menu")
    }
}
