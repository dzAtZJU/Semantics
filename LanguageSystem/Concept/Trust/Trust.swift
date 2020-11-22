import Foundation

struct TrustInterpretation: Interpretation {
    // Do you think that most other people can be trusted?
    
    // Can be trusted
    // +: Most other people
    // format: Poll
    
    var caBeTrusted: [Opinion] = []
}
