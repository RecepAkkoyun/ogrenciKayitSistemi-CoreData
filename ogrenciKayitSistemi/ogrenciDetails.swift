//
//  ogrenciDetails.swift
//  ogrenciKayitSistemi
//
//  Created by Recep Akkoyun on 9.08.2022.
//

import UIKit
import CoreData

class ogrenciDetails: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ogrAdi: UITextField!
    @IBOutlet weak var ogrSoyadi: UITextField!
    @IBOutlet weak var ogrYasi: UITextField!
    @IBOutlet weak var ekleButonu: UIButton!
    
    
    var secilenOgrAdi = ""
    var secilenOgrId :  UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if secilenOgrAdi != ""{
            ekleButonu.isHidden = true
            if ogrAdi.text != "" || ogrSoyadi.text != ""{
                ekleButonu.isEnabled = false
            }
            
            if let ogrIdString = secilenOgrId?.uuidString{
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                 
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ogrenciler")
                fetchRequest.predicate = NSPredicate(format: "ogrId = %@", ogrIdString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let sonuclar = try context.fetch(fetchRequest)
                    
                    if sonuclar.count > 0{
                        
                        for sonuc in sonuclar as! [NSManagedObject] {
                            
                            if let isim = sonuc.value(forKey: "ogrAdi") as? String{
                                ogrAdi.text = isim
                            }
                            
                            if let soyisim = sonuc.value(forKey: "ogrSoyadi") as? String {
                                ogrSoyadi.text = soyisim
                            }
                            
                            if let yas = sonuc.value(forKey: "ogrYasi") as? Int {
                                ogrYasi.text = String(yas)
                            }
                            
                            if let gorsel = sonuc.value(forKey: "ogrGorsel") as? Data {
                                let image = UIImage(data: gorsel)
                                imageView.image = image
                            }
                            
                            
                            
                        }
                        
                        
                        
                    }
                    else{

                        
                    }
                    
                }catch{
                    print ("Hata")
                }
            }
        }
        else{
            ekleButonu.isEnabled = false
            ekleButonu.isHidden = false
        }
        
                
                
        
        //Klavyeyi Kapat
        let klavyegestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(klavyeyiKapat))
        view.addGestureRecognizer(klavyegestureRecognizer)
        //Fotoğraf işlemleri
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(fotografEkle))
        imageView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func klavyeyiKapat(){
        view.endEditing(true)
    }
    
    @objc func fotografEkle () {
    let fotograf = UIImagePickerController()
        fotograf.delegate = self
        fotograf.sourceType = .photoLibrary
        fotograf.allowsEditing = true
        present(fotograf, animated: true, completion: nil)
        
    }
    // Fotoğraf seçiminden sonra yapılan işlem
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage // ımageview in image'ini UIımage formatına dönüştür
        ekleButonu.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnEkle(_ sender: Any) {
        
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // AppDelegate erişmeye çalıştım.
        let context = appDelegate.persistentContainer.viewContext
        let KaydedilenOgrenci = NSEntityDescription.insertNewObject(forEntityName: "Ogrenciler", into: context)
        
        KaydedilenOgrenci.setValue(ogrAdi.text!, forKey: "ogrAdi")
        KaydedilenOgrenci.setValue(ogrSoyadi.text, forKey: "ogrSoyadi")
        KaydedilenOgrenci.setValue(UUID(), forKey: "ogrId")
        if let yas = Int(ogrYasi.text!){
            KaydedilenOgrenci.setValue(yas, forKey: "ogrYasi")
        let gorsel = imageView.image?.jpegData(compressionQuality: 0.5) //fotoğrafın boyutunu kalite açısından düşürüyoruz.
        KaydedilenOgrenci.setValue(gorsel, forKey: "ogrGorsel")
        
             do {
                try context.save()
                print("Kayıt Başarılı")
                }
                catch {
                    print("Hata!")
                }
            // veri kaydetmeyi güncelleyip bi önceki ekrana dönmek için.
            NotificationCenter.default.post(name: NSNotification.Name("veriGirildi"), object: nil)
            self.navigationController?.popViewController(animated: false )
            
        }
        
    }
    
}
