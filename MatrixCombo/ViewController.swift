//
//  ViewController.swift
//  MatrixCombo
//
//  Created by Edu Ardo on 12/3/18.
//  Copyright © 2018 neteamador. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var contexto: NSManagedObjectContext!
    
    // defino la variable donde guardo el jugador seleccionado
    var jugadorSeleccionado: Jugadores!
    var partidaSeleccionada: Partidas!
    var partidaCreada: Partidas!
    
    func conexion() -> NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }    

    // Funciones del Sistema
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.variosJugadores2.dataSource = self
        self.variosJugadores2.delegate = self
        textoCasillasDefecto2.delegate = self
        esPrimeraVez()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if primerJugador {
            nuevoJugador()
            primerJugador = false
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Funciones del PickView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return variosJugadoresLista.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return variosJugadoresLista[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let fila = row
        let nombreJugador = variosJugadoresLista [fila]
        let contexto = conexion()
        let peticion = NSFetchRequest<Jugadores>(entityName: "Jugadores")
        peticion.predicate = NSPredicate(format: "idJugador == %@", nombreJugador)
        do {
            let resultados = try contexto.fetch(peticion)
            let jugador = resultados.first!
            jugadorSeleccionado = jugador
            pintarJugador(jugador: self.jugadorSeleccionado)
        } catch let error as NSError {
            print("No pude recuperar datos \(error), \(error.userInfo)")
        }
    }
    
    // Funciones de carga de primeros datos
    
    func esPrimeraVez() {
        let contexto = conexion()
        let peticionJugadores = NSFetchRequest<Jugadores>(entityName: "Jugadores")
        peticionJugadores.predicate = NSPredicate(format: "idJugador != nil")
        let cantidadJugadores = try! contexto.count(for: peticionJugadores)
        if cantidadJugadores == 0 {
            // Grabamos los datos iniciales del Ordenador            
            let entidad = NSEntityDescription.entity(forEntityName: "Jugadores", in: contexto)!
            let jugador = Jugadores(entity: entidad,insertInto: contexto)
            jugador.idJugador = "Ordenador"
            jugador.fechaInicio = NSDate() as Date
            jugador.numCasillasDefecto = 30
            jugador.puntosTotal = 0
            jugador.filasTotal = 0
            jugador.paresTotal = 0
            jugador.partidasTotal = 0
            jugador.columnasTotal = 0
            jugador.passJugador = "passOrdenador"
            try! contexto.save()
            // preparo para que pida el nombre de un nuevo Jugador
            self.primerJugador = true
            return
        }  else {
            // La info del Jugadores.Ordenador y la del nuevo Jugador ya están guardadas
            let contexto = conexion()
            let peticion = NSFetchRequest<Jugadores>(entityName: "Jugadores")
            let ordenador = "Ordenador"
            peticion.predicate = NSPredicate(format: "idJugador != %@", ordenador)
            // Pintar en ViewController los datos del Jugador
            variosJugadoresLista.removeAll()
            do {
                let resultados = try contexto.fetch(peticion)
                for res in  resultados as [NSManagedObject] {
                    variosJugadoresLista.append(res.value(forKey: "idJugador") as! String)
                }
                let jugador = resultados.first!
                jugadorSeleccionado = jugador
                pintarJugador(jugador: self.jugadorSeleccionado)
            } catch let error as NSError {
                print("No pude recuperar datos \(error), \(error.userInfo)")
            }
            self.primerJugador = false
            return
        }
    }    
    func nuevoJugador() {
        let contexto = conexion()
        let entidad = NSEntityDescription.entity(forEntityName: "Jugadores", in: contexto)!
        let jugador = Jugadores(entity: entidad,insertInto: contexto)
        // Grabamos los datos del nuevo Jugador pidiendo los datos con una alerta
        let alerta = UIAlertController(title: "Nuevo Jugador", message: "Pon tu nombre de Jugador", preferredStyle: .alert)
        let leerJugador = UIAlertAction(title: "Agregar", style: .default, handler: {
            (action:UIAlertAction) -> Void in
            let textField = alerta.textFields!.first
            let idJugador = textField!.text!
            jugador.idJugador = textField!.text!
            jugador.fechaInicio = NSDate() as Date
            jugador.numCasillasDefecto = 30
            jugador.puntosTotal = 0
            jugador.filasTotal = 0
            jugador.paresTotal = 0
            jugador.partidasTotal = 0
            jugador.columnasTotal = 0
            jugador.passJugador = "passJugador"
            try! contexto.save()
            self.primerJugador = false
            self.jugadorSeleccionado = jugador
            self.pintarJugador(jugador: self.jugadorSeleccionado)
            self.variosJugadoresLista.append(idJugador)
            self.variosJugadores2.reloadAllComponents()
        })
        let cancelar = UIAlertAction(title: "Cancelar", style: .default)
        {(action: UIAlertAction) -> Void in }
        
        alerta.addTextField {(textField:UITextField) -> Void in}
        alerta.addAction(leerJugador)
        alerta.addAction(cancelar)
        present(alerta, animated: true, completion: nil)
    }
    func pintarJugador(jugador: Jugadores) {
        // Escribo el Jugador y leo los datos del mismo
        
        let datosFechaInicio = jugador.fechaInicio as Date?
        let formatoFecha = DateFormatter()
        formatoFecha.dateStyle = .short
        formatoFecha.timeStyle = .none
        textoJugador2.text = jugador.idJugador
        textoFechaInicio2.text = formatoFecha.string(from: datosFechaInicio!)
        textoCasillasDefecto2.text = "\(jugador.numCasillasDefecto)"
        textoPuntosTotal2.text = "\(jugador.puntosTotal)"
        textoTotalPartidas2.text = "\(jugador.partidasTotal)"
    }
    
    // Control de flujo
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "jugarSegue" {
            let objJugar: JugarViewController =  segue.destination as! JugarViewController
            objJugar.numCasillasOriginal = numCasillas
            objJugar.jugadorSeleccionado = jugadorSeleccionado
  //          objJugar.matrix = matrix
            objJugar.partidaSeleccionada = partidaSeleccionada
        } else if segue.identifier == "ultimaPartidaSegue" {
                let objUltimaPartida: UltimaPartidaViewController =  segue.destination as! UltimaPartidaViewController
                objUltimaPartida.jugadorSeleccionado = jugadorSeleccionado
        } else if segue.identifier == "estadisticasSegue" {
            let objEstadisticas: EstadisticasViewController =  segue.destination as! EstadisticasViewController
            objEstadisticas.jugadorSeleccionado = jugadorSeleccionado
        } else if segue.identifier == "errorCasillas" {
                    let mensajeError = sender as! String
                    textoCasillasDefecto2.text = mensajeError
            }        
    }
    
    // IBOulets

    @IBOutlet weak var textoJugador2: UILabel!
    @IBOutlet weak var textoCasillasDefecto2: UITextField!
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textoCasillasDefecto2.resignFirstResponder()
        return true
    }
    @IBOutlet weak var textoFechaInicio2: UILabel!
    @IBOutlet weak var textoTotalPartidas2: UILabel!
    @IBOutlet weak var textoPuntosTotal2: UILabel!
    @IBOutlet weak var variosJugadores2: UIPickerView!
    
    @IBAction func pulsaUltimaPartida2(_ sender: Any) {
        // Compruebo que hay Partidas sin finalizar del Jugador
        let contexto = conexion()
        let peticion = NSFetchRequest<Partidas>(entityName: "Partidas")
        peticion.predicate = NSPredicate(format: "idJugador == %@ && estado < %@", jugadorSeleccionado.idJugador!, "2")
        do {
            let resultados = try contexto.fetch(peticion)
            if resultados.count > 0 {
                self.performSegue(withIdentifier: "ultimaPartidaSegue", sender: nombreJugador)
            }
        } catch let error as NSError {
            print("No pude recuperar datos \(error), \(error.userInfo)")
        }
    }
    @IBAction func pulsaEstadisticas2(_ sender: Any) {
        if jugadorSeleccionado.partidasTotal > 0 {
            let nombreJugadorEstadisticas = nombreJugador
            self.performSegue(withIdentifier: "estadisticasSegue", sender: nombreJugadorEstadisticas)
        }
    }
    @IBAction func NuevaPartida2(_ sender: Any) {
        let a: Int? = Int(textoCasillasDefecto2.text!)
        if (a != nil) {
            numCasillas = a!
        } else {
            textoCasillasDefecto2.text = "Número"
            return
        }
        crearPartida()
        partidaSeleccionada = partidaCreada
        let contexto = conexion()
        let partidas = jugadorSeleccionado.partidasTotal + 1
        jugadorSeleccionado.partidasTotal = partidas
//        idJugadorJugar = jugadorSeleccionado.idJugador
        do {
            try contexto.save()
        } catch let error as NSError {
            print("no puedo actualizar número de partidas del jugador", error)
        }
        self.performSegue(withIdentifier: "jugarSegue", sender: numCasillas)
    }
    func crearPartida() {
        let contexto = conexion()
        // Leo cuántas partidas hay ya y sumo 1 al idPartida
        let peticion = NSFetchRequest<Partidas>(entityName: "Partidas")
        peticion.predicate = NSPredicate(format: "idPartida != nil")
        cantidadPartidas = try! contexto.count(for: peticion)
        idPartidaCreada = cantidadPartidas + 1
        // Inserto una fila en Partidas con el idJugador y a cero resto
        let entidad = NSEntityDescription.entity(forEntityName: "Partidas", in: contexto)!
        partidaCreada = Partidas(entity: entidad,insertInto: contexto)
        partidaCreada.idPartida = Int32(idPartidaCreada)
        partidaCreada.fechaInicial = NSDate() as Date
        partidaCreada.idJugador = jugadorSeleccionado.idJugador
        partidaCreada.estado = 0
        partidaCreada.versionActual = 0
        partidaCreada.idMatriz = 0
        partidaCreada.filasJugador = 0
        partidaCreada.filasOrdenador = 0
        partidaCreada.numCasillasOriginal = Int16(numCasillas)
        partidaCreada.paresJugador = 0
        partidaCreada.paresOrdenador = 0
        partidaCreada.puntosJugador = 0
        partidaCreada.puntosOrdenador = 0
        try! contexto.save()
    }
    
    // Variables
    
    var nombreJugador: String = "Edu"
//    var numPartida: Int = 0
    
    var primerJugador: Bool = false
//    var hayPartida: Bool = false
    
    var variosJugadoresLista: [String] = [String]()
    
//    var nombreJugadorDeVuelta: String = "Jugador de vuelta"
//    var matrix: [Int] = [Int]()
//    var matrix2: [Int] = [Int]()
    var numCasillas: Int = 0
//    var numeroUltimaPartida2: String = "última"
    
    var cantidadPartidas: Int = 0
//    var idJugadorJugar: String?
    var idPartidaCreada: Int = 0
//    var nuevaPartida: Bool = false
    
}

