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
    // Variables
    var matrix: [Int] = [Int]()
    let imageData = [" ", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    var colorElegido: UIColor = UIColor()
    let color1 = UIColor(displayP3Red: 0.952, green: 0.882, blue: 0.878, alpha: 0.9)
    let color2 = UIColor(displayP3Red: 0.956, green: 0.925, blue: 0.741, alpha: 0.9)
    let color3 = UIColor(displayP3Red: 0.666, green: 0.949, blue: 0.654, alpha: 0.9)
    let color4 = UIColor(displayP3Red: 0.635, green: 0.858, blue: 0.937, alpha: 0.9)
    let color5 = UIColor(displayP3Red: 0.964, green: 0.725, blue: 0.917, alpha: 0.9)
    let color6 = UIColor(displayP3Red: 0.478, green: 0.988, blue: 0.988, alpha: 0.9)
    var jugadorSeleccionado: Jugadores!
    var partidaSeleccionada: PartidasCombo!
    var matrizSeleccionada: MatricesCombo!
    var codigoDePartidaSeleccionada: Int64 = 0
    var variasMatricesLista: [String] = [String]()
    // **********
    var variasPartidasCodigo: [Int32] = [0]
    var variasMatricesCodigo: [Int64] = [0]
    var variasMatricesListaCodigo: [Int64] = [0]
    var variasMatricesInicial: [String] = [String]()
    var variasPartidasTipo: [Int16] = [0]
    var tipoPartida: String = ""
    var tipoPartidaActual: Int16 = 0
    // **********
    var variasPartidaListaid: [Int32] = [0]
    var variasMatricesListaId: [Int64] = [0]
    
    var nombreJugadorEstadisticas: String?
    
    // Me pasan el jugador y busco todas las PartidasCombo en estado 2
    // A esas Partidas/Matrices Combo les leo la Matriz Incial y las Jugadas
    // Tanto al Jugador como al Ordenador
    
    override func viewDidLoad() {
        super.viewDidLoad()
        celdaCollectionView2.delegate = self
        celdaCollectionView2.dataSource = self
 //       jugador2.text = jugadorSeleccionado.idJugador!
        self.variasPartidas2.dataSource = self
        self.variasPartidas2.delegate = self
        jugador.text = jugadorSeleccionado.idJugador
        
        // Cargo las Partidas del Jugador en variasPartidasListaid
        let contexto = conexion()
        let string2 = String(2)
        let peticion = NSFetchRequest<PartidasCombo>(entityName: "PartidasCombo")        
        peticion.predicate = NSPredicate(format: "idJugador == %@ AND estado == %@", jugadorSeleccionado.idJugador!, string2)
        variasPartidasCodigo.removeAll()
        variasPartidasTipo.removeAll()
        variasMatricesCodigo.removeAll()
        variasMatricesListaCodigo.removeAll()
        variasMatricesInicial.removeAll()
        do {
            let resultados = try contexto.fetch(peticion)
            if resultados.count > 0 {
                for res in resultados as [NSManagedObject] {
                    variasPartidasCodigo.append(res.value(forKey: "codigoPartida") as! Int32)
                    variasPartidasTipo.append(res.value(forKey: "tipoPartida") as! Int16)
                    variasMatricesCodigo.append(res.value(forKey: "codigoMatriz") as! Int64)
                    let tipoNum = res.value(forKey: "tipoPartida") as! Int
                    switch tipoNum {
                    case 1: tipoPartida = "facilón"
                    case 2: tipoPartida = "mimosín"
                    case 3: tipoPartida = "regu"
                    case 4: tipoPartida = "desafío"
                    case 5: tipoPartida = "ikea"
                    case 6: tipoPartida = "tormenta"
                    case 7: tipoPartida = "borrasca"
                    case 8: tipoPartida = "ciclón"
                    case 9: tipoPartida = "huracán"
                    case 10: tipoPartida = "tsunami"
                    default:
                        tipoPartida = "edu"
                    }
                    let datosFechaPartida = res.value(forKey: "fechaInicio")
                    let formatoFecha = DateFormatter()
                    formatoFecha.dateStyle = .short
                    formatoFecha.timeStyle = .none
                    let textoPicker3 = formatoFecha.string(from: datosFechaPartida! as! Date)
                    let textoPicker1 = tipoPartida
                    let textoPicker2 = res.value(forKey: "codigoPartida")!
                    let textoPicker = "\(String(describing: textoPicker1)) - id: \(String(describing: textoPicker2)) - \(String(describing: textoPicker3))"
                    variasMatricesLista.append(textoPicker)
                    variasMatricesListaCodigo.append(res.value(forKey: "codigoMatriz") as! Int64)
                    variasMatricesInicial.append(res.value(forKey: "celdasInicial") as! String)
                }
            } else {
                // No hay Partidas de este Jugador -> Vuelvo atrás
                let numDePartidaJugada = 1
                self.performSegue(withIdentifier: "volverDeEstadisticas", sender: numDePartidaJugada)
            }
        } catch let error as NSError {
            print("No pude recuperar datos Jugador: \(String(describing: jugadorSeleccionado.idJugador)) error: \(error), \(error.userInfo)")
        }
 //       let contexto2 = conexion()
 //       let peticion2 = NSFetchRequest<MatricesCombo>(entityName: "MatricesCombo")
        
        codigoMatriz.text = "\(variasMatricesListaCodigo[0])"
        codigoMatrizActual = variasMatricesListaCodigo[0]
        tipoPartidaActual = variasPartidasTipo[0]
        matrixPartida = cambiarStringAMatriz(stringAMatriz: variasMatricesInicial[0])
        filasBorradasAntes = buscarFilasBlanco(matrizFilasBlanco: matrixPartida)
        matrixVersion = CrearMatrixVersion(matrizAVersionar: matrixPartida)
        crearMatrixVersionRevuelta()
        pintarMatrixPartida()
        leerCaminos()
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
        codigoMatriz.text = "\(variasMatricesListaCodigo[fila])"
        codigoMatrizActual = variasMatricesListaCodigo[fila]
        tipoPartidaActual = variasPartidasTipo[fila]
        matrixPartida = cambiarStringAMatriz(stringAMatriz: variasMatricesInicial[fila])
        filasBorradasAntes = buscarFilasBlanco(matrizFilasBlanco: matrixPartida)
        matrixVersion = CrearMatrixVersion(matrizAVersionar: matrixPartida)
        crearMatrixVersionRevuelta()
        pintarMatrixPartida()
        leerCaminos()
    }
    // ############################# Operaciones de lectura/escritura de CaminosOrdenador <--> caminoTotalOrdenador
    var jugadaInter: String = ""
    var jugadasString: [String] = [String]()
    var jugadaInterEnteros: [Int] = [Int]()
    var jugadasEnteros: [[Int]] = [[Int]]()
    var parCeldas: [Int] = [Int]()
    var numeroJugada: Int = 0
    var numeroPares: Int = 0
    var caminosTotalOrdenador: [[[Int]]] = [[[Int]]]()  // Conjunto de las JUGADAS (Conjunto de PARES Ordenados)
    var caminosJugador: [[[Int]]] = [[[Int]]]()
    var codigoMatrizActual: Int64 = 0
    var versionActual: Int16 = 0
    var matrixVersion: [Int] = [Int]()
    var matrixPartida: [Int] = [Int]()
    var matrixPartidaRevuelta: [Int] = [Int]()          // Tiene los índices que corresponden con matrixVersion/Color
    var matrixPartidaOriginal: [Int] = [Int]()          // Tiene los valores de TODAS LAS CELDAS ORIGINALES
    var matrixFilasBorradas: [Bool] = [Bool]()
    var filasBorradas: Int16 = 0
    var filasBorradasAntes: Int16 = 0
    var filasBorradasAntesOrd: Int16 = 0
    var filaATratar: Int16 = 0
    var filasEnBlanco1: Int = 0
    var filasEnBlanco2: Int = 0
    var puntosJugada: Int = 0
    var paresJugada: Int = 0
    var filasJugada: Int = 0
    var puntosN: Int = 0
    var cerosEnFila: Int = 0
    var grupoMayorJugada: Int = 0
    
    func leerCaminos() {
        if tipoPartidaActual < 5 {
            versionActual = 1
        } else {
            if tipoPartidaActual < 11 {
                versionActual = 4
            } else {
                versionActual = 10
            }
        }
        caminosTotalOrdenador = leerCaminosSolucion(codigoMatriz: Int16(codigoMatrizActual), jugador: "Ordenador", version: versionActual)
        caminosJugador = leerCaminosSolucion(codigoMatriz: Int16(codigoMatrizActual), jugador: jugadorSeleccionado.idJugador!, version: versionActual)
    }
    func puntosDelCamino(camino: [[[Int]]]) -> Int{
        paresJugada = 0
        puntosJugada = 0
        filasJugada = 0
        grupoMayorJugada = 0
        for grupos in camino {
            if grupos.count > grupoMayorJugada {
                grupoMayorJugada = grupos.count
            }
            paresJugada = paresJugada + grupos.count
            puntosJugada = puntosJugada + valorGrupo(n: grupos.count)
        }
        filasEnBlanco1 = Int(buscarFilasBlanco(matrizFilasBlanco: matrixPartida))
        puntosJugada = puntosJugada + filasEnBlanco1 * 4
        return puntosJugada
    }
    func valorGrupo(n: Int) -> Int{
        puntosN = 0
        for ii in 1...n {
            puntosN = puntosN + ii
        }
        return puntosN
    }
    // Funciones de Líneas a ceros
    // Rellena matrixFilasBorradas y devuelve el número de filasBorradas
    func buscarFilasBlanco (matrizFilasBlanco: [Int]) -> Int16 {
        let numFilasMatriz = (matrizFilasBlanco.count / 9) - 1
        filasBorradas = 0
        matrixFilasBorradas.removeAll()
        for i in 0...numFilasMatriz {
            cerosEnFila = 0
            for j in 0...8 {
                if (i * 9 + j) < matrizFilasBlanco.count {
                    if matrizFilasBlanco[i * 9 + j] == 0 {
                        cerosEnFila = cerosEnFila + 1
                    }
                }
            }
            if cerosEnFila == 9 {
                filasBorradas = filasBorradas + 1
                matrixFilasBorradas.append(true)
            } else {
                matrixFilasBorradas.append(false)
            }
        }
        // Por si el número de Celdas no es múltiplo de 9
        matrixFilasBorradas.append(false)
        return filasBorradas
    }
    func CrearMatrixVersion(matrizAVersionar: [Int]) -> [Int]{
        matrixVersion.removeAll()
        for i in 0...matrizAVersionar.count - 1 {
            filaATratar = Int16(i / 9)
            if matrixFilasBorradas[Int(filaATratar)] == false {
                matrixVersion.append(i)
            }
        }
        return matrixVersion
    }
    func crearMatrixVersionRevuelta() {
        matrixPartidaRevuelta.removeAll()
        for _ in 0...matrixPartida.count - 1 {
            matrixPartidaRevuelta.append(0)
        }
        for i in 0...matrixVersion.count - 1 {
            matrixPartidaRevuelta[matrixVersion[i]] = i
        }
    }
    
    func leerCaminosSolucion(codigoMatriz: Int16, jugador: String, version: Int16) -> [[[Int]]]{
        // Leo de CaminosSolucion y devuelvo caminosJugador
        // Borro el caminosJugador
        caminosJugador.removeAll()
        // Leo los CaminosJugador ordenados por numJugada
        let stringCodigoMatriz = String(codigoMatrizActual)
        let stringVersion = String(version)
        let contexto = conexion()
        let peticion = NSFetchRequest<CaminosSolucion>(entityName: "CaminosSolucion")
        let orderBymovimiento = NSSortDescriptor(key: "numJugada", ascending: true)
        peticion.sortDescriptors = [orderBymovimiento]
        peticion.predicate = NSPredicate(format: "codigoMatriz == %@ AND version == %@ AND jugador = %@", stringCodigoMatriz, stringVersion, jugador)
        let resultados = try! contexto.fetch(peticion)
        for res in resultados as [NSManagedObject] {
            jugadaInterEnteros.removeAll()
            jugadasEnteros.removeAll()
            let stringInter = res.value(forKey: "jugada") as! String
            jugadasString = stringInter.components(separatedBy: ",")
            for c in jugadasString {
                if c.count > 0 {
                    jugadaInterEnteros.append(Int(String(c))!)
                }
            }
            numeroPares = 0
            while numeroPares < jugadaInterEnteros.count {
                parCeldas.removeAll()
                parCeldas.append(jugadaInterEnteros[numeroPares])
                parCeldas.append(jugadaInterEnteros[numeroPares + 1])
                jugadasEnteros.append(parCeldas)
                numeroPares = numeroPares + 2
            }
            //            print("Convierto en enteros: \(jugadasEnteros)")
            caminosJugador.append(jugadasEnteros)
        }
        //         print("El CaminosSolucion: \(caminosSolucion)")
        return caminosJugador
    }
    
    // ############################# Operaciones de lectura/escritura de CaminosOrdenador <--> caminoTotalOrdenador
    
    func pintarMatrixPartida() {
        // Tenemos en matrixVersion los número de Celdas de matrixPartida
        // Ponemos en matrix los valores de matrixPartida según el índice de matrixVersion
        matrix.removeAll()
        for i in 0...matrixVersion.count - 1 {
            matrix.append(matrixPartida[matrixVersion[i]])
        }
        limpiarColores()
        self.celdaCollectionView2.reloadData()
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
    
    func buscarCaminosJugador() {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return matrix.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let celda = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! celdaCollectionViewCell
        celda.etiqueta2.text = imageData[matrix [indexPath.row]]
        celda.backgroundColor = matrixColor[indexPath.row]
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
    func collectionView(_ collectionView: UICollectionView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    // Proceso de pulsar celdas
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        avanzar(camino: caminosJugador, velocidad: 1)
    }

    // Funciones de la matriz de colores: matrixColor
    func limpiarColores() {
        matrixColor.removeAll()
        for _ in 0...matrix.count - 1 {
            matrixColor.append(UIColor.white)
        }
    }
    
    
    @IBOutlet weak var celdaCollectionView2: UICollectionView!
    @IBOutlet weak var variasPartidas2: UIPickerView!
    @IBOutlet weak var codigoMatriz: UILabel!
    
    @IBAction func volverAtras2(_ sender: Any) {
        let numDePartidaJugada = 1
        self.performSegue(withIdentifier: "volverDeEstadisticas", sender: numDePartidaJugada)
    }
    @IBOutlet weak var jugador: UILabel!
    @IBOutlet weak var ordenador: UILabel!
    @IBAction func avanceJugador(_ sender: Any) {
        avanzar(camino: caminosJugador, velocidad: 1)
    }
    @IBAction func rapidoJugador(_ sender: Any) {
        avanzar(camino: caminosJugador, velocidad: 1)
    }
    @IBAction func avanceOrdenador(_ sender: Any) {
        avanzar(camino: caminosTotalOrdenador, velocidad: 1)
    }
    @IBAction func rapidoOrdenador(_ sender: Any) {
        avanzar(camino: caminosTotalOrdenador, velocidad: 1)
    }
    func setUpCollectionView (collection : UICollectionView) {
        collection.delegate = self
        collection.dataSource = self
    }
    func avanzar(camino: [[[Int]]], velocidad: Int) {
        for grupos in camino {
            for parejas in grupos {         // Pulsamos de una en una las celdas de las parejas, cambiando color
                let valorPrimera = matrix [matrixPartidaRevuelta[parejas[0]]]      // Guardo el VALOR de la Celda primera del grupo
                // Ojo, quizá hay que tener cuidado con los índices relativos
                // Elegimos el color de las celdas marcadas según el valor
                switch valorPrimera {
                case 1: colorElegido = color1
                case 2: colorElegido = color2
                case 3: colorElegido = color3
                case 4: colorElegido = color4
                case 5: colorElegido = color5
                case 6: colorElegido = color4
                case 7: colorElegido = color3
                case 8: colorElegido = color2
                case 9: colorElegido = color1
                //            default: colorElegido = color6
                default: colorElegido = UIColor.white
                }
                // Al ser la primera la ponemos en color pendiente
                let celdaVersion_1 = matrixPartidaRevuelta[parejas[0]]
                let celdaVersion_2 = matrixPartidaRevuelta[parejas[1]]
                indexCelda1 = IndexPath(row: celdaVersion_1, section: 0)
                indexCelda2 = IndexPath(row: celdaVersion_2, section: 0)
 //               self.celdaCollectionView2.deleteItems(at: [indexCelda1])
                let celda1 = celdaCollectionView2.cellForItem(at: indexCelda1)
                let celda2 = celdaCollectionView2.cellForItem(at: indexCelda2)
  //              let celda1 = celdaCollectionView2.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexCelda1) as! celdaCollectionViewCell
  //              let celda2 = celdaCollectionView2.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexCelda1) as! celdaCollectionViewCell
                /*
                 let celda = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! celdaCollectionViewCell
                 celda.etiqueta2.text = imageData[matrix [indexPath.row]]
                 celda.backgroundColor = matrixColor[indexPath.row]
                 celda.layer.cornerRadius = 10
                 */
       //         let celda1 = celdaCollectionView2.cellForItem(at: indexCelda1) as! celdaCollectionViewCell
      //          let celda2 = celdaCollectionView2.cellForItem(at: indexCelda2) as! celdaCollectionViewCell
                celda1?.backgroundColor = color6
                matrixColor[Int(celdaVersion_1)] = color6
     //           setUpCollectionView(collection: celdaCollectionView2)
     //           self.celdaCollectionView2.deleteItems(at: [indexCelda1])
     //           self.celdaCollectionView2.insertItems(at: [indexCelda1])
                self.celdaCollectionView2.reloadData()
                if velocidad == 1 {
                    sleep(1)
                } else {
                    // distintas velocidades
                }
                celda1?.backgroundColor = colorElegido
                celda2?.backgroundColor = colorElegido
                matrixColor[Int(celdaVersion_1)] = colorElegido
                matrixColor[Int(celdaVersion_2)] = colorElegido
    //            setUpCollectionView(collection: celdaCollectionView2)
                self.celdaCollectionView2.reloadData()
                if velocidad == 1 {
                    sleep(1)
                } else {
                    
                }
                
            }
            anotarJugada(grupo: grupos)
        }
    }
    func anotarJugada(grupo: [[Int]]) {
        // A la vez vamos poniendo a 0 las Celdas de matrixPartida
        // Hay que tener en cuenta que el índice a 0 de matrixPartida
        // es el contenido de la Celda de matrixVersion con índice igual que matrix
        filasEnBlanco1 = Int(buscarFilasBlanco(matrizFilasBlanco: matrixPartida))
        for i in 0 ... grupo.count - 1 {
            let celdaVersion_0 = matrixPartidaRevuelta[grupo[i][0]]
            let celdaVersion_1 = matrixPartidaRevuelta[grupo[i][1]]
            //         let celdaVersion_0 = grupo[i][0] - Int((filasJugador * 9))
            //         let celdaVersion_1 = grupo[i][1] - Int((filasJugador * 9))
            matrixPartida[matrixVersion[celdaVersion_0]] = 0
            matrixPartida[matrixVersion[celdaVersion_1]] = 0
        }
        paresGrupo = grupo.count
        if grupoMayorVersion < paresGrupo {
            grupoMayorVersion = Int16(paresGrupo)
        }
        paresVersion = paresVersion + Int32(paresGrupo)
        puntosGrupo = valorGrupo(n: paresGrupo)
        filasEnBlanco2 = Int(buscarFilasBlanco(matrizFilasBlanco: matrixPartida))
        filasJugador = filasJugador + Int64(filasEnBlanco2 - filasEnBlanco1)
        let puntosFilaBlanco = 4 * (filasEnBlanco2 - filasEnBlanco1)
        puntosVersion = puntosVersion + Int32(puntosGrupo + (puntosFilaBlanco))
        puntosJugador = puntosJugador + Int64(puntosGrupo + (puntosFilaBlanco))
        if mayorGrupoJugador < grupoMayorVersion {
            mayorGrupoJugador = grupoMayorVersion
        }
        //        tuPuntuacion2.text = "\(puntosJugador)"
        //        numPulsaciones = 0
        //        puntosParcial.text = "0"
        // Ahora, partiendo de la nueva matrixPartida
        // tengo que generar matrixVersion y matrix
        // Vamos a transformar matrixPartida a matrix
        // Primero buscamos las filasBlanco (Ya lo tengo por filasEnBlanco1/2)
        //          filasBorradasAntes = buscarFilasBlanco(matrizFilasBlanco: matrixPartida)
        // Después creamos la matrixVersion quitando las filas en blanco
        // y desplazando las celdas/filas
        matrixVersion = CrearMatrixVersion(matrizAVersionar: matrixPartida)
        crearMatrixVersionRevuelta()
        // Ahora puedo generar matrix
        pintarMatrixPartida()
 //       setUpCollectionView(collection: celdaCollectionView2)
        self.celdaCollectionView2.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "volverDeEstadisticas" {
            
        }
    }
    var matrixColor: [UIColor] = [UIColor]()
    var matrixVisibilidad: [Bool] = [Bool]()
    var grupoJugadasInter: [[Int]] = [[Int]]()
    var grupoJugadasInter2: [[Int]] = [[Int]]()
    var paresGrupo: Int = 0
    var puntosGrupo: Int = 0
    var puntosVersion: Int32 = 0
    var paresVersion: Int32 = 0
    var filasVersion: Int16 = 0
    var grupoMayorVersion: Int16 = 0
    var puntosJugador: Int64 = 0
    var paresJugador: Int64 = 0
    var filasJugador: Int64 = 0
    var mayorGrupoJugador: Int16 = 0
    var indexCelda1: IndexPath = IndexPath()
    var indexCelda2: IndexPath = IndexPath()

}
