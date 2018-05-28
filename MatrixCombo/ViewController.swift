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
    var partidaComboSeleccionada: PartidasCombo!
    var matrizComboCreada: MatricesCombo!
    
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
            print("No pude recuperar datos de jugador: \(nombreJugador) Error: \(error), \(error.userInfo)")
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
            // La info del Ordenador y la del nuevo Jugador ya están guardadas
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
        if segue.identifier == "eleccionTipo" {
            let objJugar: ElegirTipoViewController =  segue.destination as! ElegirTipoViewController
            objJugar.numCasillasOriginal = numCasillas            
            objJugar.jugadorSeleccionado = jugadorSeleccionado
            objJugar.partidaComboSeleccionada = partidaComboSeleccionada
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
        let peticion = NSFetchRequest<PartidasCombo>(entityName: "PartidasCombo")
        peticion.predicate = NSPredicate(format: "idJugador == %@ && estado == %@", jugadorSeleccionado.idJugador!, "1")
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
        self.performSegue(withIdentifier: "eleccionTipo", sender: numCasillas)
    }
    // Módulo MatricesCombo
    var matrizAGrabar: MatricesCombo!
    var cantidadMatrices: Int = 0
    var codigoMatrizCreada: Int32 = 0
    var numCasillasNueva: Int32 = 0
    var modoDeJuego: String = "Libre"
    var tipoDePartida: Int16 = 5
    var matrixPartidaOriginal: [Int] = [Int]()     // Tiene los valores de TODAS LAS CELDAS ORIGINALES
    // Buscar el codigoMatriz nuevo
    func buscarCodigoMatrizCombo() -> Int32{
        do {
            let contexto = conexion()
            let peticion = NSFetchRequest<MatricesCombo>(entityName: "MatricesCombo")
            let orderByCodigoMatriz = NSSortDescriptor(key: "codigoMatriz", ascending: false)
            peticion.sortDescriptors = [orderByCodigoMatriz]
            peticion.fetchLimit = 1
            let resultados = try contexto.fetch(peticion)
            return resultados[0].codigoMatriz + 1
        } catch let error as NSError {
            print("No pude recuperar datos \(error), \(error.userInfo)")
        }
        print("No pude recuperar MatricesCombo para buscar el código siguiente")
        return 1
    }
    // Funciones para pasar de String a Matriz y viceversa
    var matrizString: String = ""
    var matrizDeVuelta: [Int] = [Int]()
    func cambiarMatrizAString(matrizAString: [Int]) -> String {
        matrizString = ""
        for i in 0 ... matrizAString.count - 1 {
            matrizString = matrizString + String(describing: matrizAString[i])
        }
        return matrizString
    }
    func cambiarStringAMatriz(stringAMatriz: String) -> [Int] {
        matrizDeVuelta.removeAll()
        for c in stringAMatriz {
            matrizDeVuelta.append(Int(String(c))!)
        }
        return matrizDeVuelta
    }
    func pintarMatricesCombo() {
        let contexto = conexion()
        let peticion = NSFetchRequest<MatricesCombo>(entityName: "MatricesCombo")
        let orderByCodigoMatriz = NSSortDescriptor(key: "codigoMatriz", ascending: true)
        peticion.sortDescriptors = [orderByCodigoMatriz]
        let resultados = try! contexto.fetch(peticion)
        for res in resultados {
            print(" matrizCombo: \(res)")
        }
        if resultados.count == 0 {
            print("Error al leer MatricesCombo:")
        }
    }
    
    

     /*
     func crearTiposDePartida() {
     tiposDePartida.append([1,1,90,90])          // tipoJuego = "facilon"
     tiposDePartida.append([2,1,180,180])          // tipoJuego = "suave"
     tiposDePartida.append([3,1,270,270])          // tipoJuego = "regu"
     tiposDePartida.append([4,1,666,666])          // tipoJuego = "desafío"
     tiposDePartida.append([5,4,66,666])          // tipoJuego = "ikea"
     tiposDePartida.append([6,4,100,1001])          // tipoJuego = "purgatorio"
     tiposDePartida.append([7,4,166,1666])          // tipoJuego = "tinieblas"
     tiposDePartida.append([8,4,200,2001])          // tipoJuego = "infierno 1"
     tiposDePartida.append([9,4,333,3333])          // tipoJuego = "infierno 2"
     tiposDePartida.append([10,4,500,5005])          // tipoJuego = "infierno 3"
     }
     */
     
    
    
    
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
    var idPartidaComboCreada: Int32 = 0
//    var nuevaPartida: Bool = false
    
}

