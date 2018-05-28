//
//  ElegirTipoViewController.swift
//  MatrixCombo
//
//  Created by Edu Ardo on 15/5/18.
//  Copyright © 2018 neteamador. All rights reserved.
//

import UIKit
import CoreData

var contexto: NSManagedObjectContext!



class ElegirTipoViewController: UIViewController {
    // defino la variable donde guardo el jugador seleccionado
    var jugadorSeleccionado: Jugadores!
    var partidaComboSeleccionada: PartidasCombo!
    var matrizComboCreada: MatricesCombo!
    
    func conexion() -> NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func prepararJuego() {
        codigoMatrizCreada = crearMatricesCombo(tipoPartida: tipoDePartida)
        // Nos devuelva el codigoMatrizCreada y el numCasillasNueva
        crearPartidaCombo()
        let contexto = conexion()
        let partidas = jugadorSeleccionado.partidasTotal + 1
        jugadorSeleccionado.partidasTotal = partidas
        //        idJugadorJugar = jugadorSeleccionado.idJugador
        do {
            try contexto.save()
        } catch let error as NSError {
            print("no puedo actualizar número de partidas del jugador", error)
        }
        self.performSegue(withIdentifier: "irAJugar", sender: numCasillas)
    }
    
    func crearPartidaCombo() {
        let contexto = conexion()
        // Leo cuántas partidas hay ya y sumo 1 al idPartida
        let peticion = NSFetchRequest<PartidasCombo>(entityName: "PartidasCombo")
        peticion.predicate = NSPredicate(format: "codigoPartida != nil")
        let cantidadPartidasCombo = try! contexto.count(for: peticion)
        idPartidaComboCreada = Int32(cantidadPartidasCombo + 1)
        // Inserto una fila en Partidas con el idJugador, fecha, casillas y tipo, a cero el resto
        let entidad = NSEntityDescription.entity(forEntityName: "PartidasCombo", in: contexto)!
        partidaComboSeleccionada = PartidasCombo(entity: entidad,insertInto: contexto)
        partidaComboSeleccionada.codigoPartida = idPartidaComboCreada
        partidaComboSeleccionada.celdasInicial = cambiarMatrizAString(matrizAString: matrixPartidaOriginal)
        partidaComboSeleccionada.celdasFinal = ""
        partidaComboSeleccionada.codigoMatriz = codigoMatrizCreada
        partidaComboSeleccionada.fechaInicio = NSDate() as Date
        partidaComboSeleccionada.idJugador = jugadorSeleccionado.idJugador
        partidaComboSeleccionada.estado = 0
        partidaComboSeleccionada.version = 0    // Esto indicará que es nueva
        partidaComboSeleccionada.filasBlancoJugador = 0
        partidaComboSeleccionada.filasBlancoOrdenador = 0
        partidaComboSeleccionada.numCasillasOriginal = numCasillasNueva
        partidaComboSeleccionada.paresJugador = 0
        partidaComboSeleccionada.paresOrdenador = 0
        partidaComboSeleccionada.puntosJugador = 0
        partidaComboSeleccionada.puntosOrdenador = 0
        partidaComboSeleccionada.estado = 0
        partidaComboSeleccionada.tipoPartida = tipoDePartida
        partidaComboSeleccionada.modoJuego = modoDeJuego
        try! contexto.save()
    }
    // Módulo MatricesCombo
    var numCasillas: Int = 0
    var idPartidaComboCreada: Int32 = 0
    var numCasillasOriginal: Int = 0
    var numDePartidaJugada: Int = 0
    var matrizAGrabar: MatricesCombo!
    var cantidadMatrices: Int = 0
    var codigoMatrizCreada: Int32 = 0
    var aleatorio: Int = 0
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
    func crearMatricesCombo(tipoPartida: Int16) -> Int32 {
        // Es nueva hay que crear MatricesCombo
        let contexto = conexion()
        let peticion = NSFetchRequest<MatricesCombo>(entityName: "MatricesCombo")
        peticion.predicate = NSPredicate(format: "codigoMatriz != nil")
        cantidadMatrices = try! contexto.count(for: peticion)
        if cantidadMatrices == 0 {
            codigoMatrizCreada = 1
        } else {
            // Busco el nuevo código y me lo deja en codigoMatrizCreada
            codigoMatrizCreada = buscarCodigoMatrizCombo()
        }
        switch tipoPartida {
        case 1: numCasillasNueva = 60
        case 2: numCasillasNueva = 120
        case 3: numCasillasNueva = 270
        case 4: numCasillasNueva = 666
        case 5: numCasillasNueva = 666
        case 6: numCasillasNueva = 1001
        case 7: numCasillasNueva = 1666
        case 8: numCasillasNueva = 2001
        case 9: numCasillasNueva = 3333
        case 10: numCasillasNueva = 5005
        default:
            numCasillasNueva = 1666
        }
        // Creo la matrixPartidaOriginal -> Celdas
        matrixPartidaOriginal.removeAll()
        for _ in 1...numCasillasNueva {
            aleatorio = 1 + Int(arc4random_uniform(9))
            matrixPartidaOriginal.append(aleatorio)
        }
        // Creo la PRIMERA MatricesCombo: la Original
        let entidad = NSEntityDescription.entity(forEntityName: "MatricesCombo", in: contexto)!
        let matrizCreada = MatricesCombo(entity: entidad,insertInto: contexto)
        matrizCreada.codigoMatriz = codigoMatrizCreada
        // Ya tengo los valores de las Celdas de TODA la Partida en matrixPartidaOriginal
        // Creamos la Original: version = 0; jugador = ""; estado = 0
        matrizCreada.numCasillas = numCasillasNueva
        matrizCreada.version = 0
        matrizCreada.estado = 0
        matrizCreada.jugador = ""
 //       matrizCreada.celdasString = cambiarMatrizAString(matrizAString: matrixPartidaOriginal)
        matrizCreada.celdasStringInicial = cambiarMatrizAString(matrizAString: matrixPartidaOriginal)
        matrizCreada.celdasStringFinal = ""
        matrizCreada.pares = 0
        matrizCreada.puntos = 0
        matrizCreada.filasBlanco = 0
        matrizCreada.filasBlancoAntes = 0
        matrizCreada.mayorGrupo = 0
        matrizCreada.tipoPartida = tipoDePartida
        matrizCreada.modoJuego = modoDeJuego
        try! contexto.save()
        // También creamos la MatricesCombo del jugador
        // Creamos la Original: version = 0; jugador = jugador.seleccionado; estado = 0
        let matrizCreadaJ = MatricesCombo(entity: entidad,insertInto: contexto)
        matrizCreadaJ.codigoMatriz = codigoMatrizCreada
        // Ya tengo los valores de las Celdas de TODA la Partida en matrixPartidaOriginal
        // Creamos la Original: version = 0; jugador = ""; estado = 0
        matrizCreadaJ.numCasillas = numCasillasNueva
        matrizCreadaJ.version = 0
        matrizCreadaJ.estado = 0
        matrizCreadaJ.jugador = jugadorSeleccionado.idJugador
 //       matrizCreadaJ.celdasString = cambiarMatrizAString(matrizAString: matrixPartidaOriginal)
        matrizCreadaJ.celdasStringInicial = cambiarMatrizAString(matrizAString: matrixPartidaOriginal)
        matrizCreadaJ.celdasStringFinal = ""
        matrizCreadaJ.pares = 0
        matrizCreadaJ.puntos = 0
        matrizCreadaJ.filasBlanco = 0
        matrizCreadaJ.filasBlancoAntes = 0
        matrizCreadaJ.mayorGrupo = 0
        matrizCreadaJ.tipoPartida = tipoDePartida
        matrizCreadaJ.modoJuego = modoDeJuego
        try! contexto.save()
        // También creamos la MatricesCombo del Ordenador
        // Creamos la Original: version = 0; jugador = "Ordenador"; estado = 0
        let matrizCreadaO = MatricesCombo(entity: entidad,insertInto: contexto)
        matrizCreadaO.codigoMatriz = codigoMatrizCreada
        // Ya tengo los valores de las Celdas de TODA la Partida en matrixPartidaOriginal
        // Creamos la Original: version = 0; jugador = ""; estado = 0
        matrizCreadaO.numCasillas = numCasillasNueva
        matrizCreadaO.version = 0
        matrizCreadaO.estado = 0
        matrizCreadaO.jugador = "Ordenador"
 //       matrizCreadaO.celdasString = cambiarMatrizAString(matrizAString: matrixPartidaOriginal)
        matrizCreadaO.celdasStringInicial = cambiarMatrizAString(matrizAString: matrixPartidaOriginal)
        matrizCreadaO.celdasStringFinal = ""
        matrizCreadaO.pares = 0
        matrizCreadaO.puntos = 0
        matrizCreadaO.filasBlanco = 0
        matrizCreadaO.filasBlancoAntes = 0
        matrizCreadaO.mayorGrupo = 0
        matrizCreadaO.tipoPartida = tipoDePartida
        matrizCreadaO.modoJuego = modoDeJuego
        try! contexto.save()
        //       print("Desde ViewControler")
        //       pintarMatricesCombo()
        return codigoMatrizCreada
    }
    
