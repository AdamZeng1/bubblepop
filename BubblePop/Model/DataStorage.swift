//
//  DataStorage.swift
//  BubblePop
//
//  Created by Audwin on 8/5/18.
//  Copyright © 2018 Audwin. All rights reserved.
//

import Foundation

// Model struct for storing data
struct DataStorage: Codable {
    let gameSettingsArchiveURL: URL
    let scoreboardArchiveURL: URL
    
    // for data errors
    enum DataError: Error {
        case dataNotFound
        case dataNotSaved
    }
    
    init() {
        // set up URLs
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        gameSettingsArchiveURL = documentsDirectory.appendingPathComponent("game_settings")
            .appendingPathExtension("json")
        scoreboardArchiveURL = documentsDirectory.appendingPathComponent("scoreboard")
            .appendingPathExtension("json")
    }
    
    func read(from archive: URL) throws -> Data {
        if let data = try? Data(contentsOf: archive) {
            return data
        }
        throw DataError.dataNotFound
    }
    
    func write(_ data: Data, to archive: URL) throws {
        do {
            try data.write(to: archive, options: .noFileProtection)
        }
        catch {
            throw DataError.dataNotSaved
        }
    }
    
    func saveData(settings: GameSettings) throws {
        let data = try JSONEncoder().encode(settings)
        try write(data, to: gameSettingsArchiveURL)
    }
    
    func saveData(scores: [Scoreboard]) throws {
        let data = try JSONEncoder().encode(scores)
        try write(data, to: scoreboardArchiveURL)
    }
    
    func loadGameSettings() throws -> GameSettings {
        let data = try read(from: gameSettingsArchiveURL)
        if let settings = try? JSONDecoder().decode(GameSettings.self, from: data) {
            return settings
        }
        throw DataError.dataNotFound
    }
    
    func loadScoreboard() throws -> [Scoreboard] {
        let data = try read(from: scoreboardArchiveURL)
        if let scoreboard = try? JSONDecoder().decode([Scoreboard].self, from: data) {
            return scoreboard
        }
        throw DataError.dataNotFound
    }
    
}
