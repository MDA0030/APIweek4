//
//  BooksListView.swift
//  BookStoreAuthApp
//
//  Created by matt on 11/11/26.
//

import SwiftUI

//main screen
struct BooksListView: View {
    @StateObject private var bookViewModel = BookStoreViewModel()
    
    
    var body: some View {
        NavigationStack {
            Group {
                //case switch for loading
                switch bookViewModel.currentState {
                case .idle, .loading:
                    ProgressView("Loading book...")
                    
                    
                case .loaded:
                    List(bookViewModel.books) {
                        book in NavigationLink(destination: BookDetailView(book: book)){
                            BookRowView(book : book)
                        }
                    }
                    .listStyle(.plain)
                case .empty:
                    ContentUnavailableView("No books available", systemImage: "books.vertical")
                case .failed(let message):
                    ContentUnavailableView {
                        Label("Error occurewd", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Please try again") { Task { await bookViewModel.loadingBooks() }
                            
                        }
                    }
                }
            }
            //design change for purple lettering style
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("The Lore and Myth Page")
                        .font(.title2.bold())
                        .foregroundStyle(.purple)
                }
            }
            
            
            .task { await bookViewModel.loadingBooks() }
            }
            
        }
    }
    
    //gets book cover from URL
    struct BookCoverView: View {
        let url: URL?
        
        var body: some View {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFit()
                case .failure:
                    placeholder
                default:
                    if url == nil {placeholder} else { ProgressView() }
                }
            }
            .aspectRatio(2/3, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        
        private var placeholder: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 6).fill(Color.purple.opacity(0.15))
                Image(systemName: "book.closed").foregroundStyle(.purple)
            }
        }
        
    }
    
    //makes book row used in the view
    struct BookRowView: View {
        let book: BookQualities
        
        var body: some View {
            HStack(alignment: .top, spacing: 10) {
                BookCoverView(url: book.urlOfImg)
                    .frame(width: 50, height: 80)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.showTitle).font(.headline)
                    Text(book.authorText).font(.subheadline).foregroundStyle(.secondary)
                    Text("\(book.showCategory) * \(book.showPublishedYear)")
                        .font(.caption).foregroundStyle(.secondary)
                        .lineLimit(4)
                    
                    
                    Text(book.shorterDescription)
                        .font(.caption).foregroundStyle(.secondary)
                        .lineLimit(4)
                    
                    
                }
            }
            .padding(.vertical, 4)
            
        }
    }
    
    //function for creating line of detail
    private func detailedRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label).bold().frame(minWidth: 90, alignment: .leading)
            Text(value).foregroundStyle(.secondary)
            
        }
    }
    
    //makes view of selected book after clicking on book
    struct BookDetailView: View {
        let book: BookQualities
        @StateObject private var detailModel = BooksDetailViewModel()
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                BookCoverView(url: book.urlOfImg)
                    .frame(maxWidth: 220)
                    .frame(maxWidth: .infinity)
                Text(book.showTitle).font(.title.bold())
                Text("by \(book.authorText)").font(.title2).foregroundStyle(.secondary)
                
                    Divider()
                    
                detailedRow("Category", book.showCategory)
                    detailedRow("First Published", book.showPublishedYear)
                if let pages = book.pageCount { detailedRow("Pages", "\(pages)") }
                    
                Divider()
                    
                Text("Information about this book").font(.headline)
                if detailModel.isLoading
                {
                    ProgressView()
                } else {
                    Text(detailModel.bookDescription ?? book.firstSentence?.first ?? "No description.")
                }
                
            }
            .padding()
            
        }
            .navigationBarTitleDisplayMode(.inline)
            .task { await detailModel.loadBook(for: book)}
    }
    

    
    //#Preview {
    //   BooksListView()
    // }
}
