import Foundation

final class CountryViewModel: ObservableObject {
    @Published var countries: [Country] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let baseURLString = "https://api.restcountries.com/countries/v5"
    private let pageSize = 100

    func fetchCountries() {
        guard URL(string: baseURLString) != nil else {
            errorMessage = "The API URL is invalid."
            return
        }

        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "REST_COUNTRIES_API_KEY") as? String,
              !apiKey.isEmpty else {
            errorMessage = "REST_COUNTRIES_API_KEY is missing. Add your REST Countries API key to Info.plist in Xcode, then rebuild the app."
            return
        }

        isLoading = true
        errorMessage = nil
        fetchCountriesPage(offset: 0, accumulatedCountries: [], apiKey: apiKey)
    }

    private func fetchCountriesPage(offset: Int, accumulatedCountries: [Country], apiKey: String) {
        guard let url = URL(string: "\(baseURLString)?limit=\(pageSize)&offset=\(offset)") else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "The API URL is invalid."
            }
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "The server response was invalid."
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "No data was returned from the server."
                }
                return
            }

            if !(200...299).contains(httpResponse.statusCode) {
                let message = Self.apiErrorMessage(from: data) ?? HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = message
                }
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(CountryListResponse.self, from: data)
                let pageCountries = decodedResponse.data.objects.map { Country(payload: $0) }
                let combinedCountries = accumulatedCountries + pageCountries

                if decodedResponse.data.meta.more == true {
                    let nextOffset = (decodedResponse.data.meta.offset ?? offset) + (decodedResponse.data.meta.count ?? pageCountries.count)
                    self.fetchCountriesPage(offset: nextOffset, accumulatedCountries: combinedCountries, apiKey: apiKey)
                    return
                }

                let sortedCountries = combinedCountries.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

                DispatchQueue.main.async {
                    self.isLoading = false
                    self.countries = sortedCountries
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = Self.apiErrorMessage(from: data) ?? "JSON parsing failed: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    private static func apiErrorMessage(from data: Data) -> String? {
        if let envelope = try? JSONDecoder().decode(APIErrorEnvelope.self, from: data),
           let message = envelope.errors?.first?.message,
           !message.isEmpty {
            return message
        }

        if let rawMessage = String(data: data, encoding: .utf8), !rawMessage.isEmpty {
            return rawMessage
        }

        return nil
    }
}

private struct APIErrorEnvelope: Decodable {
    let success: Bool?
    let errors: [APIErrorItem]?
}

private struct APIErrorItem: Decodable {
    let message: String
}