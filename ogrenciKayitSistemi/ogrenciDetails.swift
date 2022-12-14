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
        //Foto??raf i??lemleri
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
    // Foto??raf se??iminden sonra yap??lan i??lem
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage // ??mageview in image'ini UI??mage format??na d??n????t??r
        ekleButonu.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func btnEkle(_ sender: Any) {
        
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // AppDelegate eri??meye ??al????t??m.
        let context = appDelegate.persistentContainer.viewContext
        let KaydedilenOgrenci = NSEntityDescription.insertNewObject(forEntityName: "Ogrenciler", into: context)
        
        KaydedilenOgrenci.setValue(ogrAdi.text!, forKey: "ogrAdi")
        KaydedilenOgrenci.setValue(ogrSoyadi.text, forKey: "ogrSoyadi")
        KaydedilenOgrenci.setValue(UUID(), forKey: "ogrId")
        if let yas = Int(ogrYasi.text!){
            KaydedilenOgrenci.setValue(yas, forKey: "ogrYasi")
        let gorsel = imageView.image?.jpegData(compressionQuality: 0.5) //foto??raf??n boyutunu kalite a????s??ndan d??????r??yoruz.
        KaydedilenOgrenci.setValue(gorsel, forKey: "ogrGorsel")
        
             do {
                try context.save()
                print("Kay??t Ba??ar??l??")
                }
                catch {
                    print("Hata!")
                }
            // veri kaydetmeyi g??ncelleyip bi ??nceki ekrana d??nmek i??in.
            NotificationCenter.default.post(name: NSNotification.Name("veriGirildi"), object: nil)
            self.navigationController?.popViewController(animated: false )
            
        }
        
    }
    
}
