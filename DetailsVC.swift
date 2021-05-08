//
//  DetailsVC.swift
//  ArtBookApp
//
//  Created by Burak Karakoç on 23.04.2020.
//  Copyright © 2020 Burak Karakoç. All rights reserved.
//

import UIKit
import CoreData


class DetailsVC: UIViewController , UINavigationControllerDelegate , UIImagePickerControllerDelegate{
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var artistLabel: UITextField!
    @IBOutlet weak var yearLabel: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenPainting = ""
    var chosenID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if chosenPainting != "" {
            
            saveButton.isHidden = true
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetchRequest.returnsObjectsAsFaults = false
            let idString = chosenID?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String {
                            nameLabel.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            artistLabel.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearLabel.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                            
                        }
                    }
                }
            } catch {
            }
        }
        else if chosenPainting == "" {
            
            saveButton.isHidden = false
            saveButton.isEnabled = false
            
        }
            
        
        
        let keyboardClosingGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(keyboardClosingGesture)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTap))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
    }
    
    @objc func imageTap() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    

    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        newPainting.setValue(nameLabel.text, forKey: "name")
        newPainting.setValue(artistLabel.text, forKey: "artist")
        if let year = Int(yearLabel.text!) {
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
        } catch {
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newData"), object: nil)
        
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    
    

}
