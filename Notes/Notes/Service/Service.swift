//
//  Service.swift
//  Notes
//
//  Created by MAC BOOK on 13/09/22.
//

import Foundation
import UIKit


enum NetworkError: Error {
    case badURL
    case badHTTPResponse
    case imageNotFound
}

struct API {
    let session: URLSession
    init() {
        session = URLSession.shared
    }

    func loadItems(from url: String) async throws -> [NotesModel] {
        // Use the async variant of URLSession to fetch data
        guard let url = URL(string: url) else {
            throw NetworkError.badURL
        }
        let (data, response) = try await session.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.badHTTPResponse
        }
        let decoder = JSONDecoder()
        return try decoder.decode([NotesModel].self, from: data)
    }
    
    func downloadImage(with imageURL: String) async throws -> UIImage {
        guard let url = URL(string: imageURL) else {
            throw NetworkError.badURL
        }
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            throw NetworkError.badHTTPResponse
        }
        guard let image = UIImage(data: data) else {
            throw NetworkError.imageNotFound
        }
        return image
    }
    
}

