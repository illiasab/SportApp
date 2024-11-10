//
//  Model.swift
//  SportApp
//
//  Created by Ylyas Abdywahytow on 11/9/24.
//
import Foundation
// MARK: - Exercise Model
struct Exercise: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    let type: String
    let muscle: String
    let equipment: String
    let difficulty: String
    let instructions: String

    enum CodingKeys: String, CodingKey {
        case id, name, type, muscle, equipment, difficulty, instructions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(String.self, forKey: .type)
        muscle = try container.decode(String.self, forKey: .muscle)
        equipment = try container.decode(String.self, forKey: .equipment)
        difficulty = try container.decode(String.self, forKey: .difficulty)
        instructions = try container.decode(String.self, forKey: .instructions)
    }
}
// MARK: - Exercise Type Enum
enum type: String, Codable, CaseIterable, Identifiable {
    case cardio = "cardio"
    case olympic_weightlifting = "olympic_weightlifting"
    case plyometrics = "plyometrics"
    case powerlifting = "powerlifting"
    case strength = "strength"
    case stretching = "stretching"
    case strongman = "strongman"
}
extension type {
    var id: String  {
        return self.rawValue
    }
}

// MARK: - Muscle Enum
enum muscle: String, Codable, CaseIterable {
    case abdominals = "abdominals"
    case abductors = "abductors"
    case adductors = "adductors"
    case biceps = "biceps"
    case calves = "calves"
    case chest = "chest"
    case forearms = "forearms"
    case glutes = "glutes"
    case hamstrings = "hamstrings"
    case lats = "lats"
    case lower_back = "lower_back"
    case middle_back = "middle_back"
    case neck = "neck"
    case quadriceps = "quadriceps"
    case traps = "traps"
    case triceps = "triceps"

}
// MARK: - Difficulty Enum
enum difficulty: String, Codable, CaseIterable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case expert = "expert"
}


// MARK: - HTTP Client Error Enum
enum HTTPClientError: Error, LocalizedError {
    case badURL
    case badDataTask
    case badParametrSerialization
    case badDecode
    case deadApiKey

    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Url is invalid."
        case .badDataTask:
            return "SearchDataTask is nil."
        case .badParametrSerialization:
            return "Not valid parameters"
        case .badDecode:
            return "Can't decode"
        case .deadApiKey:
            return "Change your api key"
        }
    }
}
// MARK: - HTTP Method Enum
enum HTTPMethod: String {
    case GET
}
// MARK: - API Configuration
var method: HTTPMethod {
    return .GET
}
let headers: [String: String] = [
    "Content-Type": "application/json",
    "X-Api-Key": "8b3E2HX1w13LRoqNqn456Q==6sVOGIuMVlf92HEk"
]

let baseURL = "https://api.api-ninjas.com/v1/exercises"
let endpoint = "/exercise"

// MARK: - API Request Function
func fetchExercises(
    difficulty: difficulty? = nil,
    muscle: muscle? = nil,
    type: type? = nil
) async throws -> [Exercise] {
    var urlComponents = URLComponents(string: baseURL)
    
    var queryItems = [URLQueryItem]()
    if let difficulty = difficulty {
        queryItems.append(URLQueryItem(name: "difficulty", value: difficulty.rawValue))
    }
    if let muscle = muscle {
        queryItems.append(URLQueryItem(name: "muscle", value: muscle.rawValue))
    }
    if let type = type {
        queryItems.append(URLQueryItem(name: "type", value: type.rawValue))
    }
    urlComponents?.queryItems = queryItems
    
    guard let url = urlComponents?.url else {
        throw HTTPClientError.badURL
    }
    print("Requesting URL: \(url)")

    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.allHTTPHeaderFields = headers
    request.cachePolicy = .reloadIgnoringLocalCacheData

    let (data, response) = try await URLSession.shared.data(for: request)

    if let httpResponse = response as? HTTPURLResponse {
        print("Response Code: \(httpResponse.statusCode)")
        if httpResponse.statusCode == 402 {
            throw HTTPClientError.deadApiKey
        }
    }

    do {
        let decodedData = try JSONDecoder().decode([Exercise].self, from: data)
        return decodedData
    } catch {
        print("Decoding error: \(error)")
        throw HTTPClientError.badDecode
    }
}