    // Funciones de botones
    
    @IBAction func irAtras(_ sender: Any) {
        self.performSegue(withIdentifier: "volverVC", sender: numDePartidaJugada)
    }
    @IBAction func facilon1(_ sender: Any) {
        tipoDePartida = 1
        prepararJuego()
    }
    @IBAction func mimosin1(_ sender: Any) {
        tipoDePartida = 2
        prepararJuego()
    }
    @IBAction func regu1(_ sender: Any) {
        tipoDePartida = 3
        prepararJuego()
    }
    @IBAction func desafio1(_ sender: Any) {
        tipoDePartida = 4
        prepararJuego()
    }
    @IBAction func edu1(_ sender: Any) {
        tipoDePartida = 11
        prepararJuego()
    }    
    @IBAction func ikea1(_ sender: Any) {
        tipoDePartida = 5
        prepararJuego()
    }
    @IBAction func tormenta1(_ sender: Any) {
        tipoDePartida = 6
        prepararJuego()
    }
    @IBAction func borrasca1(_ sender: Any) {
        tipoDePartida = 7
        prepararJuego()
    }
    @IBAction func ciclon1(_ sender: Any) {
        tipoDePartida = 8
        prepararJuego()
    }
    @IBAction func huracan1(_ sender: Any) {
        tipoDePartida = 9
        prepararJuego()
    }
    @IBAction func tsunami1(_ sender: Any) {
        tipoDePartida = 10
        prepararJuego()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "irAJugar" {
            let objJugar: JugarViewController =  segue.destination as! JugarViewController
            objJugar.numCasillasOriginal = numCasillas
            objJugar.jugadorSeleccionado = jugadorSeleccionado
            objJugar.partidaComboSeleccionada = partidaComboSeleccionada
        } else if segue.identifier == "volverVC" {
            
        } else if segue.identifier == "estadisticasSegue" {
            let objEstadisticas: EstadisticasViewController =  segue.destination as! EstadisticasViewController
            objEstadisticas.jugadorSeleccionado = jugadorSeleccionado
        }
    }
    

    /*
    // MARK: - Navigation
     

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
