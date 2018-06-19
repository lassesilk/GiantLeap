//
//  BusinessJson.swift
//  GiantLeapTest
//
//  Created by Lasse Silkoset on 15.06.2018.
//  Copyright © 2018 Lasse Silkoset. All rights reserved.
//

import Foundation

struct NameJson: Decodable {
    
    let data: [Items]
    
    struct Items: Decodable {
        let organisasjonsnummer: Int?
        let navn: String?
        let forretningsadresse: forretningsadresse?
        let naeringskode1: naeringskode1?
    }
    
    struct forretningsadresse: Decodable {
        let adresse: String?
        let postnummer: String?
        let poststed: String?
    }
    
    struct naeringskode1: Decodable {
        let beskrivelse: String?
    }
}
