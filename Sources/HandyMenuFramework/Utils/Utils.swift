//
//  Utils.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 30/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//
import os.log

fileprivate func lastPath(_ path: String) -> String {
    return path.components(separatedBy: "/").last ?? ""
}

public func plugin_log(_ message: String = "", filePath: String = #file, line: UInt = #line, function: String = #function,_ args: CVarArg...) {
    let file = URL(fileURLWithPath: filePath).lastPathComponent
    let finalMessage = String(format: message, args)
    os_log("%{public}@ → %{public}@(%u):\n\n%{public}@", log: .handyMenuLog, type: .default, file,function,line, finalMessage)
}

