import Combine
import Foundation

enum Mapbox {
    struct Account {
        let userName: String
        let secretAccessToken: String
    }
    
    struct UploadReq {
        let key: String
        let bucket: String
        let tilesetName: String
    }
    
    struct UploadRep: Decodable {
        let id: String
        let error: String
    }
    
    static func upload(_ req: UploadReq, account: Account) -> AnyPublisher<Mapbox.UploadRep, Error> {
        
        let urlStr = "https://api.mapbox.com/uploads/v1/\(account.userName)?access_token=\(account.secretAccessToken)"
        let url = URL(string: urlStr)!
        var urlReq = URLRequest(url: url)
        urlReq.httpMethod = "POST"
        let jsonStr = """
{
"url": "http://\(req.bucket).s3.amazonaws.com/\(req.key)",
"tileset": "\(account.userName).\(req.tilesetName)"
}
"""
        urlReq.httpBody = jsonStr.data(using: .utf8)
        return URLSession.shared
            .dataTaskPublisher(for: urlReq)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 201 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: UploadRep.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
