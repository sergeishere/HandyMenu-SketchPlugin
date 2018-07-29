//
//  Array.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 29/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Foundation
import os.log

extension Array {
    public func log() {
        os_log("Count:%d\nstartIndex:%d endIndex:%d\nItems:\n%{public}@",
               log: .handyMenuLog,
               type: .default,
               self.count,
               self.startIndex,
               self.endIndex,
               String(describing: self))
    }
}
