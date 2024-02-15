//
//  GenreThumbView.swift
//  MoviesReview
//
//  Created by Eka Praditya on 12/02/24.
//

import SwiftUI

struct GenreThumbView: View {
    
    var titleName = "Action"
    var genreList = ["Action","Adventure","Animation","Comedy","Crime","Documentary","Drama","Family","Fantasy","History","Horror","Mystery","Romance","Science Fiction","TV Movie", "Thriller","Western"]
    var body: some View {
        VStack{
            ZStack{
                Color.gray
                    .opacity(0.2)
                Text(titleName)
                    .font(.title2)
                    .foregroundStyle(.black).bold()
                    .shadow(color: .white, radius: 10)
            }
        }
        .frame(width: 150, height: 80)
        .background(Image(checkGenre(titleName)).resizable())
        .clipShape(RoundedRectangle(cornerRadius: 25.0))
    }
    
    func checkGenre(_ genreTitle:String) -> String{
        if let item = genreList.first(where: { $0.contains(genreTitle) }) {
            let imageName = "\(item)Movie"
            return imageName
        } else {
            return genreList.randomElement() ?? ""
        }
    }
}

#Preview {
    GenreThumbView()
}

struct BackGroundView: View {
    var body: some View {
        VStack{
            VStack{
                ZStack{
                    Color.gray
                        .opacity(0.2)
                    Text("Action")
                        .font(.largeTitle)
                        .foregroundStyle(.black).bold()
                        .shadow(color: .white, radius: 10)
                }
            }
            .frame(width: UIScreen.main.bounds.width / 2 - 20, height: 100)
            .background(Image("ActionMovie").resizable())
            .clipShape(RoundedRectangle(cornerRadius: 25.0))
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(.blue)
    }
}
