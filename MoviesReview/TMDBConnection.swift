//
//  TMDBConnection.swift
//  MoviesReview
//
//  Created by Eka Praditya on 12/02/24.
//

import Foundation



class TMDBConnection {
    func fetchMovieVideos(for movieID: Int, completion: @escaping (Result<[MovieVideo], Error>) -> Void) {
        let urlString = "https://api.themoviedb.org/3/movie/\(movieID)/videos?language=en-US"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "MovieReviewsError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        let headers = [
            "Accept": "application/json",
            "Authorization": "Bearer \(apiKeyTMDB)"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(error!))
                    return
                }

            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "MovieMoviesError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "MovieMoviesError", code: 3, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            

            do {
                    let decodedDictionary: [String: Decodable?] = try JSONDecoder().decode([String: [MovieVideo]?].self, from: data)

                    guard let resultsArray = decodedDictionary["results"] as? [MovieVideo?] else {
                        completion(.failure(NSError(domain: "MovieMoviesError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid 'results' key"])))
                        return
                    }

                    let filteredResults = resultsArray.compactMap { $0 } // Remove nil elements if necessary
                    completion(.success(filteredResults))
                    } catch {
                        completion(.failure(error))
                    }
        }

        task.resume()
    }

    private func buildURL(for path: String, with parameters: [String: String]) -> URL? {
        var components = URLComponents(string: baseImagePath + path)!
        components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components.url
    }

    
    // TODO: remove fetchreviews
    func fetchReviews(forMovieId movieId: Int, page: Int, completion: @escaping (Result<[Review], Error>) -> Void) {
        let urlString = "https://api.themoviedb.org/3/movie/\(movieId)/reviews?language=en-US&page=\(page)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "MovieReviewsError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        let headers = [
            "Accept": "application/json",
            "Authorization": "Bearer \(apiKeyTMDB)"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "MovieReviewsError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "MovieReviewsError", code: 3, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(ReviewsResponse.self, from: data)
                completion(.success(response.results))
            } catch {
                completion(.failure(error))
            }
        }

        dataTask.resume()
    }

    func fetchReviewsWithTotalPages(forMovieId movieId: Int, page: Int, completion: @escaping (Result<ReviewsResponse, Error>) -> Void) {
        let urlString = "https://api.themoviedb.org/3/movie/\(movieId)/reviews?language=en-US&page=\(page)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "MovieReviewsError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        let headers = [
            "Accept": "application/json",
            "Authorization": "Bearer \(apiKeyTMDB)"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "MovieReviewsError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "MovieReviewsError", code: 3, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(ReviewsResponse.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(error))
            }
        }

        dataTask.resume()
    }


    func fetchMovieDetails(movieId: Int, completion: @escaping (Result<MovieDetails, APIError>) -> Void) {
        let urlString = "https://api.themoviedb.org/3/movie/\(movieId)?language=en-US"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidResponse(statusCode: 0)))
            return
        }
        
        let headers = [
            "accept": "application/json",
            "Authorization": "Bearer \(apiKeyTMDB)" // Replace with your API key
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.network(error: error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                completion(.failure(.invalidResponse(statusCode: 0)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.network(error: APIError.missingData)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let movieDetails = try decoder.decode(MovieDetails.self, from: data)
                completion(.success(movieDetails))
            } catch {
                completion(.failure(.decoding(error: error)))
            }
        }
        
        dataTask.resume()
    }
    
    
func discoverMoviesByGenre(genreId: Int, page: Int = 1, completion: @escaping (Result<MoviesResponse, Error>) -> Void) {
        var urlComponents = URLComponents(string: "https://api.themoviedb.org/3/discover/movie")!
        urlComponents.queryItems = [
            URLQueryItem(name: "include_adult", value: "false"),
            URLQueryItem(name: "include_video", value: "false"),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "sort_by", value: "popularity.desc"),
            URLQueryItem(name: "with_genres", value: String(genreId)),
        ]
        let url = urlComponents.url!
        
        let headers = [
            "accept": "application/json",
            "Authorization": "Bearer \(apiKeyTMDB)", // Replace with your API key
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.invalidResponse(statusCode: 0)))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.missingData))
                return
            }
            
        do {
            let decoder = JSONDecoder()
            let moviesResponse = try decoder.decode(MoviesResponse.self, from: data)
            completion(.success(moviesResponse))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    
    func getGenre(completion: @escaping (Result<[Genre], Error>) -> Void) {
        let urlString = "https://api.themoviedb.org/3/genre/movie/list?language=en"
        let headers = [
            "accept": "application/json",
            "Authorization": "Bearer \(apiKeyTMDB)"
        ]
        print(headers.description)
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(URLError(.badURL)))
        }
        
        var request = URLRequest(url: url) // Create the request here
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(GenreResponse.self, from: data)
                    completion(.success(response.genres)) // Access the genres array within response
                } catch {
                    completion(.failure(error))
                }
            } else {
                // Handle bad server response
            }
        }.resume()
    }
}



struct GenreResponse: Codable {
    let genres: [Genre]
}

struct Genre: Codable, Hashable {
    let id: Int
    let name: String
}

struct MoviesResponse: Decodable {
    let page: Int
    let results: [Movie]
    let total_pages : Int
    let total_results : Int
}

struct Movie: Decodable, Hashable, Identifiable {
    let id: Int
    let title: String
    let poster_path: String?
    let releaseDate: String?
    let overview: String?
    let voteAverage: Double?
}


// Custom error for API-related issues


struct MovieDetails: Decodable {
    let adult: Bool
    let backdrop_path: String?
    let belongsToCollection: MovieCollection? // Nested struct for collection details
    let budget: Int
    let genres: [Genre] // Array of genre objects
    let homepage: String
    let id: Int
    let imdb_id: String
    let original_language: String
    let original_title: String
    let overview: String
    let popularity: Double
    let poster_path: String?
    let production_companies: [ProductionCompany] // Array of company objects
    let production_countries: [ProductionCountry] // Array of country objects
    let release_date: String
    let revenue: Int
    let runtime: Int
    let spoken_languages: [SpokenLanguage] // Array of language objects
    let status: String
    let tagline: String
    let title: String
    let video: Bool
    let vote_average: Double
    let vote_count: Int

    // Nested structs for nested data

    struct MovieCollection: Decodable {
        let id: Int
        let name: String
        let poster_path: String?
        let backdrop_path: String?
    }

    struct Genre: Decodable {
        let id: Int
        let name: String
    }

    struct ProductionCompany: Decodable {
        let id: Int
        let logo_path: String?
        let name: String
        let origin_country: String
    }

    struct ProductionCountry: Decodable {
        let iso_3166_1: String
        let name: String
    }

    struct SpokenLanguage: Decodable {
        let english_name: String
        let iso_639_1: String
        let name: String
    }
}

struct Review: Decodable, Identifiable {
    let author: String
    let author_details: AuthorDetails?
    let content: String
    let created_at: String?
    let id: String?
    let updated_at: String?
    let url: String?
}

struct AuthorDetails: Decodable {
    let name: String?
    let username: String?
    let avatar_path: String?
    let rating: Int?
}

struct ReviewsResponse: Decodable {
    let page: Int
    let total_pages: Int
    let total_results: Int
    let results: [Review]
}
enum APIError: Error {
    case invalidResponse(statusCode: Int)
    case missingData
    case network(error: Error)
    case decoding(error: Error)
}

struct MovieVideo: Codable {
    let id: String
    let iso_639_1: String
    let iso_3166_1: String
    let name: String
    let key: String
    let site: String
    let size: Int
    let type: String
    let official: Bool
    let published_at: String
}

