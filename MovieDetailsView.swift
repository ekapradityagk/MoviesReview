//
//  MovieDetailsView.swift
//  MoviesReview
//
//  Created by Eka Praditya on 13/02/24.
//

import SwiftUI

struct MovieDetailsView: View {
    var movieID = Int()
    var viewList = ["Review", "Trailer"]
    @State var selectedView = "Review"
    
    @State var totalPageReview = 1
    @State var backdrop_path = ""
    @State var posterPath = ""
    @State var titleMovie = ""
    @State var genres = [String]()
    @State var voteCount = 0
    @State var voteAverage = 0.0
    @State var originalLanguage = ""
    @State var releaseDate = ""
    @State var runtime = 0
    @State var overview = ""
    
    var body: some View {
        ZStack{
            // notes // start of background area //
            AsyncImage(url: URL(string: "\(baseImagePath)\(backdrop_path)")) { image in
                image
                    .resizable().scaledToFill().ignoresSafeArea()
                    .frame(height: UIScreen.main.bounds.height)
            } placeholder: {
                ProgressView()
                    .frame(width: 50, height: 50)
            }
                
            LinearGradient(
                gradient: Gradient(colors: [.clear, .white.opacity(0.6)]),
                startPoint: .top,
                endPoint: .center
            )
            // notes // end of background area //
            
            // notes // start of front scrolled area //
            ScrollView{
                VStack{
                    
                }
                .frame(height: UIScreen.main.bounds.height/2)
                VStack {
                    
                    HStack{
                        MoviePosterView(posterPath: "\(baseImagePath)\(posterPath)", width: 130, height: 170)
                        
                        MovieRatingDetailsView(title: titleMovie, genres: genres, countRate: voteCount, numberedRate: voteAverage, language: originalLanguage,releaseDate: releaseDate, runtime: runtime)
                    }
                    .frame(maxHeight: 180)
                    .padding(.horizontal,20)
                    
                    let longText = overview
                    let overview = ExpandableLabel(text: longText, moreText: "View all")
                    
                    overview
                        .padding(.horizontal,20)
                    
                    Spacer()
                    
                    Picker("", selection: $selectedView) {
                        ForEach(viewList, id:\.self){ item in
                            Text(item)
                        }
                    }.pickerStyle(.palette)
                    
                    ScrollView{
                        
                        if selectedView == "Review"{
                            MovieReviewListView( currentPage: 1, totalPages: totalPageReview, movieID: movieID)
                        }
                        
                        Spacer()
                    }
                    .padding(.top,10)
                    
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 50)
                .background(FadingTopBackground())
            }
        }
        .onAppear(){
//            fetchReviewsTotalPage()
            print("movie id before fetch review total page : \(movieID)")
            let tmdbConnection = TMDBConnection()
            tmdbConnection.fetchMovieDetails(movieId: movieID) { result in
                switch result {
                case .success(let movieDetail):
                    fillDetails(movieDetail)
                    print("Movie details:"/*, MovieDetails*/)
                case .failure(let error):
                    print("Error:", error)
                }
            }
        }
    }
    
    func fillDetails(_ movieDetails:MovieDetails){
        backdrop_path = movieDetails.backdrop_path ?? ""
        posterPath = movieDetails.poster_path ?? ""
        titleMovie = movieDetails.title 
        genres = getGenresName(movieDetails.genres)
        voteCount = movieDetails.vote_count
        voteAverage = movieDetails.vote_average
        originalLanguage = movieDetails.original_language
        releaseDate = movieDetails.release_date
        runtime = movieDetails.runtime
        overview = movieDetails.overview
    }
    
    func getGenresName(_ arrData:[MovieDetails.Genre]) -> [String]{
        var genre = [String]()
        
        for data in arrData{
            genre.append(data.name)
        }
                
        return genre
    }
    
//    func fetchReviewsTotalPage() {
//        let tmdbConnection = TMDBConnection()
//        tmdbConnection.fetchReviewsWithTotalPages(forMovieId: movieID, ) { result in
//            switch result {
//            case .success(let reviewsResponse):
//                print("reviewsResponse total page:", reviewsResponse.total_pages)
//                self.totalPageReview = reviewsResponse.total_pages
//            case .failure(let error):
//                print("Error:", error)
//            }
//        }
//    }
}

//#Preview {
//    MovieDetailsView()
//}




struct FadingTopBackground: View {
    var body: some View {
        ZStack(alignment: .top) {
            // Background color below the gradient
            Color.white.ignoresSafeArea(.all)
            
            // Gradient applied only to the top 40px with fade effect and offset
            LinearGradient(
                colors: [
                    .clear, // Transparent at the top
                    .white.opacity(0.8) // Fades gradually to background color
                ],
                startPoint: .top,
                endPoint: .center
            )
            .frame(height: 50)
            .clipped() // Avoid overflow outside frame
            .offset(y: -27) // Adjust offset as needed
        }
    }
}


struct MoviePosterView: View {
    var posterPath: String
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: "\(baseImagePath)\(posterPath)")) { image in
                image
                    .resizable()
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } placeholder: {
                ProgressView()
                    .frame(width: 50, height: 50)
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width / 2)
    }
}

struct MovieRatingDetailsView: View {
    let title: String
    var genres : [String] = [String]()
    let countRate: Int
    let numberedRate: Double
    var language = String()
    var releaseDate = String()
    var runtime = Int()
    
    var body: some View {
        VStack {
            Text(title)
                .font(.title).bold()
            
            if !genres.isEmpty{
                HStack {
                    ForEach(genres.indices, id: \.self) { index in
                        Text(genres[index])
                            .font(.caption)
                        + Text(index == genres.indices.last ? "" : " |")
                    }
                }
                .font(.caption)
                .padding(.bottom,5)
            }
            
            if countRate != 0{
                HStack {
                    ForEach(0..<(Int(numberedRate.rounded(.down)))/2) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    ForEach(0..<(10 - Int(numberedRate.rounded(.down)))/2) { _ in
                        Image(systemName: "star")
                    }
                    
                    Text(numberedRate.formatted())
                    Text(" (\(countRate))")
                }
                .font(.caption)
            }
            
            if language != ""{
                HStack{
                    Text("Language : \(language)")
                        .font(.caption).padding(.top,1).padding(.leading,5)
                    Spacer()
                }
            }
            
            HStack{
                Text(releaseDate)
                Text(minutesToHoursMinutesString(runtime))
                Spacer()
            }
            .font(.caption)
            .padding(.top, 1).padding(.leading,5)
        }
        .frame(maxWidth: UIScreen.main.bounds.width / 2)
        
//        Spacer()
    }
}

func minutesToHoursMinutesString(_ minutes: Int) -> String {
    let hours = minutes / 60
    let remainingMinutes = minutes % 60
    return "\(hours)h \(remainingMinutes)m"
}

struct ExpandableLabel: View {
    @State private var isExpanded = false
    let text: String
    let moreText: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(isExpanded ? text : String(text.prefix(200))) // Show full text or truncated version
                .lineLimit(isExpanded ? Int.max : 2) // Dynamic line limit based on expanded state
                .truncationMode(.tail) // Enable ellipsis
                .onTapGesture {
                    isExpanded.toggle()
                }
            if !isExpanded && text.count > 200 { // Adjust threshold as needed
                Button(moreText) {
                    isExpanded.toggle()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
    }
}

