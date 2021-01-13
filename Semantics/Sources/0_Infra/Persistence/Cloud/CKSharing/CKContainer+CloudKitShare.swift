/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The extension of CKContainer which implements some convenient methods related to sharing and account checking.
*/

import UIKit
import CloudKit

extension CKContainer { // MARK: - Account checking
    
    func checkAccountStatus(completionHandler: @escaping ((Bool, CKRecord.ID?, Error?) -> Void)) {
        accountStatus { (status, error) in
            guard handleCloudKitError(error, operation: .accountStatus, alert: true) == nil && status == .available else {
                return DispatchQueue.main.async { completionHandler(false, nil, nil) }
            }
            
            self.fetchUserRecordID { (userRecordID, error) in
                _ = handleCloudKitError(error, operation: .fetchUserID, alert: false)
                DispatchQueue.main.async { completionHandler(true, userRecordID, error) }
            }
        }
    }
}

extension CKContainer { // MARK: - Sharing
    
    // Create a UICloudSharingController instance for a shared root record.
    // Fetch the share of the root record, use it to create a UICloudSharingController instance
    // in fetchRecordsCompletionBlock, and pass the controller to completionHandler.
    //
    private func newSharingController(sharedRootRecord: CKRecord,
                                      database: CKDatabase,
                                      completionHandler: @escaping (UICloudSharingController?) -> Void) {
        let shareRecordID = sharedRootRecord.share!.recordID
        let fetchRecordsOp = CKFetchRecordsOperation(recordIDs: [shareRecordID])

        fetchRecordsOp.fetchRecordsCompletionBlock = { recordsByRecordID, error in
            guard handleCloudKitError(error, operation: .fetchRecords, affectedObjects: [shareRecordID]) == nil,
                let share = recordsByRecordID?[shareRecordID] as? CKShare else { return }
            
            DispatchQueue.main.async {
                let sharingController = UICloudSharingController(share: share, container: self)
                completionHandler(sharingController)
            }
        }
        database.add(fetchRecordsOp)
    }

    // Create a UICloudSharingController instance for a root record that has not been shared.
    // Create and save the CKShare record first.
    //
    private func newSharingController(unsharedRootRecord: CKRecord,
                                      database: CKDatabase,
                                      completionHandler: (UICloudSharingController?) -> Void) {
        let sharingController = UICloudSharingController { (_, prepareCompletionHandler) in
            let operationQueue = OperationQueue()
            operationQueue.maxConcurrentOperationCount = 1

            var share = CKShare(rootRecord: unsharedRootRecord)
            share[CKShare.SystemFieldKey.title] = "A cool topic to share!" as CKRecordValue
            share.publicPermission = .readWrite
                        
            // Save the share. Must save the root record and the CKShare record at the same time.
            // Use the serverRecord when a partial failure caused by .serverRecordChanged occurs.
            // Let UICloudSharingController handle the other error, until failedToSaveShareWithError is called.
            //
            let modifyRecordsOp = CKModifyRecordsOperation(recordsToSave: [share, unsharedRootRecord], recordIDsToDelete: nil)
            modifyRecordsOp.modifyRecordsCompletionBlock = { records, recordIDs, error in
                
                if let ckError = handleCloudKitError(error, operation: .modifyRecords, affectedObjects: [share.recordID]) {
                    if let serverVersion = ckError.serverRecord as? CKShare {
                        share = serverVersion
                    }
                }
                prepareCompletionHandler(share, self, error)
            }
            modifyRecordsOp.database = database
            operationQueue.addOperation(modifyRecordsOp)
        }
        
        // This is in the main queue (as UICloudSharingController is used here) so no dispatch needed.
        completionHandler(sharingController)
    }
    
    // Set up UICloudSharingController for a root record asynchronously.
    // This method must be called from the main queue. The completion handler is called from main queue.
    //
    func prepareSharingController(rootRecord: CKRecord,
                                  database: CKDatabase,
                                  completionHandler: @escaping (UICloudSharingController?) -> Void) {
        if rootRecord.share != nil {
            newSharingController(sharedRootRecord: rootRecord, database: database,
                                 completionHandler: completionHandler)
        } else {
            newSharingController(unsharedRootRecord: rootRecord, database: database,
                                 completionHandler: completionHandler)
        }
    }
}
