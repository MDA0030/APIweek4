//
//  BookModels.swift
//  BookStoreAuthApp
//
//  Created by matt on 11/12/26.
//

import Foundation

struct ResponseFromSearch: Decodable {
    let books: [BookQualities]?
    
    enum CodingKeys: String,CodingKey {
        case books = "docs"
    }
}

struct BookQualities: Decodable, Identifiable {
    let id: String
    let title: String?
    let authorName: [String]?
    let publishedYear: Int?
    let coverNumber: Int?
    let bookSubject: [String]?
    let firstSentence: [String]?
    let pageCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "key"
        case title
        case bookSubject = "subject"
        case authorName = "author_name"
        case publishedYear = "first_publish_year"
        case coverNumber = "cover_i"
        case firstSentence = "first_sentence"
        case pageCount = "number_of_pages_median"
    }
    
    var authorText: String {
        guard let bookAuthors = authorName, !bookAuthors.isEmpty else {
            return "Author is Unknown"
        }
        return bookAuthors.joined(separator: ", ")
    }
    
    var showTitle: String { title ?? "No title" }
    
    var showPublishedYear: String {
        publishedYear.map { String($0) } ?? "No Date"
    }
    

    var showCategory: String { bookSubject?.first ?? "No Category" }

    var fullUrl: URL? {URL(string: "https://openlibrary.org\(id).json") }

    var urlOfImg: URL? {
        guard let coverNumber else { return nil }
        return URL(string: "https://covers.openlibrary.org/b/id/\(coverNumber)-M.jpg?default=false")
    }

    var shorterDescription: String {
        guard let sentence = firstSentence?.first, !sentence.isEmpty else {
            return "No description."
        }
        return sentence.count > 120 ? String(sentence.prefix(120)) + "_" : sentence
    }
    
    var moreDeatiledURL: URL? { URL(string: "https://openlibrary.org\(id).json") }
}

struct objDetail: Decodable {
    let bookDescription : String?
    
    enum CodingKeys: String, CodingKey { case bookDescription }
    private struct objDescription: Decodable { let value: String? }
    
    init(from decoder: Decoder) throws {
        let ck = try decoder.container(keyedBy: CodingKeys.self)
        if let text = try? ck.decodeIfPresent(String.self, forKey: .bookDescription) {
            bookDescription = text
        } else if let object = try? ck.decodeIfPresent(objDescription.self, forKey: .bookDescription) {
            bookDescription = object.value
        } else {
            bookDescription = nil
        }
        
        
    }
}
