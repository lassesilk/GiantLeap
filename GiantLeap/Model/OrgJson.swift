//
//  OrgJson.swift
//  GiantLeap
//
//  Created by Lasse Silkoset on 22.06.2018.
//  Copyright © 2018 Lasse Silkoset. All rights reserved.
//

import Foundation


struct OrgJson: Decodable {
    let navn: String?
    let organisasjonsnummer: Int?
    let hjemmeside: String?
    let forretningsadresse: forretningsadresse?
    let naeringskode1: naeringskode1?
    
    struct naeringskode1: Decodable {
        let beskrivelse: String?
    }
    
    struct forretningsadresse: Decodable {
        let adresse: String?
        let postnummer: String?
        let poststed: String?
    }
}

