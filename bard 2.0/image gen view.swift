//
//  image gen view.swift
//  bard 2.0
//
//  Created by owen hilkemeijer on 25/7/2024.
//

import Foundation
import SwiftUI
import OpenAISwift
class ImageGeneratorViewModel: ObservableObject {
    @Published var image: UIImage?
    @Published var errorMessage: String?
    
    private let networkManager = NetworkManager()
    
    func generateImage(prompt: String) {
        networkManager.generateImage(prompt: prompt) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let response = try? JSONDecoder().decode(DALLEImageResponse.self, from: data),
                       let imageData = Data(base64Encoded: response.data.first?.image ?? "") {
                        self?.image = UIImage(data: imageData)
                    } else {
                        self?.errorMessage = "Failed to decode image"
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}


struct DALLEImageResponse: Codable {
    let data: [DALLEImage]
}

struct DALLEImage: Codable {
    let image: String
}

struct ContentView2: View {
    @StateObject private var viewModel = ImageGeneratorViewModel()
    @State private var prompt: String = ""
    
    var body: some View {
        VStack {
            TextField("Enter prompt", text: $prompt)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                viewModel.generateImage(prompt: prompt)
            }) {
                Text("Generate Image")
            }
            .padding()
            
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView2()
}
