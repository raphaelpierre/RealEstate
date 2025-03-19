import SwiftUI

struct OptimizedAsyncImage: View {
    let url: String
    let targetSize: CGSize
    
    @State private var image: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: targetSize.width, height: targetSize.height)
                    .clipped()
            } else {
                ProgressView()
                    .frame(width: targetSize.width, height: targetSize.height)
                    .onAppear { loadImage() }
            }
        }
    }
    
    private func loadImage() {
        guard !isLoading else { return }
        isLoading = true
        
        if let cachedImage = ImageCacheManager.shared.getImage(forKey: url) {
            self.image = cachedImage
            isLoading = false
            return
        }
        
        guard let imageURL = URL(string: url) else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            defer { isLoading = false }
            
            guard let data = data,
                  let downloadedImage = UIImage(data: data) else { return }
            
            // Resize image to target size
            let resizedImage = downloadedImage.resized(to: targetSize)
            
            DispatchQueue.main.async {
                ImageCacheManager.shared.setImage(resizedImage, forKey: url)
                self.image = resizedImage
            }
        }.resume()
    }
}

// UIImage extension for resizing
extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let ratio = min(widthRatio, heightRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
} 