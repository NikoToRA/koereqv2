import Foundation
import UIKit
import CoreImage

class QRService {
    func generate(text: String) -> UIImage {
        let data = text.data(using: .utf8)
        
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        qrFilter?.setValue(data, forKey: "inputMessage")
        qrFilter?.setValue("L", forKey: "inputCorrectionLevel") // ECC-L
        
        guard let qrImage = qrFilter?.outputImage else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledQrImage = qrImage.transformed(by: transform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledQrImage, from: scaledQrImage.extent) else {
            return UIImage(systemName: "xmark.circle") ?? UIImage()
        }
        
        return UIImage(cgImage: cgImage)
    }
}
