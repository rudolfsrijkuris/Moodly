//
//  BreatheType.swift
//  BreatheAnimation
//
//  Created by Rudolfs Rijkuris on 17/07/23.
//

import SwiftUI

// MARK: Type Model And Sample Types
struct BreatheType: Identifiable,Hashable{
    var id: String = UUID().uuidString
    var title: String
    var color: Color
}

let sampleTypes: [BreatheType] = [
    .init(title: "Anger", color: .mint),
    .init(title: "Irritation", color: .brown),
    .init(title: "Sadness", color: Color("Purple")),
    .init(title: "Anxiety", color: Color("Green")),
    .init(title: "Stress", color: Color("Yellow")),

]
