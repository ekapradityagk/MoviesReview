//
//  MovieThumbView.swift
//  MoviesReview
//
//  Created by Eka Praditya on 12/02/24.
//

import SwiftUI

struct MovieThumbView: View {
    @State var imageUrl: String = "https://picsum.photos/id/237/200/300"
    @State private var image: UIImage? = nil
    
    var body: some View {
        VStack{
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
            } else {
                ProgressView()
            }
        }
        .frame(width: 160, height: 210)
        .clipShape(RoundedRectangle(cornerRadius: 35.0))
        .shadow(color: .gray, radius: 5, x: 4, y: 4).onAppear {
            if imageUrl != "" {
                loadImage(from: imageUrl) { downloadedImage in
                    self.image = downloadedImage
                }
            }
        }
    }
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        Task {
            do {
                let url = URL(string: urlString)!
                let data = try await Data(contentsOf: url)
                let uiImage = UIImage(data: data)
                // Update on main thread using MainActor.run
                await MainActor.run {
                    completion(uiImage)
                }
            } catch {
                print("Error loading image: \(error)")
                completion(nil) // Handle error gracefully, e.g., display message
            }
        }
    }
}

#Preview {
    MovieThumbView()
}
