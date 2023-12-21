//
//  Utils.swift
//  crustacean
//
//  Created by Sayan Goswami on 22/12/2023.
//

import Foundation

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

