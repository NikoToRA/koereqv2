import Foundation
import AzureStorage

class StorageService {
    private let sasToken: String
    private let facilityId: String
    private let containerName: String
    private let blobServiceClient: BlobServiceClient
    
    init(sasToken: String, facilityId: String, containerName: String = "koereq-data") {
        self.sasToken = sasToken
        self.facilityId = facilityId
        self.containerName = containerName
        
        self.blobServiceClient = BlobServiceClient(
            url: URL(string: "https://yourstorageaccount.blob.core.windows.net/\(containerName)?\(sasToken)")!
        )
    }
    
    func upload(session: Session) async throws {
        let containerClient = blobServiceClient.getBlobContainerClient(containerName: containerName)
        let sessionFolderPath = "\(facilityId)/\(session.id.uuidString)"
        
        let metaData = [
            "summary": session.summary,
            "started_at": ISO8601DateFormatter().string(from: session.startedAt),
            "ended_at": session.endedAt != nil ? ISO8601DateFormatter().string(from: session.endedAt!) : "",
            "version": "2.1"
        ]
        let metaJsonData = try JSONSerialization.data(withJSONObject: metaData, options: [.prettyPrinted])
        let metaBlobClient = containerClient.getBlobClient(blobName: "\(sessionFolderPath)/meta.json")
        
        _ = try await metaBlobClient.upload(
            data: metaJsonData,
            overwrite: true,
            metadata: ["content-type": "application/json"]
        )
        
        
    }
}
