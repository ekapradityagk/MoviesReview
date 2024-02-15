//
//  MovieReviewListView.swift
//  MoviesReview
//
//  Created by Eka Praditya on 14/02/24.
//

import SwiftUI

struct MovieReviewListView: View {
    @State var reviews = [Review]()
    @State var currentPage = Int()
    @State var totalPages = Int()
    @State var isLoading = false
    let threshold = 80.0
    var totalReviews = 50
    
    @State var movieID = Int()

    var body: some View {
        ScrollView {
            VStack {
                ForEach(reviews) { review in
                    ReviewCell(review: review)
                }
                if isLoading && currentPage < totalPages {
                    ProgressView()
                }
                
                GeometryReader { geo in
                    VStack {
                        let deltaY = geo.frame(in: .global).maxY - (geo.size.height + geo.safeAreaInsets.bottom)
                        if deltaY >= threshold && !isLoading {
                            loadMoreReviewsIfNeeded()
                            EmptyView()
                        } else {
                            ProgressView()
                        }
                    }
                }
            }
            .onAppear(){
                loadMoreReviews(page: currentPage)
            }
            
        }
    }
    
    func loadMoreReviews(page: Int) {
        isLoading = true
        
        let tmdbConnection = TMDBConnection()
        print("Movie id sent is \(movieID), and page is \(page)")
        tmdbConnection.fetchReviewsWithTotalPages(forMovieId: movieID, page: page) { result in
            defer {
                isLoading = false
            }

        switch result {
        case .success(let reviewsResponse):
            self.reviews.append(contentsOf: reviewsResponse.results)
            self.currentPage = reviewsResponse.page + 1
            self.totalPages = reviewsResponse.total_pages
        case .failure(let error):
          print("Error fetching reviews: \(error)")
        }
      }
    }

    
    func loadMoreReviewsIfNeeded() -> some View {
        print("isloading : \(isLoading), current page \(currentPage) < total page \(totalPages)")
        if !isLoading && currentPage < totalPages {
            loadMoreReviews(page: currentPage)
            return EmptyView()
        } else {
            
            print("not load")
            return EmptyView()
        }
    }
        
}



#Preview {
    MovieReviewListView()
}


struct ReviewCell: View {
    let review: Review
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title section
            HStack( spacing: 4) {
                // Profile picture
                if let profilePictureURL = review.author_details?.avatar_path {
                    AsyncImage(url: URL(string: "\(baseImagePath)\(profilePictureURL)")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 50, height: 50)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 50, height: 50)
                    }
                } else {
                    Image(systemName: "person")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                }

                // User details
                VStack(alignment: .leading) {
                    Text(review.author_details?.name ?? review.author)
                        .font(.caption)
                        .fontWeight(.bold)
                    if let rating = review.author_details?.rating {
                        Text("\(rating) stars")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                Spacer()
            }

            // Review content
            VStack(alignment: .leading, spacing: 4) {
                Text(isExpanded ? review.content : "\(review.content.prefix(100))...")
                    .lineLimit(isExpanded ? nil : 3)
                    .onTapGesture {
                        isExpanded.toggle()
                    }
                if !isExpanded && review.content.count > 100 {
                    Text("Show more...")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .onTapGesture {
                            isExpanded.toggle()
                        }
                }
            }
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width - 20)
        .background(Color.white) // Add white background
        .cornerRadius(10) // Add rounded corners
        .shadow(color: .gray, radius: 5, x: 2, y: 2)
    }
}



