//
//  EstadisticasViewController.swift
//  MatrixCombo
//
//  Created by Desarrollo on 15/3/18.
//  Copyright © 2018 neteamador. All rights reserved.
//

import UIKit
import CoreData

class EstadisticasViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {

    func conexion() -> NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        celdaCollectionView2.delegate = self
        celdaCollectionView2.dataSource = self
        jugador2.text = jugadorSeleccionado.idJugador!
        self.variasPartidas2.dataSource = self
        self.variasPartidas2.delegate = self
        
        // Cargo las Partidas del Jugador en variasPartidasListaid
        let contexto = conexion()
        let peticion = NSFetchRequest<Partidas>(entityName: "Partidas")
        //        let string2 = String(2)
        peticion.predicate = NSPredicate(format: "idJugador == %@", jugadorSeleccionado.idJugador!)
        variasMatricesLista.removeAll()
        variasPartidaListaid.removeAll()
        variasPartidaListaidid.removeAll()
        variasMatricesListaId.removeAll()
        do {
            let resultados = try contexto.fetch(peticion)
            for res in resultados as [NSManagedObject] {
                variasPartidaListaid.append(res.value(forKey: "idPartida") as! Int32)
                variasMatricesListaId.append(Int64(res.value(forKey: "idMatriz") as! Int32))
            }
            idPartida2.text = "\(variasPartidaListaid[0])"
            idMatriz2.text = "\(variasMatricesListaId[0])"
        } catch let error as NSError {
            print("No pude recuperar datos \(error), \(error.userInfo)")
        }
        let contexto2 = conexion()
        let peticion2 = NSFetchRequest<Matrices>(entityName: "Matrices")
        variasMatricesListaCodigo.removeAll()
        for i in 0 ... variasMatricesListaId.count - 1 {
            let stringIdMatriz = String(variasMatricesListaId[i])
            peticion2.predicate = NSPredicate(format: "idMatrix == %@", stringIdMatriz)
            do {
                let resultados2 = try contexto2.fetch(peticion2)
                for res2 in resultados2 as [NSManagedObject] {
                    let textoPicker1 = res2.value(forKey: "idMatrix")!
                    let textoPicker3 = res2.value(forKey: "codigoMatriz")!
                    let textoPicker2 = res2.value(forKey: "version")!
                    let textoPicker4 = res2.value(forKey: "estado")!
                    let textoPicker = "id: \(String(describing: textoPicker1)) - V: \(String(describing: textoPicker2)) - E: \(String(describing: textoPicker4))- Cod: \(String(describing: textoPicker3))"
                    variasMatricesLista.append(textoPicker)
                    variasMatricesListaCodigo.append(res2.value(forKey: "codigoMatriz") as! Int64)
                    variasPartidaListaidid.append(variasPartidaListaid[i])
                }
                
            } catch let error as NSError {
                print("No pude recuperar datos \(error), \(error.userInfo)")
            }
        }
        pintarCeldas(codigoMatriz: Int32(variasMatricesListaCodigo[0]))
        // Do any additional setup after loading the view
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return variasMatricesLista.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return variasMatricesLista[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let fila = row
        let stringCodigoMatriz = String(variasMatricesListaCodigo [fila])
        let contexto = conexion()
        let peticion = NSFetchRequest<Matrices>(entityName: "Matrices")
        peticion.predicate = NSPredicate(format: "codigoMatriz == %@", stringCodigoMatriz)
        do {
            let resultados = try! contexto.fetch(peticion)
            let matriz = resultados.first!
            idMatriz2.text = "\(stringCodigoMatriz)"
            idPartida2.text = "\(variasPartidaListaidid[fila])"
            matrizSeleccionada = matriz
        }
        pintarCeldas(codigoMatriz: matrizSeleccionada.codigoMatriz)
    }
    
    func pintarCeldas(codigoMatriz: Int32) {
        // Borro Matrix por si la hubiera
        matrix.removeAll()
        //Leo las Celdas en orden de numCela
        let stringCodigoMatriz = String(codigoMatriz)
        let contexto3 = conexion()
        let peticion3 = NSFetchRequest<Celdas>(entityName: "Celdas")
        let orderBynumCelda = NSSortDescriptor(key: "numCelda", ascending: true)
        peticion3.sortDescriptors = [orderBynumCelda]
        peticion3.predicate = NSPredicate(format: "codigoMatriz == %@", stringCodigoMatriz)
        do {
            let resultados = try contexto3.fetch(peticion3)
            for res in resultados as [NSManagedObject] {
                matrix.append(res.value(forKey: "valorCelda") as! Int)
            }
        } catch let error as NSError {
            print("No pude recuperar datos de Celdas\(error), \(error.userInfo)")
        }
        self.celdaCollectionView2.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return matrix.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let celda = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! celdaCollectionViewCell
        celda.etiqueta2.text = self.imageData[self.matrix [indexPath.row]]
        celda.backgroundColor = UIColor.white
        celda.layer.cornerRadius = 10
        return celda
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sizePantalla = UIScreen.main.bounds
        let ancho = sizePantalla.width / 9.0
        return CGSize(width: ancho, height: ancho)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3.0
    }
    // Prueba de curso
    
    
    
    @IBOutlet weak var celdaCollectionView2: UICollectionView!
    @IBOutlet weak var variasPartidas2: UIPickerView!
    @IBOutlet weak var jugador2: UILabel!
    @IBOutlet weak var idPartida2: UILabel!
    @IBOutlet weak var idMatriz2: UILabel!
    
    @IBAction func volverAtras2(_ sender: Any) {
        let numDePartidaJugada = 1
        self.performSegue(withIdentifier: "volverDeEstadisticas", sender: numDePartidaJugada)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "volverDeEstadisticas" {
        }
    }
    // Variables
    var matrix: [Int] = [1,2,3,4,5,6,7,8,9,1,2,3,4,5,6,7,8,9,4,6,5,4,2,9,8,0,5,6,7,8,9]
    let imageData = [" ", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    var jugadorSeleccionado: Jugadores!
    var partidaSeleccionada: Partidas!
    var matrizSeleccionada: Matrices!
    var codigoDePartidaSeleccionada: Int64 = 0
    var variasMatricesLista: [String] = [String]()
    var variasPartidaListaid: [Int32] = [0]
    var variasPartidaListaidid: [Int32] = [0]
    var variasMatricesListaId: [Int64] = [0]
    var variasMatricesListaCodigo: [Int64] = [0]
    
    var nombreJugadorEstadisticas: String?


}
