//
//  CountryData.swift
//  HW8
//
//  Created by Swaroop Mula on 3/5/24.
//

import Foundation

struct Country {
    var name: String
    var flag: String
    var description: String
    var URL: String
}

let countriesData = [
    Country(name: "Austria", 
            flag: "austriaFlag",
            description: "The Austrian flag is considered one of the oldest national symbols still in use by a modern country, with its first recorded use in 1230. The Austrian triband originated from the arms of the Babenberg dynasty.",
            URL: "https://en.wikipedia.org/wiki/Flag_of_Austria"),
    
    Country(name: "Belgium",
            flag: "belgiumFlag",
            description: "On 23 January 1831, the National Congress enshrined the tricolor in the Constitution, but did not determine the direction and order of the color bands. As a result, the official flag was given vertical stripes with the colors black, yellow and red.",
            URL: "https://en.wikipedia.org/wiki/Flag_of_Belgium"),
    
    Country(name: "Czech Republic", 
            flag: "czechRepublicFlag",
            description: "Description of Czech Republic",
            URL: "https://en.wikipedia.org/wiki/Flag_of_the_Czech_Republic"),
    
    Country(name: "Denmark", 
            flag: "denmarkFlag",
            description: "Description of Denmark",
            URL: "https://en.wikipedia.org/wiki/Flag_of_Denmark"),
    
    Country(name: "France", 
            flag: "franceFlag",
            description: "Description of France",
            URL: "https://en.wikipedia.org/wiki/Flag_of_France"),
    
    Country(name: "Germany", 
            flag: "germanyFlag",
            description: "Description of Germany",
            URL: "https://en.wikipedia.org/wiki/Flag_of_Germany"),
    
    Country(name: "Greece", 
            flag: "greeceFlag",
            description: "Description of Greece",
            URL: "https://en.wikipedia.org/wiki/Flag_of_Greece"),
    
    Country(name: "Italy", 
            flag: "italyFlag",
            description: "Description of Italy", 
            URL: "https://en.wikipedia.org/wiki/Flag_of_Italy"),
    
    Country(name: "Netherlands", 
            flag: "netherlandsFlag",
            description: "Description of Netherlands",
            URL: "https://en.wikipedia.org/wiki/Flag_of_the_Netherlands"),
    
    Country(name: "Portugal", 
            flag: "portugalFlag",
            description: "Description of Portugal",
            URL: "https://en.wikipedia.org/wiki/Flag_of_Portugal"),
    
    Country(name: "Spain", 
            flag: "spainFlag",
            description: "Description of Spain",
            URL: "https://en.wikipedia.org/wiki/Flag_of_Spain"),
    
    Country(name: "Sweden", 
            flag: "swedenFlag",
            description: "Description of Sweden",
            URL: "https://en.wikipedia.org/wiki/Flag_of_Sweden")
]

