import Foundation

struct NetworkSpace {
    static let bgImageQueryingURL = URL(string: "https://127.0.0.1:8081/word_bg")!
    
    static func bgImageQueryingURL(forWord word: String) -> URL {
        return bgImageQueryingURL.appendingPathComponent(word)
    }
    
    static func validate(error: Error?, response: URLResponse?) -> Bool {
        if let error = error {
            handleClientError(error)
            return false
        }
        guard let httpResponse = response as? HTTPURLResponse,
            (200...299).contains(httpResponse.statusCode) else {
                handleServerError(response: response)
            return false
        }
        return true
    }
    
    static func handleClientError(_ error: Error) {
        
    }
    
    static func handleServerError(response: URLResponse?) {
        
    }
}
