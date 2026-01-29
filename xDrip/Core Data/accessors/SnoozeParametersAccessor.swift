import Foundation
import CoreData
import os

class SnoozeParametersAccessor {
    
    // MARK: - Properties
    
    /// CoreDataManager to use
    private let coreDataManager:CoreDataManager
    
    /// for logging
    private var log = OSLog(subsystem: ConstantsLog.subSystem, category: ConstantsLog.categoryApplicationDataSnoozeParameter)
    
    // MARK: - initializer
    
    init(coreDataManager:CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
   
    // MARK: Public functions
    
    /// - gets all SnoozeParameters instances from coredata
    /// - if this the first call to this function (ie no SnoozeParameters stored yet in coredata), then they will be created for every AlertKind
    /// - sorts them by AlertKind.rawvalue (from low to high), ie from 0 to (verylow) to 8 (fastrise)
    func getSnoozeParameters() -> [SnoozeParameters] {
        
        // create fetchRequest to get SnoozeParameters's as SnoozeParameters classes
        let snoozeParametersFetchRequest: NSFetchRequest<SnoozeParameters> = SnoozeParameters.fetchRequest()
        
        // sort by alertkind from low to high
        snoozeParametersFetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(SnoozeParameters.alertKind), ascending: true)]
        
        // fetch the SnoozeParameterss
        var snoozeParameterArray = [SnoozeParameters]()
        coreDataManager.mainManagedObjectContext.performAndWait {
            do {
                // Execute Fetch Request
                snoozeParameterArray = try snoozeParametersFetchRequest.execute()
            } catch {
                let fetchError = error as NSError
                trace("in getSnoozeParameterss, Unable to Execute SnoozeParameterss Fetch Request : %{public}@", log: self.log, category: ConstantsLog.categoryApplicationDataSnoozeParameter, type: .error, fetchError.localizedDescription)
            }
        }
        
        // Check for missing AlertKinds and add them if necessary
        // This handles cases where new AlertKinds were added or data is missing/corrupted
        let existingAlertKinds = Set(snoozeParameterArray.map { Int($0.alertKind) })
        
        for alertKind in AlertKind.allCases {
            if !existingAlertKinds.contains(alertKind.rawValue) {
                snoozeParameterArray.append(
                    SnoozeParameters(
                        alertKind: alertKind,
                        snoozePeriodInMinutes: 0,
                        snoozeTimeStamp: nil,
                        nsManagedObjectContext: coreDataManager.mainManagedObjectContext
                    )
                )
            }
        }
        
        // Ensure the array is consistently sorted by alertKind
        snoozeParameterArray.sort { $0.alertKind < $1.alertKind }
        
        return snoozeParameterArray
        
    }


}
