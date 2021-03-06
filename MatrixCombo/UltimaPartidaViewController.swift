//
//  UltimaPartidaViewController.swift
//  MatrixCombo
//
//  Created by Edu Ardo on 14/3/18.
//  Copyright © 2018 neteamador. All rights reserved.
//

import UIKit
import CoreData

class UltimaPartidaViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var contexto: NSManagedObjectContext!
    
    // defino la variable donde guardo el jugador seleccionado
    var jugadorSeleccionado: Jugadores!
    var partidaSeleccionada: Partidas!
//    var partidaUsada: Partidas!
    var codigoDePartidaSeleccionada: Int = 0
    var numCasillas: Int = 0
    
    
    func conexion() -> NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        nombreJugador2.text = jugadorSeleccionado.idJugador
        let datosFechaJugador = jugadorSeleccionado.fechaInicio as Date?
        let formatoFecha = DateFormatter()
        formatoFecha.dateStyle = .short
        formatoFecha.timeStyle = .none
        fechaJugador2.text = formatoFecha.string(from: datosFechaJugador!)
        self.variasPartidas2.dataSource = self
        self.variasPartidas2.delegate = self
        
        // Cargo las Partidas del Jugador en variasPartidasLista
        let contexto = conexion()
        let peticion = NSFetchRequest<Partidas>(entityName: "Partidas")
        peticion.predicate = NSPredicate(format: "idJugador == %@ && estado < %@ AND versionActual < %@", jugadorSeleccionado.idJugador!, "2", "11")
        variasPartidaLista.removeAll()
        variasPartidaListaid.removeAll()
        do {
            let resultados = try contexto.fetch(peticion)
            if resultados.count > 0 {
                hayPartidas = true
                for res in resultados as [NSManagedObject] {
                    let datosFechaPartida = res.value(forKey: "fechaInicial")
                    let formatoFecha = DateFormatter()
                    formatoFecha.dateStyle = .short
                    formatoFecha.timeStyle = .none
                    let textoPicker2 = formatoFecha.string(from: datosFechaPartida! as! Date)
                    let textoPicker3 = res.value(forKey: "versionActual")!
                    let textoPicker = "\(String(describing: textoPicker2)) - V: \(String(describing: textoPicker3))"
                    variasPartidaLista.append(textoPicker)
                    variasPartidaListaid.append(res.value(forKey: "idPartida") as! Int32)
                }
                idPartida2.text = "\(variasPartidaListaid[0])"
            } else {
                hayPartidas = false
            }
            
        } catch let error as NSError {
            print("No pude recuperar datos \(error), \(error.userInfo)")
        }
        if hayPartidas == false {
            //          irAtras(_)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "jugarPartidaSegue" {
            let contexto = conexion()
            let peticion = NSFetchRequest<Partidas>(entityName: "Partidas")
            peticion.predicate = NSPredicate(format: "idPartida == %@", idPartida2.text!)
            do {
                let resultados = try! contexto.fetch(peticion)
                let partida = resultados.first!
                partidaSeleccionada = partida
            }
            let objJugar: JugarViewController =  segue.destination as! JugarViewController
            objJugar.partidaSeleccionada = partidaSeleccionada
            objJugar.jugadorSeleccionado = jugadorSeleccionado
        } else {
            if segue.identifier == "atrasSegue" {
            }
        }
    }
    
    @IBOutlet weak var nombreJugador2: UILabel!
    @IBOutlet weak var fechaJugador2: UILabel!
    @IBOutlet weak var idPartida2: UILabel!
    
    @IBOutlet weak var variasPartidas2: UIPickerView!
    
    @IBAction func jugarPartida2(_ sender: Any) {
        self.performSegue(withIdentifier: "jugarPartidaSegue", sender: numCasillas)
    }
    @IBAction func irAtras2(_ sender: Any) {
        self.performSegue(withIdentifier: "atrasSegue", sender: numCasillas)
    }
    
    var numeroUltimaPartida: String?
    var variasPartidaLista: [String] = [String]()
    var variasPartidaListaid: [Int32] = [0]
    var hayPartidas: Bool = false
    
    // Funciones del PickView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return variasPartidaLista.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return variasPartidaLista[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let fila = row
        let nombrePartida = String(variasPartidaListaid [fila])
        let contexto = conexion()
        let peticion = NSFetchRequest<Partidas>(entityName: "Partidas")
        peticion.predicate = NSPredicate(format: "idPartida == %@", nombrePartida)
        do {
            let resultados = try! contexto.fetch(peticion)
            let partida = resultados.first!
            idPartida2.text = "\(nombrePartida)"
            partidaSeleccionada = partida
        }
    }
    
}
