//
//  ContentView.swift
//  poketest
//
//  Created by Alexandre Martins on 11/03/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var pokemons: [Pokemons] = []
    
    var body: some View {
        VStack {
            List (pokemons, id: \.name) { pokemon in
                Text(pokemon.name)
            }
        }
        .padding()
        .task {
            do{
                pokemons = try await getPokemon()
            } catch PokeErros.invalidURL {
                print("invalid url")
            } catch PokeErros.invalidResponse {
                print("invalid response")
            } catch PokeErros.invalidData {
                print("invalid data")
            } catch {
                print("unexpectet error")
            }
        }
    }
    
    func getPokemon() async throws -> [Pokemons]{
        let endpoint = "https://pokeapi.co/api/v2/pokemon/"
        
        guard let url = URL(string: endpoint) else {
            throw PokeErros.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode==200 else{
            throw PokeErros.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(PokeTestApi.self, from: data)
            return apiResponse.results
        } catch {
            throw PokeErros.invalidData
        }
        
    }
    
}

#Preview {
    ContentView()
}


struct PokeTestApi: Codable{
    let count: Int?
    let next: String?
    let previous: String?
    let results: [Pokemons]
}

struct Pokemons: Codable {
    let name: String
    let url: String
}

enum PokeErros:Error{
    case invalidURL
    case invalidResponse
    case invalidData
}
