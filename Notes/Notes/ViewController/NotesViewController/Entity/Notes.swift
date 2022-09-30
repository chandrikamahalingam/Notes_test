//
//  Notes+CoreDataClass.swift
//  Notes
//
//  Created by MAC BOOK on 15/09/22.
//
//

import Foundation
import CoreData

enum DecoderConfigurationError: Error {
  case missingManagedObjectContext
}

@objc(Notes)
public class Notes: NSManagedObject, Decodable {
    enum CodingKeys: CodingKey {
        case id, archived, title, body, created_time, image
    }
    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw DecoderConfigurationError.missingManagedObjectContext
        }
        self.init(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.archived = try container.decode(Bool.self, forKey: .archived)
        self.title = try container.decode(String.self, forKey: .title)
        self.body = try container.decode(String.self, forKey: .body)
        self.image = try container.decode(String.self, forKey: .image)
    }
}
extension CodingUserInfoKey {
  static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}
