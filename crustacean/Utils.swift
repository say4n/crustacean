//
//  Utils.swift
//  crustacean
//
//  Created by Sayan Goswami on 22/12/2023.
//

import SwiftUI

enum DataFetchState: Error {
    case Loading
    case Success
    case Failure
    
}

func formatDateToHumanReadableDuration(date: Date) -> String? {
    let formatter = DateComponentsFormatter()
    
    formatter.unitsStyle = .abbreviated
    formatter.collapsesLargestUnit = true
    formatter.maximumUnitCount = 1
    formatter.allowedUnits = [.minute, .hour, .day, .month, .year]
    
    return formatter.string(from:date, to: Date.now)
}

class JSONParser {
    typealias ResultBlock<T> = (Result <T, Error>) -> Void

    func parse<T: Decodable>(of type: T.Type,
                                      from data: Data,
                                      completion: @escaping ResultBlock<T>) {

        do {
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let decodedData: T = try decoder.decode(T.self, from: data)
            completion(.success(decodedData))
        }
        catch {
            print(error)
            completion(.failure(DataFetchState.Failure))
        }
    }
}

struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        edges.map { edge -> Path in
            switch edge {
            case .top: return Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width))
            case .bottom: return Path(.init(x: rect.minX, y: rect.maxY - width, width: rect.width, height: width))
            case .leading: return Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height))
            case .trailing: return Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
            }
        }.reduce(into: Path()) { $0.addPath($1) }
    }
}

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}
