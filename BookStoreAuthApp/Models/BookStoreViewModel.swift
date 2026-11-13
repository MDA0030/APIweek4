//
//  BookStoreViewModel.swift
//  BookStoreAuthApp
//
//  Created by matt on 11/11/26.
//

import Foundation
import Combine

enum LoadingProgress {
    case idle, loading, loaded, empty
    case failed(String)
}

@MainActor

final class BookStoreViewModel: ObservableObject {
    
    @Published var books: [BookQualities] = []
    @Published var currentState: LoadingProgress = .idle
    
    func loadingBooks(query: String = "subject:fantasy") async {
        currentState = .loading
        
        var fldComponents = URLComponents(string: "https://openlibrary.org/search.json")
        fldComponents?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: "20"),
            URLQueryItem(name: "fields", value: "key,title,author_name,first_publish_year,cover_i,subject,first_sentence,number_of_pages_median")
            ]
        guard let url = fldComponents?.url else {
            currentState = .failed("Invalid URL.")
            return
        }
        
        do {
            var idRequest = URLRequest(url: url)
            
            idRequest.setValue("LoreandMythPage/1.0", forHTTPHeaderField: "User=Agent")
            
            let (data, response) = try await URLSession.shared.data(for: idRequest)
            
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                currentState = .failed("Server error (\(http.statusCode)).")
                return
            }
            let decoded = try JSONDecoder().decode(ResponseFromSearch.self, from: data)
            
            books = decoded.books ?? []
            currentState = books.isEmpty ? .empty : .loaded
        } catch is DecodingError {
            currentState = .failed("Unable to show data from server.")
        } catch {
            currentState = .failed("Problem with network: \(error.localizedDescription)")
            
            
        }
    }
}

@MainActor

final class BooksDetailViewModel : ObservableObject {
    @Published var isLoading = false
    @Published var bookDescription: String?
    
    func loadBook(for book: BookQualities) async {
        guard let url = book.moreDeatiledURL else {return}
        isLoading = true
        defer { isLoading = false }
        
        do {
            var idRequest = URLRequest(url: url)
            idRequest.setValue("LoreandMythPage/1.0", forHTTPHeaderField: "User-Agent")
            let (data, _) = try await URLSession.shared.data(for: idRequest)
            bookDescription = try JSONDecoder().decode(objDetail.self, from: data).bookDescription
        } catch {
            bookDescription = nil
        }
        
    }
    
}
    
    

