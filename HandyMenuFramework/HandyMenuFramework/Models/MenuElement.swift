//
//  MenuElement.swift
//  HandyMenuFramework
//
//  Created by Sergey Dmitriev on 16/07/2018.
//  Copyright © 2018 Sergey Dmitriev. All rights reserved.
//

public enum MenuElement {
    case command(MenuElementCommand)
    case separator
    
    private enum CodingKeys:String, CodingKey {
        case type
        case data
    }
}

extension MenuElement: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .command(let value):
            try container.encode("command", forKey: .type)
            try container.encode(value, forKey: .data)
        case .separator:
            try container.encode("separator", forKey: .type)
        }
    }
}

extension MenuElement: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "command":
            let data = try container.decode(MenuElementCommand.self, forKey: .data)
            self = .command(data)
        default:
            self = .separator
        }
    }
}

public struct MenuElementCommand:Codable {
    public var name:String
    public var commandID:String
    public var pluginID:String
}
