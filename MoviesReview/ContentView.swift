//
//  ContentView.swift
//  MoviesReview
//
//  Created by Eka Praditya on 12/02/24.
//

import SwiftUI

var apiKeyTMDB = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyYmMzNWFlMTI0YWEyZGFjOWVkMmU0NTI4OGVhOGFmZCIsInN1YiI6IjYzY2ZlNjkwOTE3NDViMDBjMDE1NTE1ZCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.GJr_g9o0-OnwUQF6HD6JvPX9AHtjCZ6tDQLzdlI0hvA"

var baseImagePath = "https://image.tmdb.org/t/p/original"

// sample usage - https://api.themoviedb.org/3/movie/550?api_key=2bc35ae124aa2dac9ed2e45288ea8afd

struct ContentView: View {
    
    
    var body: some View {
        GenreListView()
//        MovieDetailsView()
//        MovieReviewListView()
    }
}

#Preview {
    ContentView()
}
