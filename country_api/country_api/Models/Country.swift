import Foundation

struct Country: Identifiable {
    let id = UUID()
    let name: String
    let officialName: String
    let capital: String
    let region: String
    let population: Int
    let flagURLString: String

    init(name: String, officialName: String, capital: String, region: String, population: Int, flagURLString: String) {
        self.name = name
        self.officialName = officialName
        self.capital = capital
        self.region = region
        self.population = population
        self.flagURLString = flagURLString
    }

    init(payload: CountryPayload) {
        name = payload.names.common
        officialName = payload.names.official
        capital = payload.capitals.first?.name ?? "N/A"
        region = payload.region ?? "N/A"
        population = payload.population ?? 0
        flagURLString = payload.flag.urlPNG
    }
}

struct CountryListResponse: Decodable {
    let data: CountryListData
}

struct CountryListData: Decodable {
    let objects: [CountryPayload]
    let meta: CountryListMeta
}

struct CountryListMeta: Decodable {
    let more: Bool?
    let count: Int?
    let offset: Int?
}

struct CountryPayload: Decodable {
    let names: CountryNames
    let capitals: [CountryCapital]
    let region: String?
    let population: Int?
    let flag: CountryFlag
}

struct CountryNames: Decodable {
    let common: String
    let official: String
}

struct CountryCapital: Decodable {
    let name: String
}

struct CountryFlag: Decodable {
    let urlPNG: String

    private enum CodingKeys: String, CodingKey {
        case urlPNG = "url_png"
    }
}