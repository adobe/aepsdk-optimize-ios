/*
Copyright 2021 Adobe. All rights reserved.
This file is licensed to you under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License. You may obtain a copy
of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under
the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
OF ANY KIND, either express or implied. See the License for the specific language
governing permissions and limitations under the License.
*/
    

import SwiftUI

struct ImageOfferView: View {
    @StateObject private var imageLoader: ImageLoader
    
    init(url: String) {
        _imageLoader = StateObject(wrappedValue: ImageLoader(urlString: url))
    }

    var body: some View {
        Image(uiImage: imageLoader.uiImage ?? UIImage())
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 150)
            .frame(maxWidth: .infinity)
    }
}

class ImageLoader: ObservableObject {
    @Published var uiImage: UIImage?

    init(urlString: String) {
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }

            DispatchQueue.main.async {
                self.objectWillChange.send()
                self.uiImage = UIImage(data: data)
            }
        }.resume()
    }
}

struct ImageOfferView_Previews: PreviewProvider {
    static var previews: some View {
        ImageOfferView(url: "https://gblobscdn.gitbook.com/spaces%2F-Lf1Mc1caFdNCK_mBwhe%2Favatar-1585843848509.png?alt=media")
    }
}
