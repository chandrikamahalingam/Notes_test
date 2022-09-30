//
//  NotesModel.swift
//  Notes
//
//  Created by MAC BOOK on 15/09/22.
//

import Foundation

struct NotesModel: Codable, Hashable {
    var id: String?
    var archived: Bool?
    var title: String?
    var body: String?
    var created_time: Double?
    var image: String?
}
