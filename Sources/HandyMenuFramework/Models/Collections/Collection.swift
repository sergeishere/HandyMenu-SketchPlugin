//
//  MenuGroup.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 16/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

public struct Collection:Codable {
    public var title: String
    public var shortcut: Shortcut
    public var items:[CollectionItem]
    public var autoGrouping: Bool
}

extension Collection {
    public static var emptyCollection:Collection {
        return Collection(title: "New Collection", shortcut: .empty, items: [], autoGrouping: true)
    }
}
