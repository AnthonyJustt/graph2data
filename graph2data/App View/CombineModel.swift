//
//  ModelCombine.swift
//  graph2data
//
//  Created by Anton Krivonozhenkov on 06.02.2022.
//

import SwiftUI

class Model: ObservableObject {
    static var shared = Model() 
    
    @Published var boCurrentImage: Int = 0
    @Published var boCurrentProgress: Int = 0
}
