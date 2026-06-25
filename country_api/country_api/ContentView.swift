
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CountryViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Group {
                    if viewModel.isLoading {
                        ProgressView("Loading countries...")
                    } else if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 16) {
                            Text("Unable to load countries")
                                .font(.headline)
                            Text(errorMessage)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                            Button("Try Again") {
                                viewModel.fetchCountries()
                            }
                        }
                        .padding()
                    } else {
                        List(viewModel.countries) { country in
                            NavigationLink(destination: CountryDetailView(country: country)) {
                                CountryRowView(country: country)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                FooterView()
            }
            .navigationTitle("Countries")
        }
        .onAppear {
            if viewModel.countries.isEmpty {
                viewModel.fetchCountries()
            }
        }
    }
}

private struct CountryRowView: View {
    let country: Country

    var body: some View {
        HStack(spacing: 12) {
            CountryFlagImage(urlString: country.flagURLString)

            VStack(alignment: .leading, spacing: 4) {
                Text(country.name)
                    .font(.headline)

                Text("Capital: \(country.capital)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct CountryDetailView: View {
    let country: Country

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    CountryFlagImage(urlString: country.flagURLString)
                        .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 12) {
                        detailRow(title: "Country Name", value: country.name)
                        detailRow(title: "Official Name", value: country.officialName)
                        detailRow(title: "Capital", value: country.capital)
                        detailRow(title: "Region", value: country.region)
                        detailRow(title: "Population", value: NumberFormatter.localizedString(from: NSNumber(value: country.population), number: .decimal))
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                }
                .padding()
            }
            FooterView()
        }
        .navigationTitle(country.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value.isEmpty ? "N/A" : value)
                .font(.body)
        }
    }
}

private struct FooterView: View {
    var body: some View {
        Text("by 2107039 with love ❤️")
            .font(.footnote)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(UIColor.systemBackground))
    }
}

private struct CountryFlagImage: View {
    let urlString: String

    var body: some View {
        if #available(iOS 15.0, *) {
            AsyncImage(url: URL(string: urlString)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    placeholder
                case .empty:
                    ProgressView()
                @unknown default:
                    placeholder
                }
            }
        } else {
            RemoteImage(urlString: urlString)
        }
    }

    private var placeholder: some View {
        ZStack {
            Rectangle()
                .fill(Color(UIColor.secondarySystemBackground))
            Image(systemName: "flag")
                .font(.largeTitle)
                .foregroundColor(.secondary)
        }
        .frame(width: 70, height: 46)
        .cornerRadius(8)
    }
}

private struct RemoteImage: View {
    let urlString: String
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                placeholder
                    .onAppear(perform: loadImage)
            }
        }
    }

    private func loadImage() {
        guard image == nil, let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let loadedImage = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                image = loadedImage
            }
        }.resume()
    }

    private var placeholder: some View {
        ZStack {
            Rectangle()
                .fill(Color(UIColor.secondarySystemBackground))
            ProgressView()
        }
        .frame(width: 70, height: 46)
        .cornerRadius(8)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
