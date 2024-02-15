//
//  GenreListView.swift
//  MoviesReview
//
//  Created by Eka Praditya on 12/02/24.
//

import SwiftUI

struct GenreListView: View {
    @State var genreList = [String]()
    @State var genres = [Genre]()

    var body: some View {
        NavigationStack{
            VStack {
                VStack{
                    ScrollView{
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 170))], content: {
                            ForEach(genres, id:\.self) { genre in
                                NavigationLink {
                                    MoviesListByGenreView(genreID: genre.id, genreName: genre.name)
                                } label: {
                                    GenreThumbView(titleName: genre.name,genreList: genreList)
                                }
                            }
                        })
                    }
                }
            }
            .onAppear(){
                let tmdbConnection = TMDBConnection()
                tmdbConnection.getGenre { result in
                    switch result {
                    case .success(let genres):
                        self.genres = genres
                        for genre in genres {
                            genreList.append(genre.name)
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
                
                let movieId = 640146 // Replace with desired movie ID

                tmdbConnection.fetchMovieDetails(movieId: movieId) { result in
                    switch result {
                    case .success(let movieDetails):
                        print("Movie details:"/*, movieDetails*/)
                    case .failure(let error):
                        print("Error:", error)
                    }
                }
                
                tmdbConnection.fetchMovieVideos(for: movieId) { result in
                    switch result {
                    case .success(let videos):
                        print("Retrieved movie videos:")
                        for video in videos {
                            print("  - Name: \(video.name)")
                            print("    Key: \(video.key)")
                        }
                    case .failure(let error):
                        print("Error fetching movie videos: \(error)")
                    }
                }
//                fetchReviewsForAntMan()
                
                
            }
            .navigationTitle("Genre")
            .padding()
            .background(.conicGradient(colors: [.blue,.orange,], center: UnitPoint(x: 5, y: 1)))

        }
    }
    
    
}

#Preview {
    GenreListView()
}
