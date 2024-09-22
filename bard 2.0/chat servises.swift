//
//  chat servises.swift
//  bard 2.0
//
//  Created by owen hilkemeijer on 10/6/2024.
//


import Foundation
import SwiftUI
import GoogleGenerativeAI
import Combine
import SwiftData

@Observable
class ChatService {
    private var proModel = GenerativeModel(name: "gemini-1.5-flash-latest", apiKey: "add api key", systemInstruction: "Your name is Brian")
    private var proVisionModel = GenerativeModel(name: "gemini-1.5-flash-latest", apiKey: "add api key", systemInstruction: "Your name is Brian")
    
    private(set) var messages = [ChatMessage]()
    private(set) var loadingResponse = false
    
    // Store the conversation history
    private var conversationHistory = [ChatMessage]()
    
    // Function to reset the chat
    func newChat() {
        conversationHistory.removeAll()
        messages.removeAll()
        // Optionally, clear stored data in SwiftData
    }
    
    func sendMessage(message: String, imageData: [Data]) async {
        loadingResponse = true
        
        // Create and save user's message to SwiftData
        let userMessage = ChatMessage(role: .user, message: message, images: imageData)
//        context.insert(userMessage)
        conversationHistory.append(userMessage)
        
        // Append user message to messages list
        messages.append(userMessage)
        
        // Placeholder for AI's response
        let modelMessagePlaceholder = ChatMessage(role: .model, message: "")
        messages.append(modelMessagePlaceholder)
        
        do {
            let chatModel = imageData.isEmpty ? proModel : proVisionModel
            
            var images = [any ThrowingPartsRepresentable]()
            for data in imageData {
                if let compressedData = UIImage(data: data)?.jpegData(compressionQuality: 0.1) {
                    images.append(ModelContent.Part.jpeg(compressedData))
                }
            }
            
            let conversation = conversationHistory.map { "\($0.role == .user ? "User" : "Model"): \($0.message)" }.joined(separator: "\n")
            let fullMessage = "\(conversation)\nUser: \(message)"
            
            let outputStream = chatModel.generateContentStream(fullMessage, images)
            for try await chunk in outputStream {
                guard let text = chunk.text else {
                    return
                }
                let lastChatMessageIndex = messages.count - 1
                messages[lastChatMessageIndex].message += text
            }
            
            if let lastMessage = messages.last {
                lastMessage.timestamp = Date() // Update the timestamp
//                try context.save() // Save the updated message in SwiftData
                conversationHistory.append(lastMessage)
            }
            
            loadingResponse = false
        } catch {
            loadingResponse = false
            messages.removeLast()
            let errorMessage = ChatMessage(role: .model, message: "Something went wrong. Please try again.")
            messages.append(errorMessage)
//            context.insert(errorMessage)
            print(error.localizedDescription)
        }
    }
}
