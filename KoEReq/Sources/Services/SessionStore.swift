import Foundation
import CoreData

class SessionStore {
    private let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "KoEReqModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("CoreData failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    func saveSession(_ session: Session) {
        let context = container.viewContext
        let sessionEntity = SessionEntity(context: context)
        sessionEntity.id = session.id
        sessionEntity.startedAt = session.startedAt
        sessionEntity.endedAt = session.endedAt
        sessionEntity.summary = session.summary
        
        
        do {
            try context.save()
        } catch {
            print("Failed to save session: \(error.localizedDescription)")
        }
    }
    
    func fetchSessions() -> [Session] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<SessionEntity> = SessionEntity.fetchRequest()
        
        do {
            let sessionEntities = try context.fetch(fetchRequest)
            return sessionEntities.map { entity in
                Session(id: entity.id ?? UUID(), startedAt: entity.startedAt ?? Date())
            }
        } catch {
            print("Failed to fetch sessions: \(error.localizedDescription)")
            return []
        }
    }
}
