//
//  YouTubePlayerView.swift
//  TheRecipe
//
//  Created by Elena Zisina on 11/7/24.
//


import SwiftUI
import WebKit

// Create a struct that conforms to UIViewRepresentable to use WKWebView in SwiftUI
struct YouTubePlayerView: UIViewRepresentable {
    var videoUrl: String? // The ID of the YouTube video

    func makeUIView(context: Context) -> WKWebView {
        // Create the WKWebView instance
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let videoUrl else {
            // Stop loading if no videoID is provided (e.g., view is being removed or no longer needed)
            uiView.stopLoading()
            return
        }
        if let videoID = parseVideoId(from: videoUrl) {
            // Construct the embed URL for YouTube video
            let embedURLString = "https://www.youtube.com/embed/\(videoID)"
            
            if let url = URL(string: embedURLString) {
                let request = URLRequest(url: url)
                uiView.load(request)
            }
        }
    }
    
    func dismantleUIView(_ uiView: WKWebView, coordinator: Self.Coordinator) {
        // This is called when the view is removed, stop any ongoing loading here
        uiView.stopLoading()
    }
    
    private func parseVideoId(from url: String?) -> String? {
        if url == nil || url?.isEmpty == true { return nil }
        let urlComponents = URLComponents(string: url!)
        return urlComponents?.queryItems?.first(where: {$0.name == "v"})?.value
    }
}

