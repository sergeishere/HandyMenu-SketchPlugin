//
//  InstalledPluginsCollectionView.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 02/08/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

import Cocoa

class InstalledPluginsCollectionView: NSCollectionView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func resignFirstResponder() -> Bool {
        self.deselectAll(self)
        return super.resignFirstResponder()
    }
}
