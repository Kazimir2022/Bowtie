/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import CoreData

struct PetService {
  let context: NSManagedObjectContext

  func createPet(name: String) -> Pet {
    let pet = Pet(context: context)
    pet.name = name
    pet.animalType = "dog"

    return pet
  }

  func selectedPet() -> Pet? {
    guard let url =
            UserDefaults.standard.url(forKey: PetService.selectedPetKey),
          let coordinator = context.persistentStoreCoordinator,
          let objectID = coordinator.managedObjectID(forURIRepresentation: url)
    else {
      return nil
    }

    do {
      return try context.existingObject(with: objectID) as? Pet
    } catch {
      return nil
    }
  }

  func selectPet(_ pet: Pet) {
    UserDefaults.standard.set(pet.objectID.uriRepresentation(), forKey: PetService.selectedPetKey)
    UserDefaults.standard.synchronize()
  }

  func latestActivity(for activityType: Activity.ActivityType) -> NSFetchRequest<Activity> {
    let fetchRequest: NSFetchRequest<Activity> = Activity.fetchRequest()

    let activityTypePredicate = NSPredicate(format: "activityType == %@", argumentArray: [activityType.rawValue])

    if let pet = selectedPet() {
      let petPredicate = NSPredicate(format: "pet == %@", pet)
      fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [petPredicate, activityTypePredicate])
    } else {
      fetchRequest.predicate = activityTypePredicate
    }

    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    fetchRequest.fetchLimit = 1

    return fetchRequest
  }

  func activitiesFetchRequest(for pet: Pet?) -> NSFetchRequest<Activity> {
    let fetchRequest: NSFetchRequest<Activity> = Activity.fetchRequest()

    if let pet = pet {
      let petPredicate = NSPredicate(format: "pet == %@", pet)
      fetchRequest.predicate = petPredicate
    }

    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

    return fetchRequest
  }
}

extension PetService {
  static let selectedPetKey = "SelectedPet"
}
