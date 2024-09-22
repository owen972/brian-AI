//
//  dale.swift
//  bard 2.0
//
//  Created by owen hilkemeijer on 24/7/2024.
//

import Foundation
import OpenAISwift

class NetworkManager {
    let apiKey = "not this"
    
    func generateImage(prompt: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: "https://api.openai.com/v1/images/generations") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = ["prompt": prompt, "n": 1, "size": "512x512"]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])
                completion(.failure(error))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }
}
