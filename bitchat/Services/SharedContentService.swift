//
//  SharedContentService.swift
//  bitchat
//
//  This is free and unencumbered software released into the public domain.
//  For more information, see <https://unlicense.org>
//

import Foundation

class SharedContentService {
    
    static let shared = SharedContentService()
    
    private init() {}
    
private struct UserDefaultsKeys {
    static let sharedContent = "sharedContent"
    static let sharedContentDate = "sharedContentDate"
    static let sharedContentType = "sharedContentType"
    static let appGroup = "group.chat.bitchat"
}

private enum SharedContentType: String {
    case url = "url"
    case text = "text"
}

func checkForSharedContent(chatViewModel: ChatViewModel) {
    guard let userDefaults = UserDefaults(suiteName: UserDefaultsKeys.appGroup) else {
        print("DEBUG: Failed to access app group UserDefaults")
        return
    }
    
    guard let sharedContent = userDefaults.string(forKey: UserDefaultsKeys.sharedContent),
          let sharedDate = userDefaults.object(forKey: UserDefaultsKeys.sharedContentDate) as? Date else {
        print("DEBUG: No shared content found in UserDefaults")
        return
    }
    
    // Only process if shared within last 30 seconds
    guard Date().timeIntervalSince(sharedDate) < 30 else {
        print("DEBUG: Shared content is too old, ignoring")
        return
    }
    
    let contentType = userDefaults.string(forKey: UserDefaultsKeys.sharedContentType) ?? "text"
    
    clearSharedContent(in: userDefaults)
    
    Task {
        await notifyUser(contentType: contentType, chatViewModel: chatViewModel)
        await sendSharedContent(sharedContent, contentType: contentType, chatViewModel: chatViewModel)
    }
}

private func clearSharedContent(in userDefaults: UserDefaults) {
    userDefaults.removeObject(forKey: UserDefaultsKeys.sharedContent)
    userDefaults.removeObject(forKey: UserDefaultsKeys.sharedContentType)
    userDefaults.removeObject(forKey: UserDefaultsKeys.sharedContentDate)
    userDefaults.synchronize()
}

@MainActor
private func notifyUser(contentType: String, chatViewModel: ChatViewModel) {
    let systemMessage = BitchatMessage(
        sender: "system",
        content: "preparing to share \(contentType)...",
        timestamp: Date(),
        isRelay: false
    )
    chatViewModel.messages.append(systemMessage)
}

@MainActor
private func sendSharedContent(_ content: String, contentType: String, chatViewModel: ChatViewModel) async {
    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
    
    if contentType == SharedContentType.url.rawValue {
        processURLContent(content, chatViewModel: chatViewModel)
    } else {
        chatViewModel.sendMessage(content)
    }
}

private func processURLContent(_ content: String, chatViewModel: ChatViewModel) {
    if let data = content.data(using: .utf8),
       let urlData = try? JSONSerialization.jsonObject(with: data) as? [String: String],
       let url = urlData["url"],
       let title = urlData["title"] {
        let markdownLink = "👇 [\(title)](\(url))"
        chatViewModel.sendMessage(markdownLink)
    } else {
        chatViewModel.sendMessage("Shared link: \(content)")
    }
}
}
