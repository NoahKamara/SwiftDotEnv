//
//  Errors.swift
//  
//
//  Created by Noah Kamara on 03.05.21.
//

import Foundation

extension DotEnv {
    enum Errors: Error {
        case FileNotFound(_ path: String)
    }
}
