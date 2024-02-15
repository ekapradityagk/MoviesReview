//
// MoviesListByGenreView.swift
// MoviesReview
//
// Created by Eka Praditya on 12/02/24.
//

import SwiftUI

struct MoviesListByGenreView: View {
  @State var movieList = [Movie]()
  @State var currentPage = 1
  @State var totalPages = 1 // In case the API doesn't provide this
  @State var isLoading = false
  let threshold = 80.0

  var genreID = 0
  var genreName = ""

  var body: some View {
    ScrollView {
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 170))]) {
        ForEach(movieList) { movie in
          NavigationLink(destination: MovieDetailsView(movieID: movie.id)) {
            MovieThumbView(imageUrl: "https://image.tmdb.org/t/p/original/\(movie.poster_path ?? "")")
          }
        }
      }
      .padding(.horizontal, 20)

      GeometryReader { geo in
        VStack {
          let deltaY = geo.frame(in: .global).maxY - (geo.size.height + geo.safeAreaInsets.bottom)
          if deltaY >= threshold && !isLoading {
            loadMoreMoviesIfNeeded()
            EmptyView()
          } else {
            ProgressView() // Show loading indicator if needed
          }
        }
      }
    }
    .navigationTitle("\(genreName) Movie List")
    .onAppear {
      fetchMovies(page: currentPage)
    }
  }

  func fetchMovies(page: Int) {
    isLoading = true
    let tmdbConnection = TMDBConnection()
    tmdbConnection.discoverMoviesByGenre(genreId: genreID, page: page) { result in
      defer {
        isLoading = false
      }

      switch result {
      case .success(let moviesResponse):
        // Access all properties of moviesResponse here
        self.movieList.append(contentsOf: moviesResponse.results)
        self.currentPage = moviesResponse.page + 1 // Update currentPage
        self.totalPages = moviesResponse.total_pages // Update totalPages
      case .failure(let error):
        print("Error fetching movies:", error)
      }
    }
  }

  func loadMoreMoviesIfNeeded() -> some View {
    if !isLoading && currentPage < totalPages {
      fetchMovies(page: currentPage)
      return EmptyView()
    }
    return EmptyView()
  }
}


#Preview {
  MoviesListByGenreView()
}
