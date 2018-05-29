//
//  JugarViewController.swift
//  MatrixCombo
//
//  Created by Edu Ardo on 12/3/18.
//  Copyright © 2018 neteamador. All rights reserved.
//

// ************************************* Versión con Cálculo de Ordenador Nivel1 **********************************
import UIKit
import CoreData

class JugarViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {

    // Variables de inicio y de CoreData
    let imageData = [" ", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    var colorElegido: UIColor = UIColor()
    let color1 = UIColor(displayP3Red: 0.952, green: 0.882, blue: 0.878, alpha: 0.9)
    let color2 = UIColor(displayP3Red: 0.956, green: 0.925, blue: 0.741, alpha: 0.9)
    let color3 = UIColor(displayP3Red: 0.666, green: 0.949, blue: 0.654, alpha: 0.9)
    let color4 = UIColor(displayP3Red: 0.635, green: 0.858, blue: 0.937, alpha: 0.9)
    let color5 = UIColor(displayP3Red: 0.964, green: 0.725, blue: 0.917, alpha: 0.9)
    let color6 = UIColor(displayP3Red: 0.478, green: 0.988, blue: 0.988, alpha: 0.9)
    var partidaComboSeleccionada: PartidasCombo!
    var jugadorSeleccionado: Jugadores!
    var matrizCreada: Matrices!
    var celdaCreada: Celdas!
    var logPartidaMatriz: LogMatriz!
//    var partidaCreada: Partidas!
    var codigoMatrizUsada: Int32 = 0
    var idMatrizUsada: Int32 = 0
    var puntosAntes: Int64 = 0
    
    // Variable y función de CoreData
    var contexto: NSManagedObjectContext!
    func conexion() -> NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    // ***************************** Versión con Cambio a MatrizCombo y PartidasCombo *********************
    
    // Cambio a MatrizCombo y PartidasCombo
    var matrixPartidaOriginal: [Int] = [Int]()          // Tiene los valores de TODAS LAS CELDAS ORIGINALES
    var matrixPartida: [Int] = [Int]()
    var matrixVersion: [Int] = [Int]()
    var matrixFilasBorradas: [Bool] = [Bool]()
    var filasBorradas: Int16 = 0
    var filasBorradasAntes: Int16 = 0
    var filasBorradasAntesOrd: Int16 = 0
    var filaATratar: Int16 = 0
    var matrixComboJugada: [Int] = [Int]()    
    var numCasillasJugada: Int = 0
    var matrixComboSeleccionada: MatricesCombo!
    var matrixComboAGuardar: MatricesCombo!
    var matrixComboInter: MatricesCombo!
    var vueltas: Int = 0
    var desdeCelda: Int16 = 0
    var hastaCelda: Int16 = 0
    var caminosJugador: [[[Int]]] = [[[Int]]]()         // El total
    var caminosJugadorVersion: [[[Int]]] = [[[Int]]]()
    var tiposDePartida: [[Int16]] = [[Int16]]()
    var filasEnBlanco1: Int = 0
    var filasEnBlanco2: Int = 0
    var codigoMatrizActual: Int32 = 0
    var puntosJugada: Int = 0
    var paresJugada: Int = 0
    var filasJugada: Int = 0
    var grupoMayorJugada: Int = 0
    var puntosVersion: Int32 = 0
    var paresVersion: Int32 = 0
    var filasVersion: Int16 = 0
    var grupoMayorVersion: Int16 = 0
    var puntosVersionOrd: Int64 = 0
    var paresVersionOrd: Int64 = 0
    var filasVersionOrd: Int16 = 0
    var grupoMayorVersionOrd: Int16 = 0
    var puntosN: Int = 0
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
    
    func pintarMatrixPartida() {
        // Tenemos en matrixVersion los número de Celdas de matrixPartida
        // Ponemos en matrix los valores de matrixPartida según el índice de matrixVersion
        matrix.removeAll()
        for i in 0...matrixVersion.count - 1 {
            matrix.append(matrixPartida[matrixVersion[i]])
        }
        limpiarColores()
        self.matrixCollectionView2.reloadData()
    }
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
    func buscarMatrixPartidasOriginal(codigoMatriz: Int32) -> [Int]{
        let contexto = conexion()
        let peticion = NSFetchRequest<MatricesCombo>(entityName: "MatricesCombo")
        let orderByCodigoMatriz = NSSortDescriptor(key: "codigoMatriz", ascending: false)
        peticion.sortDescriptors = [orderByCodigoMatriz]
        peticion.fetchLimit = 1
        let stringCodigoMatriz = String(partidaComboSeleccionada.codigoMatriz)
        let stringVersion = String(0)   // Seleccionamos la Original
        let stringEstado = String(0)        // Seleccionamos la Original
        let stringJugador = ""
        peticion.predicate = NSPredicate(format: "codigoMatriz == %@ AND version == %@ AND estado == %@ AND jugador == %@", stringCodigoMatriz, stringVersion, stringEstado, stringJugador)
        let resultados = try! contexto.fetch(peticion)
        if resultados.count == 0 {
            print("Error al leer MatricesCombo: codigo: \(stringCodigoMatriz) version: \(stringVersion) y estado: \(stringEstado)")
        }
        matrixPartidaOriginal = cambiarStringAMatriz(stringAMatriz: resultados[0].celdasStringInicial!)
        return matrixPartidaOriginal
    }
    func pintarMatricesCombo() {
        let contexto = conexion()
        let peticion = NSFetchRequest<MatricesCombo>(entityName: "MatricesCombo")
        let orderByCodigoMatriz = NSSortDescriptor(key: "codigoMatriz", ascending: false)
        peticion.sortDescriptors = [orderByCodigoMatriz]
        let resultados = try! contexto.fetch(peticion)
        for res in resultados {
            print(res)
        }
        if resultados.count == 0 {
            print("Error al leer MatricesCombo:")
        }
    }
    func crearMatricesComboPartida (codigoMatriz: Int32, jugador: String, version: Int16) -> [Int]{
        // Vamos a calcular la nueva matrixJugada con las Celdas según tipoPartida
        // Primero el número de Celdas según tipoPartida
        let tipoJ = partidaComboSeleccionada.tipoPartida
        if tipoJ < 5 {
            for i in 0...matrixPartidaOriginal.count - 1 {
                matrixPartida.append(matrixPartidaOriginal[i])
            }
        } else {
            if tipoJ == 5 {
                desdeCelda = Int16(matrixPartida.count)
                if version < 4 {
                    hastaCelda = desdeCelda + (66 * version)
                } else {
                    hastaCelda = 666
                }
                for i in desdeCelda...hastaCelda - 1 {
                    matrixPartida.append(matrixPartidaOriginal[Int(i)])
                }
            } else {
                if tipoJ == 6 {
                    desdeCelda = Int16(matrixPartida.count)
                    if version < 4 {
                        hastaCelda = desdeCelda + (100 * version)
                    } else {
                        hastaCelda = 1001
                    }
                    for i in desdeCelda...hastaCelda - 1 {
                        matrixPartida.append(matrixPartidaOriginal[Int(i)])
                    }
                } else {
                    if tipoJ == 7 {
                        desdeCelda = Int16(matrixPartida.count)
                        if version < 4 {
                            hastaCelda = desdeCelda + (166 * version)
                        } else {
                            hastaCelda = 1666
                        }
                        for i in desdeCelda...hastaCelda - 1 {
                            matrixPartida.append(matrixPartidaOriginal[Int(i)])
                        }
                    } else {
                        if tipoJ == 8 {
                            desdeCelda = Int16(matrixPartida.count)
                            if version < 4 {
                                hastaCelda = desdeCelda + (200 * version)
                            } else {
                                hastaCelda = 2001
                            }
                            for i in desdeCelda...hastaCelda - 1 {
                                matrixPartida.append(matrixPartidaOriginal[Int(i)])
                            }
                        } else {
                            if tipoJ == 9 {
                                desdeCelda = Int16(matrixPartida.count)
                                if version < 4 {
                                    hastaCelda = desdeCelda + (333 * version)
                                } else {
                                    hastaCelda = 3333
                                }
                                for i in desdeCelda...hastaCelda - 1 {
                                    matrixPartida.append(matrixPartidaOriginal[Int(i)])
                                }
                            } else {
                                if tipoJ == 10 {
                                    desdeCelda = Int16(matrixPartida.count)
                                    if version < 4 {
                                        hastaCelda = desdeCelda + (500 * version)
                                    } else {
                                        hastaCelda = 5005
                                    }
                                    for i in desdeCelda...hastaCelda - 1 {
                                        matrixPartida.append(matrixPartidaOriginal[Int(i)])
                                    }
                                } else {
                                    if tipoJ == 11 {
                                        desdeCelda = Int16(matrixPartida.count)
                                        if version < 11 {
                                            hastaCelda = desdeCelda + (30 * version)
                                        } else {
                                            hastaCelda = 5005
                                        }
                                        for i in desdeCelda...hastaCelda - 1 {
                                            matrixPartida.append(matrixPartidaOriginal[Int(i)])
                                        }
                                    } else {
                                        print("error en tipoJuego: \(tipoJ)")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        // Creo las CUATRO MatricesCombo: para guardar la original y la que se juega
        // Creo las DOS MatricesCombo: para guardar la del jugador y la del Ordenador
        // Cambio MatricesCombo para que tengan la Matriz Inicial y la Matriz Final/en Juego
        
        let contexto = conexion()
        let entidad = NSEntityDescription.entity(forEntityName: "MatricesCombo", in: contexto)!
        let matrizComboPartida = MatricesCombo(entity: entidad,insertInto: contexto)
        matrizComboPartida.codigoMatriz = codigoMatriz
        matrizComboPartida.jugador = jugador
        matrizComboPartida.version = version
        matrizComboPartida.estado = 0          // Original de la versión actual
 //       matrizComboPartida.celdasString = cambiarMatrizAString(matrizAString: matrixPartida)
        matrizComboPartida.celdasStringInicial = cambiarMatrizAString(matrizAString: matrixPartida)
        matrizComboPartida.celdasStringFinal = ""
        matrizComboPartida.caminoVersion = ""
        matrizComboPartida.pares = 0
        matrizComboPartida.puntos = 0
        matrizComboPartida.filasBlanco = 0
        matrizComboPartida.mayorGrupo = 0
        matrizComboPartida.filasBlancoAntes = buscarFilasBlanco(matrizFilasBlanco: matrixPartida)
        // Habría que inicializar (si sirve de algo en MatricesCombo) los tipo de juego y partida
  // NO CREO la matrixCombo.estado = 0      try! contexto.save()
        let matrizComboPartida1 = MatricesCombo(entity: entidad,insertInto: contexto)
        matrizComboPartida1.codigoMatriz = codigoMatriz
        matrizComboPartida1.jugador = jugador
        matrizComboPartida1.version = version
        matrizComboPartida1.estado = 1          // En juego la versión actual
 //       matrizComboPartida1.celdasString = cambiarMatrizAString(matrizAString: matrixPartida)
        matrizComboPartida1.celdasStringInicial = cambiarMatrizAString(matrizAString: matrixPartida)
        matrizComboPartida1.celdasStringFinal = ""
        matrizComboPartida1.caminoVersion = ""
        matrizComboPartida1.pares = 0
        matrizComboPartida1.puntos = 0
        matrizComboPartida1.filasBlanco = 0
        matrizComboPartida1.mayorGrupo = 0
        matrizComboPartida1.filasBlancoAntes = buscarFilasBlanco(matrizFilasBlanco: matrixPartida)
        // Habría que inicializar (si sirve de algo en MatricesCombo) los tipo de juego y partida
        try! contexto.save()
        let matrizComboPartida2 = MatricesCombo(entity: entidad,insertInto: contexto)
        matrizComboPartida2.codigoMatriz = codigoMatriz
        matrizComboPartida2.jugador = "Ordenador"
        matrizComboPartida2.version = version
        matrizComboPartida2.estado = 0          // Original de la versión actual
 //       matrizComboPartida2.celdasString = cambiarMatrizAString(matrizAString: matrixPartida)
        matrizComboPartida2.celdasStringInicial = cambiarMatrizAString(matrizAString: matrixPartida)
        matrizComboPartida2.celdasStringFinal = ""
        matrizComboPartida2.caminoVersion = ""
        matrizComboPartida2.pares = 0
        matrizComboPartida2.puntos = 0
        matrizComboPartida2.filasBlanco = 0
        matrizComboPartida2.mayorGrupo = 0
        matrizComboPartida2.filasBlancoAntes = buscarFilasBlanco(matrizFilasBlanco: matrixPartida)
        // Habría que inicializar (si sirve de algo en MatricesCombo) los tipo de juego y partida
 // NO CREO la matrixCombo.estado = 0       try! contexto.save()
        let matrizComboPartida12 = MatricesCombo(entity: entidad,insertInto: contexto)
        matrizComboPartida12.codigoMatriz = codigoMatriz
        matrizComboPartida12.jugador = "Ordenador"
        matrizComboPartida12.version = version
        matrizComboPartida12.estado = 1          // En juego la versión actual
  //      matrizComboPartida12.celdasString = cambiarMatrizAString(matrizAString: matrixPartida)
        matrizComboPartida12.celdasStringInicial = cambiarMatrizAString(matrizAString: matrixPartida)
        matrizComboPartida12.celdasStringFinal = ""
        matrizComboPartida12.caminoVersion = ""
        matrizComboPartida12.pares = 0
        matrizComboPartida12.puntos = 0
        matrizComboPartida12.filasBlanco = 0
        matrizComboPartida12.mayorGrupo = 0
        matrizComboPartida12.filasBlancoAntes = buscarFilasBlanco(matrizFilasBlanco: matrixPartida)
        // Habría que inicializar (si sirve de algo en MatricesCombo) los tipo de juego y partida
        try! contexto.save()
        
//        print("Desde Jugar")
//        pintarMatricesCombo()
        
        // Ya tenemos en matrixPartida la matriz a jugar
        // Inicializamos contadores de version
        puntosVersion = 0
        paresVersion = 0
        filasVersion = 0
        grupoMayorVersion = 0
        return matrixPartida
    }
    
    func guardarMatrizComboVersion(matrizGuardar: [Int], jugador: String, version: Int16, estado: Int16, pares: Int32, puntos: Int32, filas: Int16, mayor: Int16, camino:[[[Int]]]) {
        // Aquí vamos a actualizar la MatricesCombo con la versión correspondiente
        // Si el estado = 2 se finaliza la matrizCombo (esto lo controla quien llama a la función
        let contexto = conexion()
        let peticion = NSFetchRequest<MatricesCombo>(entityName: "MatricesCombo")
        let stringIdPartida = String(codigoMatrizActual)
        let stringVersion = String(version)
        let stringEstado = String(1)        // Leemos la matriz con estado = 1
        peticion.predicate = NSPredicate(format: "codigoMatriz == %@ AND version == %@ AND jugador == %@ AND estado == %@", stringIdPartida, stringVersion, jugador, stringEstado)
        let matrizSel = try! contexto.fetch(peticion)
        matrixComboSeleccionada = matrizSel[0]
 //       matrixComboSeleccionada.celdasString = cambiarMatrizAString(matrizAString: matrizGuardar)
        matrixComboSeleccionada.celdasStringFinal = cambiarMatrizAString(matrizAString: matrizGuardar)
        matrixComboSeleccionada.caminoVersion = cambiarCaminosAString(caminos: camino)
        matrixComboSeleccionada.estado = estado
        matrixComboSeleccionada.pares = pares
        matrixComboSeleccionada.puntos = puntos
        matrixComboSeleccionada.filasBlanco = filas
        matrixComboSeleccionada.mayorGrupo = mayor
        do {
            try contexto.save()
        } catch let error as NSError {
            print("no puedo actualizar la MatricesCombo: \(codigoMatrizActual) version: \(version) estado: \(estado)", error)
        }
    }
    func grupoMayorCamino(camino: [[[Int]]]) -> Int {
        grupoMayorJugada = 0
        for grupos in camino {
            if grupos.count > grupoMayorJugada {
                grupoMayorJugada = grupos.count
            }
        }
        return grupoMayorJugada
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
  //          puntosJugada = puntosJugada + grupos.count + (grupos.count - 1) * 2
            puntosJugada = puntosJugada + valorGrupo(n: grupos.count)
        }
        filasEnBlanco1 = Int(buscarFilasBlanco(matrizFilasBlanco: matrixPartida))
        puntosJugada = puntosJugada + filasEnBlanco1 * 4
        return puntosJugada
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
    
    func leerCaminosSolucion(codigoMatriz: Int16, jugador: String, version: Int16) -> [[[Int]]]{
        // Leo de CaminosSolucion y devuelvo caminosJugador
        // Borro el caminosJugador
        caminosJugador.removeAll()
        // Leo los CaminosJugador ordenados por numJugada
        let stringCodigoMatriz = String(codigoMatriz)
        let stringVersion = String(version)
        let contexto = conexion()
        let peticion = NSFetchRequest<CaminosSolucion>(entityName: "CaminosSolucion")
        let orderBymovimiento = NSSortDescriptor(key: "numJugada", ascending: true)
        peticion.sortDescriptors = [orderBymovimiento]
        peticion.predicate = NSPredicate(format: "codigoMatriz == %@ AND version == %@", stringCodigoMatriz, stringVersion)
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
    func guardarCaminosSolucion(codigoMatriz: Int16, version: Int16, caminos: [[[Int]]], jugador: String) {
        // Recibo caminosJugador y grabo en CaminosSolucion
        // OJO debo intentar no sobreescribir lo que ya está grabado
        // var: numGruposCaminoYaGuardadosVersion
        // Cuando lee al principio de una ya empezada es el count de caminosSolucion
        if caminos.count > 0 {
            // Primero borro el CaminosSolucion de ese codigoMatriz, version versionActual y estado = 1
            let contexto = conexion()
            let peticion = NSFetchRequest<CaminosSolucion>(entityName: "CaminosSolucion")
            let stringcodigoMatriz = String(codigoMatriz)
            let stringVersion = String(version)
            peticion.predicate = NSPredicate(format: "codigoMatriz == %@ AND version == %@ AND jugador == %@", stringcodigoMatriz, stringVersion, jugador)
            do {
                let resultados = try! contexto.fetch(peticion)
                if resultados.count > 0 {
                    for i in resultados {
                        contexto.delete(i)
                        try! contexto.save()
                    }
                }
            }
            jugadasString.removeAll()
            for jugadasOrden in caminos {
                jugadaInter = ""
                for paresOrden in jugadasOrden {
                    jugadaInter = jugadaInter + String(describing: paresOrden[0]) + ","
                    jugadaInter = jugadaInter + String(describing: paresOrden[1]) + ","
                }
                jugadasString.append(jugadaInter)
            }
            // Ahora Creo CaminosSolucion a partir de caminosTotalOrdenador / caminosAGuardar
            let contexto2 = conexion()
            let entidad2 = NSEntityDescription.entity(forEntityName: "CaminosSolucion", in: contexto2)!
            numeroJugada = 0
            for jugadaActual in jugadasString {
                numeroJugada = numeroJugada + 1
                let jugada = CaminosSolucion(entity: entidad2, insertInto: contexto2)
                jugada.codigoMatriz = Int32(codigoMatriz)
                jugada.version = version
                jugada.jugada = jugadaActual
                jugada.jugador = jugador
                jugada.numJugada = Int16(numeroJugada)
                jugada.jugada = jugadaActual
                try! contexto2.save()
            }
        }
        
    }
    
    
    // Funciones del sistema
    override func viewDidLoad() {
        super.viewDidLoad()
        matrixCollectionView2.delegate = self
        matrixCollectionView2.dataSource = self
        // Me pasan"partidaComboSeleccionada", compruebo si es una Partida nueva
        // y hay que inicializar el idmatriz
        if partidaComboSeleccionada.version == 0 {
            // Es nueva voy a crearMatricesComboPartida con version = 1            
            // Creamos la versión 1: vamos a la función crearMatricesComboPartida
            codigoMatrizActual = partidaComboSeleccionada.codigoMatriz
            versionActual = 1
            matrixPartidaOriginal = buscarMatrixPartidasOriginal(codigoMatriz: codigoMatrizActual)
            // Creamos la versiones 1 de Ordenador y jugador
            matrixPartida.removeAll()
            matrixPartida = crearMatricesComboPartida(codigoMatriz: codigoMatrizActual, jugador: partidaComboSeleccionada.idJugador!, version: 1)
            // Calculo el Ordenador de la version = 1 y actualizo contadores
            soloPrueba = false
            caminosTotalOrdenador.removeAll()
            valorParCompleto = calculoOrdenadorGrupos(matrixOrdCalculo: matrixPartida, version: 1)
            /*
             Ya tenemos actualizado los contadores del Ordenador y partidaComboSeleccionada
             puntosOrdenador = puntosOrdenador + Int64(puntosVersionOrd)
             paresOrdenador = paresOrdenador + Int64(paresVersionOrd)
             filasOrdenador = filasOrdenador + Int64(filasVersionOrd)
             // el grupoMayorVersionOrd está ya cargado
             //                   puntosOrdenador = puntosOrdenador + valorParCompleto
             */
            ordPuntuacion12.text = "\(puntosOrdenador)"
            // Hemos creado la Version 1 del Jugador una con estado 0 y otra estado 1 que jugamos
            // Vamos a transformar matrixPartida a matrix
            // Primero buscamos las filasBlanco
            // Es la primera vez NO
    //        filasBorradasAntes = buscarFilasBlanco(matrizFilasBlanco: matrixPartida)
            // Después creamos la matrixVersion quitando las filas en blanco
            // y desplazando las celdas/filas
            matrixVersion = CrearMatrixVersion(matrizAVersionar: matrixPartida)
            // Ahora puedo generar matrix
            pintarMatrixPartida()
            
            // Ahora ya tengo en matrixComboJugada la matrix a jugar

            filasBorradasAntes = 0    // Es la primera vez
            caminosJugador.removeAll()
        } else {
            // Leo la Matriz correspondiente con estado = 1
            // También tengo que leer la MatricesCombo con versión 0
            // para tener la matrixPartidaOriginal
            // Actualizo la versionActual
            versionActual = partidaComboSeleccionada.version
            matrixPartidaOriginal = buscarMatrixPartidasOriginal(codigoMatriz: partidaComboSeleccionada.codigoMatriz)
            let contexto = conexion()
            let peticion = NSFetchRequest<MatricesCombo>(entityName: "MatricesCombo")
            let orderByCodigoMatriz = NSSortDescriptor(key: "codigoMatriz", ascending: false)
            peticion.sortDescriptors = [orderByCodigoMatriz]
            peticion.fetchLimit = 1
            let stringCodigoMatriz = String(partidaComboSeleccionada.codigoMatriz)
            let stringVersion = String(partidaComboSeleccionada.version)
            let stringEstado = String(1)
            peticion.predicate = NSPredicate(format: "codigoMatriz == %@ AND version == %@ AND estado == %@ AND jugador == %@", stringCodigoMatriz, stringVersion, stringEstado, partidaComboSeleccionada.idJugador!)
            let resultados = try! contexto.fetch(peticion)
            if resultados.count == 0 {
                print("Error al leer MatricesCombo: codigo: \(stringCodigoMatriz) version: \(stringVersion) y estado: \(stringEstado) jugador: \(partidaComboSeleccionada.idJugador!)")
            }
            // Ahora tengo que descifrar celdasString --> matrizPartida
            matrixPartida = cambiarStringAMatriz(stringAMatriz: resultados[0].celdasStringFinal!)
            // Después vamos a transformar matrixPartida a matrix
            // Primero leemos las filasBlanco de la matrixVersion (sí! está guardada ya)
            filasBorradasAntes = resultados[0].filasBlancoAntes
            // hacemos esto para cargar las filasEnBlanco
            filasEnBlanco1 = Int(buscarFilasBlanco(matrizFilasBlanco: matrixPartida))
            // Después creamos la matrixVersion quitando las filas en blanco
            // y desplazando las celdas/filas
            matrixVersion = CrearMatrixVersion(matrizAVersionar: matrixPartida)
            // Ahora puedo generar matrix
            pintarMatrixPartida()
            // Leo los contadores
            puntosVersion = resultados[0].puntos
            paresVersion = resultados[0].pares
            grupoMayorVersion = resultados[0].mayorGrupo
            filasVersion = resultados[0].filasBlanco
            // Debemos cargar el log que en este caso está en CaminosSolucion
            // Leo de CaminosSolucion y devuelvo caminosJugador
            codigoMatrizActual = partidaComboSeleccionada.codigoMatriz
            caminosJugador = cambiarStringACaminos(caminoString: partidaComboSeleccionada.caminoFinalJugador!)
            caminosTotalOrdenador = cambiarStringACaminos(caminoString: partidaComboSeleccionada.caminoFinalOrdenador!)
  //          caminosJugador = leerCaminosSolucion(codigoMatriz: Int16(codigoMatrizActual), jugador: partidaComboSeleccionada.idJugador!, version: partidaComboSeleccionada.version)
  //          caminosTotalOrdenador = leerCaminosSolucion(codigoMatriz: Int16(codigoMatrizActual), jugador: "Ordenador", version: partidaComboSeleccionada.version)
        }
        // Inicializo
        numCasillasOriginal = Int(partidaComboSeleccionada.numCasillasOriginal)
        puntosJugador = partidaComboSeleccionada.puntosJugador
        paresJugador = partidaComboSeleccionada.paresJugador
        filasJugador = Int64(partidaComboSeleccionada.filasBlancoJugador)
        grupoMayorVersion = partidaComboSeleccionada.mayorGrupoJugador
        puntosOrdenador = partidaComboSeleccionada.puntosOrdenador
        paresOrdenador = partidaComboSeleccionada.paresOrdenador
        filasOrdenador = Int64(partidaComboSeleccionada.filasBlancoOrdenador)
        mayorGrupoOrd = partidaComboSeleccionada.mayorGrupoOrdenador
        puntosTotalJugador = jugadorSeleccionado.puntosTotal - partidaComboSeleccionada.puntosJugador
        paresTotalJugador = jugadorSeleccionado.paresTotal - partidaComboSeleccionada.paresJugador
        filasTotalJugador = jugadorSeleccionado.filasTotal - Int64(partidaComboSeleccionada.filasBlancoJugador)
        tuPuntuacion2.text = "\(puntosJugador)"
        ordPuntuacion12.text = "\(puntosOrdenador)"
        // A jugar
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //        guardarMatrizCombo(version: versionActual, estado: 1)
        //        guardarCeldasString()
        //        guardarPartida(estado: 1)
        //        guardarJugador()
        //        guardarLogMatriz()
        //        guardarLogGrupos()
        //        guardarLogFilasBorradas()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        //        guardarMatrizCombo(version: versionActual, estado: 1)
        //        guardarCeldasString()
        //        guardarPartida(estado: 1)
        //        guardarJugador()
        //        guardarLogMatriz()
        //        guardarLogGrupos()
        //        guardarLogFilasBorradas(
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
    func cambiarCaminosAString(caminos: [[[Int]]]) -> String {
        // Recibo caminosJugador y grabo en CaminosSolucion
        // Separo los Grupos del Camino con "*"
        caminoString = ""
        for grupos in caminos {
            for paresOrden in grupos {
                caminoString = caminoString + String(describing: paresOrden[0]) + ","
                caminoString = caminoString + String(describing: paresOrden[1]) + ","
            }
            caminoString = caminoString + "*,"
        }
        // Debería borrar los dos últimos caracteres: "*,"
        // Ya tengo en caminoString el camino Solución
        // -> para PartidasCombo y MatricesCombo
        return caminoString
    }
    func cambiarStringACaminos(caminoString: String) -> [[[Int]]] {
        caminosJugador.removeAll()
        jugadaInterEnteros.removeAll()
        jugadasEnteros.removeAll()
        jugadasString = caminoString.components(separatedBy: ",")
        for c in jugadasString {
            if c.count > 0 {    // Esto es para descartar el último ","
                if c != "*" {
                    jugadaInterEnteros.append(Int(String(c))!)
                } else {            // Ya tengo un grupo de pares de una jugada
                    numeroPares = 0
                    while numeroPares < jugadaInterEnteros.count {
                        parCeldas.removeAll()
                        parCeldas.append(jugadaInterEnteros[numeroPares])
                        parCeldas.append(jugadaInterEnteros[numeroPares + 1])
                        jugadasEnteros.append(parCeldas)
                        numeroPares = numeroPares + 2
                    }
                    caminosJugador.append(jugadasEnteros)
                    jugadaInterEnteros.removeAll()
                    jugadasEnteros.removeAll()
                }
            }
        }
        return caminosJugador
    }

    // Ver si Fin de matrix
    @IBAction func verificarSiQuedan2(_ sender: Any) {
        soloPrueba = true
        valorParCompleto = calculoOrdenadorGrupos(matrixOrdCalculo: matrixPartida, version: versionActual)
        ordPuntuacion22.text = "\(valorParCompleto)"
        if valorParCompleto == 0 {
            // Debo guardar la versión finalizada con estado = 2
            /*
             Se ha completado la Matriz Versión actual, hay que:
             guardar la Matriz con estado = 2 y los puntos/pares/filas/columnas del Jugador
             actualizar la Partida con versionActual + 1 y los puntos/pares/filas/columnas del Jugador
             */
            guardarMatrizComboVersion(matrizGuardar: matrixPartida, jugador: partidaComboSeleccionada.idJugador!, version: versionActual, estado: 2, pares: paresVersion, puntos: puntosVersion, filas: filasVersion, mayor: grupoMayorVersion, camino: caminosJugador)
  //          guardarCaminosSolucion(codigoMatriz: Int16(codigoMatrizActual), version: versionActual, caminos: caminosJugador, jugador: partidaComboSeleccionada.idJugador!)
            // Compruebo si es la última vuelta por la version y el tipoJuego
            let tipoJ = partidaComboSeleccionada.tipoPartida
            if tipoJ < 5 {
                // es de los 4 primeros tipos que solo tienen una vuelta/versión
                // Fin de Partida guardo y antes de volver debería enseñar los resultados
                guardarPartidaCombo(version: versionActual, estado: 2, matrizGuardar: matrixPartida)
                guardarJugador()
                // Ir a FINAL DE PARTIDA
                self.performSegue(withIdentifier: "irAFinalPartidaSegue", sender: numDePartidas)
            } else {
                if tipoJ < 11 {
                    // es de los de 4 vueltas, compruebo version
                    // Si aún está en juego (< 5) creo la siguiente matrixComboPartida / versión
                    if versionActual < 4 {
                        versionActual = versionActual + 1
                        // Debemos guardar la Versión de la MatricesCombo
                        // Creamos la version n de Ordenador y jugador
               //         matrixPartida.removeAll()
                        matrixPartida = crearMatricesComboPartida(codigoMatriz: codigoMatrizActual, jugador: partidaComboSeleccionada.idJugador!, version: versionActual)
                        soloPrueba = false
                        valorParCompleto = calculoOrdenadorGrupos(matrixOrdCalculo: matrixPartida, version: versionActual)
                        /*
                         Ya tenemos actualizado los contadores del Ordenador
                         puntosOrdenador = puntosOrdenador + Int64(puntosVersionOrd)
                         paresOrdenador = paresOrdenador + Int64(paresVersionOrd)
                         filasOrdenador = filasOrdenador + Int64(filasVersionOrd)
                         // el grupoMayorVersionOrd está ya cargado
                         //                   puntosOrdenador = puntosOrdenador + valorParCompleto
                         */
                        
                        ordPuntuacion12.text = "\(puntosOrdenador)"
                        // Hemos creado la Version n del Jugador una con estado 0 y otra estado 1 que jugamos
                        // Como hemos cambiado de version actualizamos
                        partidaComboSeleccionada.version = versionActual
                        // Vamos a transformar matrixPartida a matrix
                        // Primero buscamos las filasBlanco
                        filasBorradasAntes = buscarFilasBlanco(matrizFilasBlanco: matrixPartida)
                        // Después creamos la matrixVersion quitando las filas en blanco
                        // y desplazando las celdas/filas
                        matrixVersion = CrearMatrixVersion(matrizAVersionar: matrixPartida)
                        // Ahora puedo generar matrix
                        pintarMatrixPartida()
                        // Ahora ya tengo en matrixComboJugada la matrix a jugar
                    } else {
                        // Hemos acabado la PartidasCombo
                        // Fin de Partida guardo y antes de volver debería enseñar los resultados
                        guardarPartidaCombo(version: versionActual, estado: 2, matrizGuardar: matrixPartida)
                        guardarJugador()
                        // Ir a FINAL DE PARTIDA
                        self.performSegue(withIdentifier: "irAFinalPartidaSegue", sender: numDePartidas)
                    }
                } else {
                    // Es de tipo 11: 10 vueltas
                    if versionActual < 10 {
                        versionActual = versionActual + 1
                        // Creamos la version n de Ordenador y jugador
                        //         matrixPartida.removeAll()
                        matrixPartida = crearMatricesComboPartida(codigoMatriz: codigoMatrizActual, jugador: partidaComboSeleccionada.idJugador!, version: versionActual)
                        soloPrueba = false
                        valorParCompleto = calculoOrdenadorGrupos(matrixOrdCalculo: matrixPartida, version: versionActual)
                        /*
                         Ya tenemos actualizado los contadores del Ordenador
                         puntosOrdenador = puntosOrdenador + Int64(puntosVersionOrd)
                         paresOrdenador = paresOrdenador + Int64(paresVersionOrd)
                         filasOrdenador = filasOrdenador + Int64(filasVersionOrd)
                         // el grupoMayorVersionOrd está ya cargado
                         // puntosOrdenador = puntosOrdenador + valorParCompleto
                         */
                        ordPuntuacion12.text = "\(puntosOrdenador)"
                        // Hemos creado la Version n del Jugador una con estado 0 y otra estado 1 que jugamos
                        // Como hemos cambiado de version actualizamos
                        partidaComboSeleccionada.version = versionActual
                        // Vamos a transformar matrixPartida a matrix
                        // Primero buscamos las filasBlanco
                        filasBorradasAntes = buscarFilasBlanco(matrizFilasBlanco: matrixPartida)
                        // Después creamos la matrixVersion quitando las filas en blanco
                        // y desplazando las celdas/filas
                        matrixVersion = CrearMatrixVersion(matrizAVersionar: matrixPartida)
                        // Ahora puedo generar matrix
                        pintarMatrixPartida()
                        // Ahora ya tengo en matrixComboJugada la matrix a jugar
                    } else {
                        // Hemos acabado la PartidasCombo
                        // Fin de Partida guardo y antes de volver debería enseñar los resultados
                        guardarPartidaCombo(version: versionActual, estado: 2, matrizGuardar: matrixPartida)
                        guardarJugador()
                        // Ir a FINAL DE PARTIDA
                        self.performSegue(withIdentifier: "irAFinalPartidaSegue", sender: numDePartidas)
                    }
                }
            }
        }
    }
    
    func guardarPartidaCombo(version: Int16, estado: Int16, matrizGuardar: [Int]) {
        let contexto = conexion()
        // Leo la partida del Jugador
        let peticion = NSFetchRequest<PartidasCombo>(entityName: "PartidasCombo")
        let stringidPartida = String(partidaComboSeleccionada.codigoPartida)
        let predicado = NSPredicate (format: "(codigoPartida == %@) && (idJugador == %@)", stringidPartida, partidaComboSeleccionada.idJugador!)
        peticion.predicate = predicado
        do {
            let resultados = try contexto.fetch(peticion)
            let partidaCreada = resultados.first!
            partidaCreada.codigoMatriz = Int32(codigoMatrizActual)
            partidaCreada.fechaFinal = NSDate() as Date
            partidaCreada.estado = estado
            partidaCreada.version = version
            if estado == 2 {
                partidaCreada.celdasFinal = cambiarMatrizAString(matrizAString: matrizGuardar)
            }
            partidaCreada.caminoFinalJugador = cambiarCaminosAString(caminos: caminosJugador)
            partidaCreada.caminoFinalOrdenador = cambiarCaminosAString(caminos: caminosTotalOrdenador)
            partidaCreada.puntosJugador = puntosJugador
            partidaCreada.paresJugador = paresJugador
            partidaCreada.filasBlancoJugador = Int16(filasJugador)
            partidaCreada.mayorGrupoJugador = grupoMayorVersion
            partidaCreada.puntosOrdenador = puntosOrdenador
            partidaCreada.paresOrdenador = paresOrdenador
            partidaCreada.filasBlancoOrdenador = Int16(filasOrdenador)
            partidaCreada.mayorGrupoOrdenador = partidaComboSeleccionada.mayorGrupoOrdenador
            if finalGlorioso {
                partidaCreada.finalGlorioso = true
            } else {
                partidaCreada.finalGlorioso = false
            }
    //        partidaCreada.celdasFinal = cambiarMatrizAString(matrizAString: matrizGuardar)
            try! contexto.save()
        } catch let error as NSError {
            print("No pude recuperar guardar partida \(error), \(error.userInfo)")
        }
    }
    func guardarJugador() {
        let contexto = conexion()
        // Leo el Jugador
        let peticion = NSFetchRequest<Jugadores>(entityName: "Jugadores")
        let predicado = NSPredicate (format: "idJugador == %@", partidaComboSeleccionada.idJugador!)
        peticion.predicate = predicado
        do {
            let resultados = try contexto.fetch(peticion)
            let jugadorActivo = resultados.first!
            jugadorActivo.puntosTotal = puntosTotalJugador + puntosJugador
            jugadorActivo.paresTotal = paresTotalJugador + paresJugador
            jugadorActivo.filasTotal = filasTotalJugador + filasJugador
            try! contexto.save()
        } catch let error as NSError {
            print("No pude recuperar guardar partida \(error), \(error.userInfo)")
        }
    }
    
    
    
    // Funciones del collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return matrix.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let celda = collectionView.dequeueReusableCell(withReuseIdentifier: "numeroCelda", for: indexPath) as! matrixCollectionViewCell
        celda.etiqueta2.text = self.imageData[self.matrix [indexPath.row]]
   //     celda.backgroundColor = UIColor.white
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
        // handle tap events
        let celda = collectionView.cellForItem(at: indexPath)
        
        // vamos a controlar las pulsaciones teniendo en cuenta las pulsaciones pares
        // var pulsacionesPar: Bool = false
        
        if numPulsaciones == 0 {                            // Inicio del if numPulsaciones == 0 +-+-+-+-+-+-+-+-+-+-+-
            // la primera pulsación
            celdaPrimera = indexPath                        // Guardo el indexPath de la Celda primera del grupo
            valorPrimera = matrix [celdaPrimera.row]        // Guardo el VALOR de la Celda primera del grupo
            celda1 = indexPath
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
//            celda?.backgroundColor = colorElegido
            matrixColor[celdaPrimera.row] = color6
//            celda?.backgroundColor = color6
            numPulsaciones = 1
            paresGrupo = 0
            puntosGrupo = 0
            pulsacionesPar = false
            tengoGrupo = false
            indexGrupoJugador.removeAll()
            indexGrupoParcial.removeAll()
            self.matrixCollectionView2.reloadData()
        } else {
            // Es una pulsación después de la primera
            numPulsaciones = numPulsaciones + 1
            // Esto habría que sacarlo de aquí y hacer funciones para cada variable
            // Calculamos si pulsacionesPar, si esCompatible, si yaEsta y si sonLaMisma son ciertas o falsas
            // Miro si es pulsacionesPar
            if numPulsaciones % 2 == 0 {
                pulsacionesPar = true
            } else {
                pulsacionesPar = false
            }
            // vemos si esCompatible para hacer pareja
            let valorNuevo = matrix [indexPath.row]
            if valorPrimera == valorNuevo || (valorPrimera + valorNuevo) == 10 {
                esCompatible = true
            } else {
                esCompatible = false
            }
            // Vemos si esta casilla yaEstá en el indexGrupoJugador
            yaEsta = false
            if indexGrupoJugador.count > 0 {
                for h in 0 ... indexGrupoJugador.count - 1 {
                    if indexPath.row == indexGrupoJugador[h][0].row || indexPath.row == indexGrupoJugador[h][1].row {
                        yaEsta = true
                    }
                }
            }
            // Veamos si es la misma celda que la pulsada anteriormente que dependerá si es par o impar
            if pulsacionesPar {
                // Al ser PAR comparamos con celda1
                if indexPath == celda1 {
                    sonLaMisma = true
                } else {
                    sonLaMisma = false
                }
            } else {
                // Al ser IMPAR comparamos con celda2
                if indexPath == celda2 {
                    sonLaMisma = true
                } else {
                    sonLaMisma = false
                }
            }
            // También vemos si "hace grupo" es decir se hace pareja con cualquiera de indexGrupoJugador
            if esCompatible && yaEsta == false {
                // esCompatible y no está ya: Comprobar si esta Celda puede hacer pareja con cualquier Celda ya guardada
                i = 0
                haceGrupo = false
                if indexGrupoJugador.count > 0 {
                    for i in 0 ... indexGrupoJugador.count - 1 {
                        if continuaCadena(celdaA: indexPath, celdaB: indexGrupoJugador[i][0]) || continuaCadena(celdaA: indexPath, celdaB: indexGrupoJugador[i][1]){
                            haceGrupo = true
                        }
                    }
                }
            }
            // Ya tenemos todas las variables ahora vamos a seleccionar
            if !pulsacionesPar && numPulsaciones != 1 {     // Principio de if/else !pulsacionesPar && numPulsaciones != 1 **
                // Es IMPAR y no es la primera (la primera la tratamos aparte -> redundante)
                if esCompatible == false {
                    // Si NO esCompatible -> Movimiento fallido no hago nada y numPulsaciones - 1
                    numPulsaciones = numPulsaciones - 1
                } else {
                    if yaEsta {
                        // Si yaEstá al ser IMPAR -> ir a acumular la Jugada y empezar de nuevo
                        limpiarColores()
                        anotarJugada()
                    } else {
                        // Es Nueva. Comprobar si esta Celda puede hacer pareja con cualquier Celda ya guardada
                        if haceGrupo {
                            // sigue la cadena y es la primera celda del nuevo eslabón. Pongo la celda como Celda1
         //                   celda?.backgroundColor = colorElegido
                            matrixColor[indexPath.row] = color6         // Por ser impar
                            celda?.backgroundColor = color6
                            celda1 = indexPath
                            self.matrixCollectionView2.reloadData()
                        } else {
                            // Creo que movimiento fallido: no hago nada  ojojojojojojo
                            numPulsaciones = numPulsaciones - 1
                        }
                    }
                }                                            // Fin de if/else !pulsacionesPar && numPulsaciones != 1 **
            } else {
                // Es PAR
                // Comprobamos si es la misma celda que la penúltima
                if sonLaMisma {
                    // Es PAR y son la  misma -> limpio celda1, resto numPulsaciones - 2 y regreso
                    let celda = collectionView.cellForItem(at: celda1)
                    celda?.backgroundColor = UIColor.white
                    matrixColor[celda1.row] = UIColor.white
                    numPulsaciones = numPulsaciones - 2
                    self.matrixCollectionView2.reloadData()
                } else {
                    // Veamos si ya está en el indexGrupoJugador
                    if yaEsta {
                        // Repite celda ya elegida -> ignoramos y continúo
                        numPulsaciones = numPulsaciones - 1
                    } else {
                        // Son distintas y no es una de las del grupoJugador -> veamos si son compatibles
                        if esCompatible {
                            celda2 = indexPath
                            if continuaCadena(celdaA: celda1, celdaB: celda2) {
                                // Forman pareja -> acumulo en grupoParejasJugador y continúo
    //                            celda?.backgroundColor = colorElegido
                                matrixColor[celda1.row] = colorElegido
                                matrixColor[celda2.row] = colorElegido
                                encontradaParejaGrupo(primero: celda1, segundo: celda2)
                                self.matrixCollectionView2.reloadData()
                            } else {
                                // No forman pareja -> resto 1 a numPulsaciones y continúo
                                numPulsaciones = numPulsaciones - 1
                            }
                        } else {
                            // No son compatibles -> resto 1 a numPulsaciones y continuo
                            numPulsaciones = numPulsaciones - 1
                        }
                    }
                }
            }                           // Fin de if/else !pulsacionesPar && numPulsaciones != 1 **
        }                               // Fin del if/else numPulsaciones == 0 +-+-+-+-+-+-+-+-+-+-+-
    }
    func continuaCadena(celdaA: IndexPath, celdaB: IndexPath) -> Bool {
        // Ordeno las celdas
        if celdaA.row < celdaB.row {indice1 = celdaA; indice2 = celdaB}
        else           {indice1 = celdaB; indice2 = celdaA}
        sigueCadena = false
        // compruebo
        if (indice1.row % 9) == (indice2.row % 9) {
            // Misma columna: comprobar abajo
            if comprobarAbajo(primero: indice1.row, segundo: indice2.row) {
                sigueCadena = true
            }
        } else {
            // Distinta columna hay que comprobar adelante
            if comprobarAdelante(primero: indice1.row, segundo: indice2.row) {
                sigueCadena = true
            }
        }
        return sigueCadena
    }
    // Funciones de comprobación de pareja encontrada por el Jugador
    func comprobarAbajo (primero: Int, segundo: Int) -> Bool {
        if primero == segundo - 9 {
            pareja = true
        } else {
            empiezo = primero + 9
            while empiezo <= segundo - 9 {
                caminoLibre = false
                if indexGrupoJugador.count > 0 {
                    for h in 0 ... indexGrupoJugador.count - 1 {         // Aquí tengo que ver que las de enmedio están ya en el grupo
                        if empiezo == indexGrupoJugador[h][0].row || empiezo == indexGrupoJugador[h][1].row {
                            caminoLibre = true
                        }
                    }
                }
                if matrix [empiezo] != 0 && caminoLibre == false {
                    pareja = false
                    return pareja
                }
                empiezo = empiezo + 9
            }
            pareja = true
        }
        return pareja
    }
    func comprobarAdelante (primero: Int, segundo: Int) -> Bool {
        if primero == segundo - 1 {
            pareja = true
        } else {
            empiezo = primero + 1
            while empiezo <= segundo - 1 {
                caminoLibre = false
                if indexGrupoJugador.count > 0 {
                    for h in 0 ... indexGrupoJugador.count - 1 {         // Aquí tengo que ver que las de enmedio están ya en el grupo
                        if empiezo == indexGrupoJugador[h][0].row || empiezo == indexGrupoJugador[h][1].row {
                            caminoLibre = true
                        }
                    }
                }
                if matrix [empiezo] != 0 && caminoLibre == false {
                    pareja = false
                    return pareja
                }
                empiezo = empiezo + 1
            }
            pareja = true
        }
        return pareja
    }
    
    func encontradaParejaGrupo(primero: IndexPath, segundo: IndexPath) {
        // Ver puntuación
        // Guardo las parejas de IndexPath en indexGrupoJugador
        indexGrupoParcial.removeAll()
        indexGrupoParcial.append(primero)
        indexGrupoParcial.append(segundo)
        indexGrupoJugador.append(indexGrupoParcial)
        paresGrupo = paresGrupo + 1
        puntosGrupo = valorGrupo(n: paresGrupo)
//        puntosGrupo = paresGrupo + (paresGrupo - 1) * 2
        puntosParcial.text = "\(puntosGrupo)"
        tengoGrupo = true
    }
    func encontradaPareja (primero: IndexPath, segundo: IndexPath) {
        paresJugador = paresJugador + 1
        filaLog.removeAll()
        filaLog.append(primero.row)
        filaLog.append(segundo.row)
        filaLog.append(matrix [primero.row])
        filaLog.append(matrix [segundo.row])
        matrix [primero.row] = 0
        matrix [segundo.row] = 0
        logJuego.append(filaLog)
        indiceLog = indiceLog + 1
        self.matrixCollectionView2.reloadData()
    }
    
    // IBOutlets
    @IBOutlet weak var matrixCollectionView2: UICollectionView!
    
    @IBOutlet weak var ordPuntuacion12: UILabel!
    @IBOutlet weak var ordPuntuacion22: UILabel!
    @IBOutlet weak var tuPuntuacion2: UILabel!
    @IBOutlet weak var puntosParcial: UILabel!
    var numPartidaJ: Int = 0
    
    @IBAction func irAtras2(_ sender: Any) {
        let numDePartidaJugada = numDePartidas + 1
        guardarMatrizComboVersion(matrizGuardar: matrixPartida, jugador: jugadorSeleccionado.idJugador!, version: versionActual, estado: 1, pares: paresVersion, puntos: puntosVersion, filas: filasVersion, mayor: grupoMayorVersion, camino: caminosJugador)
  //      guardarCaminosSolucion(codigoMatriz: Int16(codigoMatrizActual), version: versionActual, caminos: caminosJugador, jugador: jugadorSeleccionado.idJugador!)
        guardarPartidaCombo(version: versionActual, estado: 1, matrizGuardar: matrixPartida)
        guardarJugador()
        self.performSegue(withIdentifier: "volverDeJugar", sender: numDePartidaJugada)
    }
    
    func anotarJugada() {
        // Vamos a guardar la Jugada en caminosJugador [[[Int]]]
        // caminosJugador: [[[c1a,c1b][c2a,c2b]...[cNa, cNb]][[d1a,d1b]]...[[]]]
        // A la vez vamos poniendo a 0 las Celdas de matrixPartida
        // Hay que tener en cuenta que el índice a 0 de matrixPartida
        // es el contenido de la Celda de matrixVersion con índice igual que matrix
        if tengoGrupo {
            // Guardo el nuevo grupo en grupoJugadas (desde indexGrupoJugador y de matrix)
            filasEnBlanco1 = Int(buscarFilasBlanco(matrizFilasBlanco: matrixPartida))
            grupoJugadasInter2.removeAll()
            for i in 0 ... indexGrupoJugador.count - 1 {
                grupoJugadasParcial.removeAll()
                let sd1 = indexGrupoJugador[i][0].row
                let sd2 = indexGrupoJugador[i][1].row
                grupoJugadasParcial.append(matrixVersion[sd1])
                grupoJugadasParcial.append(matrixVersion[sd2])
                grupoJugadasInter2.append(grupoJugadasParcial)
                matrixPartida[matrixVersion[sd1]] = 0
                matrixPartida[matrixVersion[sd2]] = 0
                encontradaPareja(primero: indexGrupoJugador[i][0], segundo: indexGrupoJugador[i][1])
            }
            caminosJugador.append(grupoJugadasInter2)
            paresGrupo = grupoJugadasInter2.count
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
            tuPuntuacion2.text = "\(puntosJugador)"
            numPulsaciones = 0
            puntosParcial.text = "0"
            // Ahora, partiendo de la nueva matrixPartida
            // tengo que generar matrixVersion y matrix
            // Vamos a transformar matrixPartida a matrix
            // Primero buscamos las filasBlanco (Ya lo tengo por filasEnBlanco1/2)
  //          filasBorradasAntes = buscarFilasBlanco(matrizFilasBlanco: matrixPartida)
            // Después creamos la matrixVersion quitando las filas en blanco
            // y desplazando las celdas/filas
            matrixVersion = CrearMatrixVersion(matrizAVersionar: matrixPartida)
            // Ahora puedo generar matrix
            pintarMatrixPartida()
            self.matrixCollectionView2.reloadData()
        }
    }
    func valorGrupo(n: Int) -> Int{
        puntosN = 0
        for ii in 1...n {
            puntosN = puntosN + ii
        }
        return puntosN
    }
    
    @IBAction func borrarMovimiento2(_ sender: Any) {
        // Tenemos que recorrer los caminosjugador, borrar el último e inicializar
        // Vamos a utilizar este botón tanto para limpiar la jugada empezada
        // como para deshacer una jugada completada
        // creo que lo más sencillo es numPulsaciones = 0 y reload
        if numPulsaciones > 0 {
            numPulsaciones = 0
            puntosParcial.text = "0"
            limpiarColores()
            self.matrixCollectionView2.reloadData()
        } else {
            if caminosJugador.count > 0 {
                let ultimoGrupo = caminosJugador.last!
                filasEnBlanco1 = Int(buscarFilasBlanco(matrizFilasBlanco: matrixPartida))
                for pares in ultimoGrupo {
                    // estoy leyendo las parejas del último grupo
                    let sd1 = pares[0]
                    let sd2 = pares[1]
                    matrixPartida[sd1] = matrixPartidaOriginal[sd1]
                    matrixPartida[sd2] = matrixPartidaOriginal[sd2]
                }
                caminosJugador.remove(at: caminosJugador.count - 1)
                paresGrupo = ultimoGrupo.count
                paresVersion = paresVersion - Int32(paresGrupo)
     //           puntosGrupo = paresGrupo + (paresGrupo - 1) * 2
                puntosGrupo = valorGrupo(n: paresGrupo)
                filasEnBlanco2 = Int(buscarFilasBlanco(matrizFilasBlanco: matrixPartida))
                let puntosFilaBlanco = 4 * (filasEnBlanco1 - filasEnBlanco2)    // OJOJOJOJO
                puntosVersion = puntosVersion - Int32(puntosGrupo + (puntosFilaBlanco))
                puntosJugador = puntosJugador - Int64(puntosGrupo + (puntosFilaBlanco))
                tuPuntuacion2.text = "\(puntosJugador)"
                numPulsaciones = 0
                puntosParcial.text = "0"
                matrixVersion = CrearMatrixVersion(matrizAVersionar: matrixPartida)
                // Ahora puedo generar matrix
                pintarMatrixPartida()
                self.matrixCollectionView2.reloadData()
            }
            // No hay nada que borrar
        }
    }
    func borrarMovimientoIndividual() {
        if indiceLog > 0 {
 //           puntosJugador = puntosJugador - 1
            paresJugador = paresJugador - 1
            filaLog = logJuego.last!
            celdaLog1 = filaLog [0]
            celdaLog2 = filaLog [1]
            valorLog1 = filaLog [2]
            valorLog2 = filaLog [3]
            matrix [celdaLog1] = valorLog1
            matrix [celdaLog2] = valorLog2
            logJuego.remove(at: indiceLog - 1)
            indiceLog = indiceLog - 1
            self.matrixCollectionView2.reloadData()
        }
    }
    // Funciones de la matriz de colores: matrixColor
    func limpiarColores() {
        matrixColor.removeAll()
        for _ in 0...matrix.count - 1 {
            matrixColor.append(UIColor.white)
        }
    }
    // Funciones de la matriz de colores: matrixColor
    func inicializarVisibilidad() {
        matrixVisibilidad.removeAll()
        for _ in 0...matrix.count - 1 {
            matrixVisibilidad.append(true)
        }
    }
    
    // Flujo de ventanas
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "volverDeJugar" {
        } else {
            if segue.identifier == "irAFinalPartidaSegue" {
                let objJugar: FinalPartidaViewController =  segue.destination as! FinalPartidaViewController
                objJugar.jugadorSeleccionado = jugadorSeleccionado
                objJugar.partidaComboSeleccionada = partidaComboSeleccionada
            }
        }
    }
    

    
    
    // Variables
    // ################ Variables y funciones de MATRIXORIGINAL
    
    
    
    
    
    // ################ Variables y funciones de MATRIXORIGINAL
    
    var numCasillasOriginal: Int = 0
    var numDePartidas: Int = 0
    var numDePartidasJ: Int = 0
    var codigoMatrizCreada: Int32 = 0
    var idMatrizCreada: Int32 = 0
    var idPartidaAJugar: Int = 0
    
    var matrix: [Int] = [Int]()
    var matrixColor: [UIColor] = [UIColor]()
    var matrixVisibilidad: [Bool] = [Bool]()
    
    var pareja: Bool = false
    var finalPartida: Bool = false
    var finalGlorioso: Bool = false
    
    var numPulsaciones: Int = 0
    var numColumnas: Int = 9
    var numFilas: Int = 15
    var numCasillas: Int = 0
    var numCasillasTotal: Int = 0
    var incremento: Int = 0
    var filaALimpiar1: Int = 0
    var filaALimpiar2: Int = 0
    var numFilasLimpias: Int = 0
    
    var fila: Int = 0
    var columna: Int = 0
    var columna1: Int = 0
    var columna2: Int = 0
    var i: Int = 0
    var j: Int = 0
    var empiezo: Int = 0
    var filas: Int = 0
    var puntosTotalJugador: Int64 = 0
    var paresTotalJugador: Int64 = 0
    var filasTotalJugador: Int64 = 0
    var puntosJugador: Int64 = 0
    var paresJugador: Int64 = 0
    var filasJugador: Int64 = 0
    var mayorGrupoJugador: Int16 = 0
    var puntosOrdenador: Int64 = 0
    var paresOrdenador: Int64 = 0
    var filasOrdenador: Int64 = 0
    var mayorGrupoOrd: Int16 = 0
    var indiceLog: Int = 0
    var ordPuntos: Int64 = 0
    var ordFilas: Int64 = 0
    var ordPares: Int64 = 0
    var ordPuntos1: Int64 = 0
    var ordPuntos2: Int64 = 0
    var puntosValidar: Int64 = 0
    var numeroDeCeros: Int = 0
    
    var cantidadMatrices: Int = 0
    var cantidadPartidas: Int = 0
    var versionActual: Int16 = 0
    var celdasAnteriores: Int32 = 0
    var desde: Int32 = 0
    var uno: Int32 = 1
    
    var parejas: Int = 0
    var repetir: Int = 0
    var distintos: Int = 0
    
    var celdaPrimera = IndexPath()
    var celda1 = IndexPath()
    var celda2 = IndexPath()
    var valorPrimera: Int = 0
    var paresGrupo: Int = 0
    var puntosGrupo: Int = 0
    var indice1 = IndexPath()
    var indice2 = IndexPath()
    var pulsacionesPar: Bool = false
    var tengoGrupo: Bool = false
    var yaEsta: Bool = false
    var esCompatible: Bool = false
    var sigueCadena: Bool = false
    var caminoLibre: Bool = false
    var sonLaMisma: Bool = false
    var haceGrupo: Bool = false
    var soloPrueba: Bool = false
    var listaGrupoJugador: [[Int]] = [[Int]]()                 // Guarda los indexPath de las Celdas ya parejas y de la que está en juego IMPAR
    var indexGrupoJugador: [[IndexPath]] = [[IndexPath]]()     // Guarda los IndexPath de la pareja de Celdas que son PAREJA entre sí
//    var casillasGrupoJugador: [[Int]] = [[Int]]()              // Guarda los Valores de la pareja de Celdas que son PAREJA entre sí
    var grupoJugadas: [[Int]] = [[Int]]()                      // Guarda los Grupos: puntuación y las parejas de índices y valores del Grupo Jugado
    var lineasBlancasJugadas: [[Int]] = [[Int]]()               // Guarda las lineas borradas de cada jugada
    /*
     lineasBlancasJugadas[numGrupo][0] = numGrupo o número de Jugada
     lineasBlancasJugadas[numGrupo][1] = numFilasBlanco -> el número de filas borradas en esa Jugada (0 = no hay)
     lineasBlancasJugadas[numGrupo][2] = primera fila borrada
     lineasBlancasJugadas[numGrupo][...]
     lineasBlancasJugadas[numGrupo][numFilasBlanco + 1] = última fila borrada
     */
    var lineasBlancasJugadasInter: [Int] = [Int]()               // Guarda las lineas borradas de cada jugada
    var lineasBlancas: [Int] = [Int]()
    var cuentaCasillasBlanco: Int = 0
    var indexGrupoParcial: [IndexPath] = [IndexPath]()
    var grupoJugadasInter: [[Int]] = [[Int]]()
    var grupoJugadasInter2: [[Int]] = [[Int]]()
//    var casillasGrupoParcial: [Int] = [Int]()
    var grupoJugadasParcial: [Int] = [Int]()
    var valorCeldaPrimera: Int = 0
    var indiceCeldaPrimera: IndexPath = IndexPath()
    var celdaAnterior1 = IndexPath()
    var celdaAnterior2 = IndexPath()
    var valorAnterior1: Int = 0
    var valorAnterior2: Int = 0
    var numCaminosGuardados: Int = 0
    
    // Variables de GRUPOS
    var filasBorradasJugada: [Int] = [Int]()
    var pares: Int = 0
    var numGrupoAnterior: Int = 0
    var numSubgrupoAnterior: Int = 0
    var h: Int = 0
    var k: Int = 0
    var l: Int = 0
    var m: Int = 0
    var n: Int = 0
    
    // variables para el log
    var logJuego: [[Int]] = [[Int]]()
    var filaLog: [Int] = [Int]()
    var lineasALimpiarLog: Int = 0
    var lineaLimpiar1Log: Int = 0
    var lineaLimpiar2Log: Int = 0
    var celdaLog1: Int = 0
    var celdaLog2: Int = 0
    var valorLog1: Int = 0
    var valorLog2: Int = 0
    var celdaAInsertar: Int = 0
    
    
    // Funciones de cálculo del Ordenador ************ Nivel0: lógica ***************
    func calculoOrdenadorGrupos(matrixOrdCalculo: [Int], version: Int16) -> Int64 {
//        filasBorradasAntes = fil
        caminosJugadaOrdenador.removeAll()
        filasBorradasAntesOrd = buscarFilasBlanco(matrizFilasBlanco: matrixOrdCalculo)
        matrixOrdGrupos.removeAll()
        for i in 0 ... matrixOrdCalculo.count - 1 {
            switch matrixOrdCalculo[i] {
            case 1: matrixOrdGrupos.append(1)
            case 2: matrixOrdGrupos.append(2)
            case 3: matrixOrdGrupos.append(3)
            case 4: matrixOrdGrupos.append(4)
            case 5: matrixOrdGrupos.append(5)
            case 6: matrixOrdGrupos.append(4)
            case 7: matrixOrdGrupos.append(3)
            case 8: matrixOrdGrupos.append(2)
            case 9: matrixOrdGrupos.append(1)
            default: matrixOrdGrupos.append(0)
            }
            numCasillas = matrixOrdCalculo.count
        }
 //       caminosTotalOrdenador.removeAll()
        calcularFrecuencia(matrixFrecuencia: matrixOrdGrupos)
        // Calculo la frecuencia ¿¿¿una sola vez??? y dejo en ordenEtiquetas
        // Proceso hasta fin de los grupos PARES, después ya veremos
        finReGrupos = false
        while finReGrupos == false {
            // Lo primero es calcular los reGrupos ordenados
            reGrupos = reAgrupar(matrixReAgrupar: matrixOrdGrupos)
            // Esto nos devuelve reGrupos ya Ordenados al que le vamos a "jugar" los Grupos que nos interesen
            if reGrupos.count > 0 {
                // Tengo en ordenEtiquetas el orden para buscar grupo de reGrupos
                calcularFrecuencia(matrixFrecuencia: matrixOrdGrupos)   // Calculo la frecuencia antes de elegirReGrupo
                // Cambiamos y elegirRegrupo devuelve el grupoElegido elegido para JUGAR
                grupoElegido = elegirGrupoParMenor(elegirReGrupo: reGrupos)
                if grupoElegido.count > 0 {
                    // Ha elegido uno de los reGrupos, lo jugamos y limpiado matrixOrdGrupos
                    caminoMayorJugada = buscarCamino(matrixBuscar: matrixOrdGrupos, grupoBuscar: grupoElegido)
                    if caminoMayorJugada.count == 0 {
                        print("No hay caminoMayorJugada 111 ?????")
                    }
                    if soloPrueba == false {
                        caminosTotalOrdenador.append(caminoMayorJugada)
                    }
                    caminosJugadaOrdenador.append(caminoMayorJugada)
                    // Nos devuelve el caminoMayorJugada con los PARES ordenados
                    // Borrar celdas de caminoMayorjugada
                    for l in 0 ... caminoMayorJugada.count - 1 {
                        matrixOrdGrupos[caminoMayorJugada[l][0]] = 0
                        matrixOrdGrupos[caminoMayorJugada[l][1]] = 0
                    }
                } else {
                    // No ha encontrado grupo para jugar ¿?
                    print("No ha encontrado grupo para jugar RARO -> FIN")
                    //          finReGrupos = true
                }
            } else {
 //               print("No hay reGrupos FIN")
                finReGrupos = true
            }
        }
        if caminosJugadaOrdenador.count == 0 {
            return 0
        } else {
            puntosVersionOrd = 0
            paresVersionOrd = 0
            filasVersionOrd = 0
            calcularPuntosCaminosOrdenador(caminosACalcular: caminosJugadaOrdenador, metodoCalculo: 0)
            // Ya tenemos los puntos de la Version del Ordenador en xxxVersionOrd
            if soloPrueba == false {
                // Ahora debo actualizar los datos del Ordenador en PartidasCombo
                guardarMatrizComboVersion(matrizGuardar: matrixOrdGrupos, jugador: "Ordenador", version: versionActual, estado: 2, pares: Int32(paresVersionOrd), puntos: Int32(puntosVersionOrd), filas: filasVersionOrd, mayor: grupoMayorVersionOrd, camino: caminosTotalOrdenador)
                partidaComboSeleccionada.puntosOrdenador = partidaComboSeleccionada.puntosOrdenador + puntosVersionOrd
                partidaComboSeleccionada.paresOrdenador = partidaComboSeleccionada.paresOrdenador + paresVersionOrd
                partidaComboSeleccionada.filasBlancoOrdenador = partidaComboSeleccionada.filasBlancoOrdenador + filasVersionOrd
                if partidaComboSeleccionada.mayorGrupoOrdenador < grupoMayorVersionOrd {
                    partidaComboSeleccionada.mayorGrupoOrdenador = grupoMayorVersionOrd
                }
                puntosOrdenador = puntosOrdenador + Int64(puntosVersionOrd)
                paresOrdenador = paresOrdenador + Int64(paresVersionOrd)
                filasOrdenador = filasOrdenador + Int64(filasVersionOrd)
         //       guardarCaminosSolucion(codigoMatriz: Int16(codigoMatrizActual), version: versionActual, caminos: caminosTotalOrdenador, jugador: "Ordenador")
            }
            return Int64(puntosVersionOrd)
        }
    }
    var grupoElegido: [Int] = [Int]()
    func elegirGrupoParMenor(elegirReGrupo: [[Int]]) -> [Int]{
        // Primero elegimos los de etiqueta de menor frecuencia
        if elegirReGrupo.count > 0 {
            grupoElegido.removeAll()
            gruposPar.removeAll()
            indicesPar.removeAll()
            gruposImpar.removeAll()
            indicesImpar.removeAll()
            // Primero procesamos todos los grupos PARES
            for i in 1...5 {                                // Recorremos ordenEtiquetas de menor a mayor frecuencia
                for j in 0 ... elegirReGrupo.count - 1 {    // Recorremos reGrupos para buscar PAR y sea de la etiqueta
                    if esPar(numCeldas: elegirReGrupo[j].last!) && elegirReGrupo[j][1] == ordenEtiquetas[i] {
                        // Elegir el grupo de los pares más pequeño y que sea de menorValor
                        gruposPar.append(elegirReGrupo[j].last!)
                        indicesPar.append(j)
                    }
                }
                if gruposPar.count > 0 {                 // Hay grupo PAR con el valor de frecuencia actual o siguientes
                    gruposParMenor = gruposPar[0]
                    indiceParMenor = indicesPar[0]
                    for m in 0 ... gruposPar.count - 1 {
                        if gruposParMenor > gruposPar[m] {
                            gruposParMenor = gruposPar[m]
                            indiceParMenor = indicesPar[m]
                        }
                    }
                    // Ya tenemos el grupo de menor número PAR de pares en elegirReGrupo[indiceParMenor]
                    return elegirReGrupo[indiceParMenor]
                }                              // No hay grupo PAR con el valor de frecuencia actual
            }                                  // volvemos a por otro de frecuencia
            // Si sale por aquí es que no hay ningún grupo PAR -> tratamos a los IMPARES
            gruposImpar.removeAll()
            indicesImpar.removeAll()
            for p in 1...5 {    // Todos deben de ser IMPAR Recorremos reGrupos para buscar que sea de la etiqueta
                for l in 0 ... elegirReGrupo.count - 1 {
                    if elegirReGrupo[l][1] == ordenEtiquetas[p] {
                        // Elegir el grupo de número de pares más pequeño y que sea de menorValor
                        gruposImpar.append(elegirReGrupo[l].last!)
                        indicesImpar.append(l)
                    }
                }
                if gruposImpar.count > 0 {                // Hay grupo IMPAR con el valor de frecuencia actual o siguientes
                    gruposImparMenor = gruposImpar[0]
                    indiceImparMenor = indicesImpar[0]
                    for m in 0 ... gruposImpar.count - 1 {
                        if gruposImparMenor > gruposImpar[m] {
                            gruposImparMenor = gruposImpar[m]
                            indiceImparMenor = indicesImpar[m]
                        }
                    }
                    // Ya tenemos el grupo de menor número PAR de pares en elegirParReGrupo[indiceParMenor]
                    return elegirReGrupo[indiceImparMenor]
                }
            }
        }                                      // No hay grupos ni PAR ni IMPAR-> Sanseacabó
        print("No hay grupos ni PAR ni IMPAR: error en elegirReGrupo :-> Sanseacabó")
        return grupoElegido
    }
    var frecuencia: [[Int]] = [[0], [0], [0], [0], [0], [0]]
    var frecuencia1: Int = 0
    var frecuencia2: Int = 0
    var frecuencia3: Int = 0
    var frecuencia4: Int = 0
    var frecuencia5: Int = 0
    var menorValor: Int = 0
    var menorIndice: Int = 0
    var matrixPrueba: [Int] = [Int]()
    func calcularFrecuencia(matrixFrecuencia: [Int]) {
        frecuencia = [[0], [0], [0], [0], [0], [0]]
        for i in 0 ... matrixFrecuencia.count - 1 {
            switch matrixFrecuencia[i] {
            case 1: frecuencia[1][0] = frecuencia[1][0] + 1
            case 2: frecuencia[2][0] = frecuencia[2][0] + 1
            case 3: frecuencia[3][0] = frecuencia[3][0] + 1
            case 4: frecuencia[4][0] = frecuencia[4][0] + 1
            case 5: frecuencia[5][0] = frecuencia[5][0] + 1
            default: frecuencia[0][0] = frecuencia[0][0] + 1
            }
        }

        ordenEtiquetas.removeAll()
        ordenEtiquetas.append(0)            // Por comodidad ponemos el valor 0 en el lugar 0 ;-)
        // Vamos a ordenar ascendentemente las etiquetas en ordenEtiquetas según su frecuencia
        for _ in 1...5 {
            //            print("i: \(i) frecuencia: \(frecuencia) ordenEtiquetas: \(ordenEtiquetas)")
            let g = menorValorFrecuencia()
            ordenEtiquetas.append(g)
            
        }
    }
    func menorValorFrecuencia() -> Int{
        menorValor = matrixOrdGrupos.count      // Pongo el máximo + 1
        for i in 1 ... 5 {                      // excluyo los valores de 0
            if frecuencia[i][0] < menorValor {
                menorIndice = i
                menorValor = frecuencia[i][0]
            }
        }
        frecuencia[menorIndice][0] = matrixOrdGrupos.count // La ponemos al máximo + 1 para que no vuelva a ser seleccionada
        return menorIndice
    }
    var jugada: Int = 0
 //   var jug: Int = 0
    var mayorGrupo: Int = 0
    var valorParCompleto: Int64 = 0
    var matrizValoraciones: [[Int]] = [[Int]]()
    var matrizValoracionesInter: [Int] = [Int]()
    // [Nº jugada, numCasillas, método, numPares, mayorGrupo, valorGrupos, líneas en blanco, valorCompleto
    func calcularPuntosCaminosOrdenador(caminosACalcular:[[[Int]]], metodoCalculo: Int) {
        puntosVersionOrd = 0
        paresVersionOrd = 0
        grupoMayorVersionOrd = 0
        for i in 0...caminosACalcular.count - 1 {
            let paresParcial = caminosACalcular[i].count
            paresVersionOrd = paresVersionOrd + Int64(paresParcial)
            puntosVersionOrd = puntosVersionOrd + Int64(valorGrupo(n: paresParcial))
            if paresParcial > grupoMayorVersionOrd {
                grupoMayorVersionOrd = Int16(paresParcial)
            }
        }
        filasVersionOrd = Int16(buscarFilasBlancoOrdenadorN1(matrizFilasBlanco: matrixOrdGrupos)) - filasBorradasAntesOrd
        puntosVersionOrd = puntosVersionOrd + Int64(filasVersionOrd * 4)
    }
    // ############################# Operaciones de lectura/escritura de CaminosOrdenador <--> caminoTotalOrdenador
    var jugadaInter: String = ""
    var caminoString: String = ""
    var jugadasString: [String] = [String]()
    var jugadaInterEnteros: [Int] = [Int]()
    var jugadasEnteros: [[Int]] = [[Int]]()
    var parCeldas: [Int] = [Int]()
    var numeroJugada: Int = 0
    var numeroPares: Int = 0
    func guardarJugadasOrdenador(caminosAGuardar:[[[Int]]], version: Int16) {
        if caminosAGuardar.count > 0 {
            // Primero borro el CaminoSolucion de ese codigoMatriz y jugador = "Ordenador"
            let contexto = conexion()
            let peticion = NSFetchRequest<CaminosSolucion>(entityName: "CaminosSolucion")
            let stringcodigoMatrizActual = String(codigoMatrizActual)
            let stringVersion = String(version)
            peticion.predicate = NSPredicate(format: "codigoMatriz == %@ AND version == %@ AND jugador == %@", stringcodigoMatrizActual, stringVersion, "Ordenador")
            do {
                let resultados = try! contexto.fetch(peticion)
                if resultados.count > 0 {
                    for i in resultados {
                        contexto.delete(i)
                        try! contexto.save()
                    }
                }
            }
            //
            jugadasString.removeAll()
            for jugadasOrden in caminosAGuardar {
                jugadaInter = ""
                for paresOrden in jugadasOrden {
                    jugadaInter = jugadaInter + String(describing: paresOrden[0]) + ","
                    jugadaInter = jugadaInter + String(describing: paresOrden[1]) + ","
                }
                jugadasString.append(jugadaInter)
            }
            // Ahora Creo CaminosSolucion a partir de caminosTotalOrdenador / caminosAGuardar
            let contexto2 = conexion()
            let entidad2 = NSEntityDescription.entity(forEntityName: "CaminosSolucion", in: contexto2)!
            numeroJugada = 0
            for jugadaActual in jugadasString {
                numeroJugada = numeroJugada + 1
                let jugada = CaminosSolucion(entity: entidad2, insertInto: contexto2)
                jugada.codigoMatriz = Int32(codigoMatrizActual)
                jugada.version = version
                jugada.numJugada = Int16(numeroJugada)
                jugada.jugada = jugadaActual
                jugada.jugador = "Ordenador"
                try! contexto2.save()
            }
        }
    }
    
    // ############################# Operaciones de lectura/escritura de CaminosOrdenador <--> caminoTotalOrdenador
    func reAgrupar (matrixReAgrupar: [Int]) -> [[Int]]{
        // Aquí hago el ciclo de crear los reGrupos de una Matriz
        // De entrada la Matriz a jugar
        reGrupos.removeAll()
        crearGrupos(matrixOrdCrearGrupos: matrixReAgrupar)
        reordenarGrupos()
        hacerReGrupos()
        // Esto nos devuelve reGruposOrdenados al que le vamos a "jugar" los grupo PAR que encontremos
        if reGrupos.count > 0 {
            reGrupos = limpiarReGrupos(reGrupoALimpiar: reGrupos)
        }
        return reGrupos
    }
    func crearGrupos(matrixOrdCrearGrupos: [Int]) {
        gruposEtiqueta.removeAll()
        for i in 0 ... matrixOrdCrearGrupos.count - 2 {
            buscarAdelantePareja(matrixOrdCrearGrupos: matrixOrdCrearGrupos, etiqueta: matrixOrdCrearGrupos[i], i: i)
            if i < matrixOrdCrearGrupos.count - 10 {
                buscarAbajoPareja(matrixOrdCrearGrupos: matrixOrdCrearGrupos, etiqueta: matrixOrdCrearGrupos[i], i: i)
            }
        }
    }
    // Búsqueda de Parejas
    func buscarAdelantePareja (matrixOrdCrearGrupos: [Int], etiqueta: Int, i: Int) {
        if finalTabla == true {return}
        for j in i + 1 ... numCasillas - 1 {                   // Bucle hacia adelante desde la casilla siguiente a la recibida hasta el final de la tabla
            if matrixOrdCrearGrupos [j] != 0 {
                if matrixOrdCrearGrupos [j] == etiqueta {
                    encontradaPareja(etiqueta: etiqueta, i: i, j: j)
                    return
                } else {
                    return
                }
            }
        }
    }
    func buscarAbajoPareja (matrixOrdCrearGrupos: [Int], etiqueta: Int, i: Int) {
        j = i + 9
        if j > numCasillas {return}                               // Estamos en la última fila y no podemos ir hacia abajo. No hemos encontrado pareja con ese i, continuamos
        while j < numCasillas {
            if matrixOrdCrearGrupos [j] != 0 {
                if  matrixOrdCrearGrupos [j] == etiqueta {
                    encontradaPareja(etiqueta: etiqueta, i: i, j: j)
                    return
                } else {
                    return                                      // No hemos encontrado pareja para este "i", continuamos
                }
            } else { j = j + 9}                                 // Sigo buscando hacia abajo
        }
        return                                                  // No hemos encontrado pareja para este "i", continuamos
    }
    func encontradaPareja(etiqueta: Int, i: Int, j: Int) {
        grupo.removeAll()
        grupo.append(etiqueta)
        grupo.append(i)
        grupo.append(j)
        grupo.append(0)
        gruposEtiqueta.append(grupo)
    }
    func reordenarGrupos() {
        gruposEtiquetaOrdenados.removeAll()
        if gruposEtiqueta.count > 0 {   // Hay grupos, si no hay lo dejamos vacío
            for i in 1 ... 5 {
                for j in 0 ... gruposEtiqueta.count - 1 {
                    if gruposEtiqueta[j][0] == i {
                        gruposEtiquetaOrdenados.append(gruposEtiqueta[j])
                    }
                }
            }
        }
        
        //       print("Grupos de Etiqueta Ordenados")
        //       print(gruposEtiquetaOrdenados)
    }
    func hacerReGrupos () {
        reGrupos.removeAll()
        if gruposEtiquetaOrdenados.count > 0 {
            for l in 0 ... gruposEtiquetaOrdenados.count - 1 {
                //        print("l = \(l)")
                if gruposEtiquetaOrdenados[l][3] == 0 {
                    gruposEtiquetaOrdenados[l][3] = 2            // Marco la tupla para no volverla a usar
                    reCola.removeAll()
                    cola.removeAll()
                    k = gruposEtiquetaOrdenados[l][0]
                    reCola.append(k)
                    reCola.append(gruposEtiquetaOrdenados[l][1])
                    reCola.append(gruposEtiquetaOrdenados[l][2])
                    cola.append(gruposEtiquetaOrdenados[l][1])
                    cola.append(gruposEtiquetaOrdenados[l][2])
                    while cola.count > 0 {
                        buscarMas(k: k, i: cola[0])
                    }
                    reGrupos.append(reCola)
                }
            }
        }
    }
    func buscarMas(k: Int, i: Int) {
        for m in 0 ... gruposEtiquetaOrdenados.count - 1 {
            if gruposEtiquetaOrdenados[m][0] == k && gruposEtiquetaOrdenados[m][3] == 0 {   // Encontrado uno que puede seguir
                if gruposEtiquetaOrdenados[m][1] == i {
                    cola.append(gruposEtiquetaOrdenados[m][2])
                    reCola.append(gruposEtiquetaOrdenados[m][2])
                    gruposEtiquetaOrdenados[m][3] = 1           // Marco la tupla como usada pero de rebote
                } else {
                    if gruposEtiquetaOrdenados[m][2] == i {
                        cola.append(gruposEtiquetaOrdenados[m][1])
                        reCola.append(gruposEtiquetaOrdenados[m][1])
                        gruposEtiquetaOrdenados[m][3] = 1           // Marco la tupla como usada pero de rebote
                    }
                }
            }
        }
        cola.remove(at: 0)
    }
    func limpiarReGrupos(reGrupoALimpiar: [[Int]]) -> [[Int]]{
        /*
         reGrupos [0] = estado del reGrupo (0 = sin usar para cálculo, 1 = usado, 2 = elegido)
         reGrupos [1] = k (valor de la celda: de 1 a 5 o 0)
         reGrupos [2 ... n + 1] = índice de las celdas implicadas en este grupo
         reGrupos [n + 3] = n (número de Celdas del grupo)
         */
        reGruposOrdenados.removeAll()
        valorParcialGrupos = 0
        for i in 0 ... reGrupoALimpiar.count - 1 {
            grupo.removeAll()
            gruposA.removeAll()
            gruposA.append(0)                       // reGrupos [0] = estado del reGrupos (0 = sin usar para cálculo)
            gruposA.append(reGrupoALimpiar[i][0])          // reGrupos [1] = k (valor de la celda: de 1 a 5 o 0)
            for j in 1 ... reGrupoALimpiar[i].count - 1 {
                grupo.append(reGrupoALimpiar[i][j])         // añado a grupo todos los índices
            }
            grupo = grupo.sorted()                          // ordeno lo índices
            gruposA.append(grupo[0])                // guardo el primer índice (el menor por estar ordenado)
            n = 1                                   // como ya he guardado el primer índice pongo el contador a 1
            for m in 1 ... grupo.count - 1 {
                if grupo[m] != grupo[m - 1] {
                    gruposA.append(grupo[m])        // Es un índice distinto que el anterior lo guardo
                    n = n + 1                       // y sumo 1 al número de índices distintos
                }
            }
            let paresInterRegrupos = Int(n / 2)
            valorParcialGrupos = valorParcialGrupos + paresInterRegrupos + (paresInterRegrupos - 1) * 2
            gruposA.append(n)                       // reGrupos [last] = n (número de Celdas del grupo)
            reGruposOrdenados.append(gruposA)
        }
        //    reGrupos = reGruposOrdenados                // pongo en reGrupos ya ordenado e inicializado
        return reGruposOrdenados
    }
    
    func pintarMatrixOrdGrupos(matrizPintar: [Int]) {
        print("******* Pintar Tabla MAtrix Ord:")
        let filas = Int(matrizPintar.count / 9)
        for i in 0 ... filas - 1{
            filaMatriz.removeAll()
            for j in 0 ... 8 {
                filaMatriz.append(matrizPintar[(i * 9) + j])
            }
            print(filaMatriz)
        }
        if numCasillas > filas * 9 {
            filaMatriz.removeAll()
            for i in filas * 9 ... matrizPintar.count - 1 {
                filaMatriz.append(matrizPintar[i])
            }
            print(filaMatriz)
        }
        
    }
    func esPar (numCeldas: Int) -> Bool {
        if numCeldas % 2 == 0 {
            return true
        } else {
            return false
        }
    }
    func estaEnMatriz (matriz: [Int], numero: Int) -> Bool {
        for i in 0 ... matriz.count - 1 {
            if numero == matriz[i] {
                return true
            }
        }
        return false
    }
    
    func hayRepetidosCaminos(prueba: [Int]) -> Bool {
        for i in 2...prueba.count - 2 {
            repetidos = 0
            let ii = prueba[i]
            for j in 2...prueba.count - 2 {
                if ii == prueba[j] {
                    repetidos = repetidos + 1
                }
            }
            if repetidos > 1 {
                print("repetido: \(ii) en: \(prueba)veces: \(repetidos) DESECHADO")
                return true
            }
        }
        return false
    }
    // Funciones para Buscar el camino de un grupo
    // Funciones para buscar el camino de Pares óptimo del Grupo
    // caminosJugada[[0,k, i, j,..., n]] -> 0 = estado, k = etiqueta, índices(*), n = número de Celdas del camino
    func seleccionarIndices(grupoBuscar: [Int]) -> [Int]{
        indicesAOrdenar.removeAll()
        indicesSinUsar.removeAll()
        for i in 2 ... grupoBuscar.count - 2 {
            indicesAOrdenar.append(grupoBuscar[i])                 // ya tengo en indicesAOrdenar los índices
        }
        indicesAOrdenar = indicesAOrdenar.sorted()                  // Los ordeno para que la búsqueda sea más eficiente (lo dudo, pero...)
        return indicesAOrdenar
    }
    func buscarCamino(matrixBuscar: [Int], grupoBuscar: [Int]) -> [[Int]]{    // Recibo matrix y el grupo para buscar el camino
        indicesAOrdenar = seleccionarIndices(grupoBuscar: grupoBuscar)
        numIndGrupo = indicesAOrdenar.count
        indicesSinUsar.removeAll()
        indicesUsados.removeAll()
        mayorCamino.removeAll()
        k = grupoBuscar[1]
        // ************ Ojo: ¿es útil la Valencia? antes hacía: indicesAOrdenar = indicesAOrdenar.sorted()
        indicesAOrdenar = calcularValencias(grupoValencia: grupoBuscar, matrixCadena: matrixBuscar, etiqueta: k)
        numIndGrupo = indicesAOrdenar.count
        finalCadena = false
        mayorNivel = 0
        // De uno en uno los pongo como inicio de un camino y proceso ese caminosPosibles
        // La primera vez cargo en indicesUsados el primer índice (acabo de usarlo)
        // También creo el primer caminosPosibles con el estado 0, la etiqueta k y el primer índice
        vueltasIndice = 0
        vueltasPar = 0
        vueltasImpar = 0
        vueltasCaminosPosibles = 0
        vueltasCaminoJugadas = 0
        for i in 0 ... indicesAOrdenar.count - 1 {
            if finalCadena == false {
                vueltasIndice = vueltasIndice + 1
                matrixJugada = matrixBuscar
                indicesSinUsar = indicesAOrdenar
                indicesUsados.removeAll()
                caminosJugada.removeAll()
                caminosPosibles.removeAll()
                caminoInter.removeAll()
                caminoInter.append(0)                       // Cargo el estado = 0
                caminoInter.append(grupoBuscar[1])          // Cargo la etiqueta = k
                caminoInter.append(indicesAOrdenar[i])      // Cargo el primer índice del nuevo Camino
                caminosPosibles.append(caminoInter)
                primerEslabon = indicesAOrdenar[i]          // Guardo el primer índcie (por si acaso: revisar)
                indicesUsados.append(indicesAOrdenar[i])    // Pongo en indicesUsados el primero de la cadena indicesAOrdenar[i]
                vueltasCaminosPosibles = 0
                while caminosPosibles.count > 0 {
                    // proceso todos los caminosPosibles
                    // Antes voy a poner un límite a los cálculos y cogeré el camino PAR mayor para procesarlo
                    vueltasCaminosPosibles = vueltasCaminosPosibles + 1
                    if vueltasCaminosPosibles > 1000 || caminosPosibles.count > 2500{
     //                   print("Vueltas: \(vueltasCaminosPosibles) Caminos Posibles \(caminosPosibles.count)")
                        for m in 0...caminosPosibles.count - 1 {
                            if esPar(numCeldas: caminosPosibles[m].count - 2) {
                                caminosPosibles[m].append(caminosPosibles[m].count - 2)
                                caminosPosibles[m][0] = 1
                            } else {
                                caminosPosibles[m].remove(at: caminosPosibles[m].count - 1)
                                caminosPosibles[m].append(caminosPosibles[m].count - 2)
                                caminosPosibles[m][0] = 1
                            }
                        }
                        caminoMayorJugada = elegirMayorCamino(caminos: caminosPosibles)
     //                   print("Grupo: \(grupoBuscar)")
     //                   print("Mayor Jugada: \(caminoMayorJugada.count)")
                        return caminoMayorJugada
                    }
                    //                    caminoInter = caminosPosibles[0]        // Cargo el primer caminoPosible en caminoInter
                    // Ojo: elegir el caminosPosibles mayor
                    mayorCaminosPosibles.removeAll()
                    for s in 0...caminosPosibles.count - 1 {
                        if caminosPosibles[s].count > mayorCaminosPosibles.count {
                            mayorCaminosPosibles = caminosPosibles[s]
                            mayorIndiceCaminosPosibles = s
                        }
                    }
                    caminoInter = mayorCaminosPosibles        // Cargo el mayor caminoPosible en caminoInter
                    // Mientras este caminoInter no llegue a su fin continuamos con él para bingo
                    while caminoInter.count > 0 {
                        // Actualizo los índicesUsados
                        indicesUsados.removeAll()
                        for h in 2...caminoInter.count - 1 {
                            indicesUsados.append(caminoInter[h])
                        }
                        // Tratamiento diferente si es IMPAR hay una Celda que necesita PAREJA
                        if esPar(numCeldas: caminoInter.count - 2) == false {
                            // Tenemos un nº IMPAR de Celdas en el Camino (puede ser la primera)
                            // Y tenemos en caminoInter la última Celda que necesita pareja sí o sí
                            // Le buscamos pareja -> buscarSegundo
                            posibles.removeAll()
                            buscarSegundos(matrixSegundo: matrixJugada, primero: caminoInter.last!, indicesSegundo: indicesUsados)
                            // Me devuelve las Celdas que hacen PAREJA con la Celda IMPAR en posibles
                            // Voy a hacer el tratamiento de posibles por separado según sea PAR o IMPAR
                            if posibles.count > 0 {                         // SÍ hay una Celda que hace PAREJA o CONTINUA, ampliamos caminoInter y creamos + caminosPosibles
                                caminoInter2 = caminoInter                  // Antes guardamos la cadena actual (caminoInter) para añadirle los otros posibles
                                caminoInter.append(posibles[0])             // Añadimos a caminoInter el nuevo medio eslabón
                                indicesUsados.append(posibles[0])           // incluimos el nuevo índice a indicesUsados  ????
                                if posibles.count > 1 {                     // Ya he utilizado el posibles[0]
                                    for m in 1 ... posibles.count - 1 {     // Evitamos el primer posible ya que está en caminoInter
                                        caminoInter2.append(posibles[m])
                                        // Antes compruebo que NO ESTÉ YA en caminosPosibles
                                        caminoExiste = false
                                        for h in 0...caminosPosibles.count - 1 {
                                            if caminoInter2 == caminosPosibles[h] {
                                                caminoExiste = true
                                            }
                                        }
                                        if caminoExiste == false && caminoInter2.count < grupoBuscar.count - 2  {
                                            // Ya he encontrado una cadena máxima
                                            caminosPosibles.append(caminoInter2)    // Creo los nuevos caminosPosibles
                                        }
                                    }
                                }
                            } else {                                                // Final de la cadena caminoInter
                                // Al ser IMPAR le borro la última celda que ya que no tiene pareja
                                // A NO SER que sea la primera Celda que borro el caminoInter y caminosPosibles[0]
                                if caminoInter.count < 5 {
                                    print("CaminoInter corto e impar: \(caminoInter)")
                                    caminosPosibles.remove(at: mayorIndiceCaminosPosibles)    // Borro el caminoPosible ya que solo tiene una Celda
                                } else {
                                    caminoInter.remove(at: caminoInter.count - 1)
                                    caminoInter.append(caminoInter.count - 2)   // Añadimos el número de índices del camino
                                    caminoInter[0] = 1                          // Camino cerrado
                                    // El caminoInter tiene al menos una PAREJA, la guardamos en caminosJugada
                                    // Antes compruebo que NO ESTÉ ya en caminosPosibles
                                    if mayorCamino.count < caminoInter.count {
                                        mayorCamino = caminoInter
                                    }
                                    if caminosJugada.count > 0 {
                                        // Ya hay caminosJugada
                                        caminoExiste = false
                                        for h in 0...caminosJugada.count - 1 {
                                            if caminoInter == caminosJugada[h] {
                                                caminoExiste = true
                                            }
                                        }
                                    } else {
                                        // Es el primer caminosJugada
                                        caminoExiste = false
                                    }
                                    if caminoExiste == false {
                                        // Punto de comprobación de índices repetidos
                                        if hayRepetidosCaminos(prueba: caminoInter) == false {
                                            // Vamos a ver si es mayor que los anteriores, si es menor no lo guardo
                                            if caminoInter.count > mayorNivel {
                                                caminosJugada.append(caminoInter)          // Creo el camino finalizado. Inicializo y vuelvo a...
                                                mayorNivel = caminoInter.count
                                            }
                                        }
                                    }
                                    // Ahora compruebo si he utilizado el máximo posible de Celdas
                                    maximaJugada()
                                }
                                caminoInter.removeAll()                     // Limpio el caminoInter para volver a coger el siguiente caminoPosible
                            }
                        } else {
                            // Al ser PAR hay que buscar entre las Celdas ya usadas las posibles Celdas que continuen la cadena
                            // Ya tenemos al menos un nº PAR de Celdas en el Camino
                            // Tenemos que buscar entre los indicesUsados todas las posibles Celdas que continuen la cadena
                            posibles.removeAll()
                            buscarPrimeros(matrixPrimero: matrixJugada, indicesPrimero: indicesUsados)
                            // Me devuelve las Celdas que continúan la cadena si las hay, en posibles
                            // Ahora procesamos las Celdas de posibles
                            if posibles.count > 0 {             // SÍ hay una Celda que CONTINUA, ampliamos caminoInter y creamos + caminosPosibles
                                caminoInter2 = caminoInter      // Antes guardamos la cadena actual (caminoInter) para añadirle los otros posibles
                                caminoInter.append(posibles[0])             // Añadimos a caminoInter el nuevo medio eslabón
                                indicesUsados.append(posibles[0])           // incluimos el nuevo índice a indicesUsados  ????
                                if posibles.count > 1 {                     // Ya he utilizado el posibles[0]
                                    for m in 1 ... posibles.count - 1 {         // Evitamos el primer posible ya que está en caminoInter
                                        caminoInter2.append(posibles[m])
                                        // Antes compruebo que NO ESTÉ ya en caminosPosibles
                                        for h in 0...caminosPosibles.count - 1 {
                                            if caminoInter2 == caminosPosibles[h] {
                                                caminoExiste = true
                                            }
                                        }
                                        if caminoExiste == false && caminoInter2.count < grupoBuscar.count - 2  {
                                            // Comprobar que no tiene más celdas que la cuenta < caminoInter2.count - 2
                                            caminosPosibles.append(caminoInter2)    // Creo los nuevos caminosPosibles
                                        }
                                    }
                                }
                            } else {                                        // Final de la cadena caminoInter
                                // Recordemos que tenemos un nº PAR de Celdas y que no le sigue ninguna
                                caminoInter.append(caminoInter.count - 2)   // Añadimos el número de índices del camino
                                caminoInter[0] = 1                          // Camino cerrado
                                // Como caminoInter tiene al menos una PAREJA la guardamos en caminosJugada
                                // Antes compruebo que NO ESTÉ ya en caminosPosibles
                                if mayorCamino.count < caminoInter.count {
                                    mayorCamino = caminoInter
                                }
                                if caminosJugada.count > 0 {
                                    // Ya hay caminosJugada
                                    caminoExiste = false
                                    for h in 0...caminosJugada.count - 1 {
                                        if caminoInter == caminosJugada[h] {
                                            caminoExiste = true
                                        }
                                    }
                                } else {
                                    // Es el primer caminosJugada
                                    caminoExiste = false
                                }
                                if caminoExiste == false {
                                    // Punto de comprobación de índices repetidos
                                    if hayRepetidosCaminos(prueba: caminoInter) == false {
                                        // Vamos a ver si es mayor que los anteriores, si es menor no lo guardo
                                        if caminoInter.count > mayorNivel {
                                            mayorNivel = caminoInter.count
                                            caminosJugada.append(caminoInter)           // Creo el camino finalizado. Inicializo y vuelvo a...
                                        }
                                    }
                                }
                                // Ahora compruebo si he utilizado el máximo posible de Celdas
                                if caminoInter.count > 4 {
                                    maximaJugada()
                                } else {
                                    print("CaminoInter corto y par: \(caminoInter)")
                                }
                                caminoInter.removeAll()                // Limpio el caminoInter para volver a coger el siguiente caminoPosible
                            }
                        }
                    }
                }
                // Vuelvo a por el índice siguiente
            }
        }
        // Acaba el GRUPO. Voy a generar el mayor camino
        caminoMayorJugada.removeAll()
        if caminosJugada.count > 0 {
            caminoMayorJugada = elegirMayorCamino(caminos: caminosJugada)
        } else {
            // No hemos encontrado el camino MÁXIMO -> elegimos el camino MAYOR
            caminosJugada.append(mayorCamino)
            caminoMayorJugada = elegirMayorCamino(caminos: caminosJugada)
        }
        return caminoMayorJugada                // Aquí es donde devuelvo la jugada MAYOR
    }
    func elegirMayorCamino(caminos: [[Int]]) -> [[Int]]{
        // Devuelve -> caminoMayorJugada
        // De los caminos recibidos elegimos el mayor
        mayorN = 0
        for i in 0...caminos.count - 1 {
            if caminos[i].last! > mayorN {
                caminoInter = caminos[i]
                mayorN = caminos[i].last!
            }
        }
        // Quito el número de Celdas, el estado [0] y la etiqueta [1]
        caminoInter.remove(at: caminoInter.count - 1)
        caminoInter.remove(at: 0)
        caminoInter.remove(at: 0)
        // Ahora agrupo las Celdas en orden y de 2 en 2 para enviar los PARES ORDENADOS
        let numeroDePares = caminoInter.count / 2
        caminoMayorJugada.removeAll()
        for m in 0...numeroDePares - 1 {
            caminoInter2.removeAll()
            caminoInter2.append(caminoInter[2 * m])
            caminoInter2.append(caminoInter[2 * m + 1])
            caminoMayorJugada.append(caminoInter2)
        }
        return caminoMayorJugada
    }
    func maximaJugada() {
        // Ahora compruebo si he utilizado el máximo posible de Celdas
        if (caminoInter.count - 3) == numIndGrupo && esPar(numCeldas: numIndGrupo){
            finalCadena = true
            caminosPosibles.removeAll()
        } else {
            if (caminoInter.count - 3) == (numIndGrupo - 1) && esPar(numCeldas: numIndGrupo) == false {
                caminosPosibles.removeAll()
                finalCadena = true
            } else {
                caminosPosibles.remove(at: mayorIndiceCaminosPosibles)               // Borro el caminoPosible que ya he cerrado
            }
        }
    }
    func buscarPrimeros(matrixPrimero: [Int], indicesPrimero: [Int]) {
        // Con los indicesUsados hay que buscar las Celdas que continúen la cadena
        // Primero preparo matrixPrimero borrando las Celdas indicesUsados y cogiendo la etiqueta
        matrixTrabajo = matrixPrimero
        for h in 0 ... indicesPrimero.count - 1 {
            matrixTrabajo[indicesPrimero[h]] = 0
        }
        // Para cada índice ya usado le busco las posibles Celdas que continuen la Cadena
        for l in 0 ... indicesPrimero.count - 1 {
            buscarCadena(matrixCadena: matrixTrabajo, etiqueta: k, i: indicesPrimero[l])
        }
    }
    func buscarSegundos(matrixSegundo: [Int], primero: Int, indicesSegundo: [Int]) {
        // Tengo que buscar las Celdas que hagan PAREJA con la i que me envían (la que necesita una PAREJA)
        // Primero preparo matrixPrimero borrando las Celdas indicesUsados y cogiendo la etiqueta
        matrixTrabajo = matrixSegundo
        for h in 0 ... indicesSegundo.count - 1 {
            matrixTrabajo[indicesSegundo[h]] = 0
        }
        buscarCadena(matrixCadena: matrixTrabajo, etiqueta: k, i: primero)
    }
    // Búsqueda de Parejas
    func buscarCadena (matrixCadena: [Int], etiqueta: Int, i: Int) {
        // Tengo matrixCadena preparada con los blancos jugados, la etiqueta y la Celda primera
        // Tengo que buscar la primera pareja y la devuelvo en posibles
        buscarAdelanteCadena(matrixCadena: matrixTrabajo, etiqueta: etiqueta, i: i)
        buscarAtrasCadena(matrixCadena: matrixTrabajo, etiqueta: etiqueta, i: i)
        buscarArribaCadena(matrixCadena: matrixTrabajo, etiqueta: etiqueta, i: i)
        buscarAbajoCadena(matrixCadena: matrixTrabajo, etiqueta: etiqueta, i: i)
    }
    func buscarAdelanteCadena (matrixCadena: [Int], etiqueta: Int, i: Int) {
        if i == matrixCadena.count - 1 {return}
        for j in i + 1 ... numCasillas - 1 {          // Bucle hacia adelante desde la casilla siguiente a la recibida hasta el final de la tabla
            if matrixCadena [j] != 0 {
                if matrixCadena [j] == etiqueta {
                    if posibles.count > 1 {
                        if estaEnMatriz(matriz: posibles, numero: j) {
                            return
                        } else {
                            posibles.append(j)
                            return
                        }
                    } else {
                        posibles.append(j)
                        return
                    }
                } else {
                    return                                      // No hemos encontrado pareja para este "i", continuamos
                }
            }
        }
    }
    func buscarAtrasCadena (matrixCadena: [Int], etiqueta: Int, i: Int) {
        j = i - 1
        if j < 0 {return}         // Estamos en la primera Celda y no podemos ir hacia atrás. No hemos encontrado pareja con ese i, continuamos
        while j > 0 {
            if matrixCadena [j] != 0 {
                if  matrixCadena [j] == etiqueta {
                    if posibles.count > 1 {
                        if estaEnMatriz(matriz: posibles, numero: j) {
                            return
                        } else {
                            posibles.append(j)
                            return
                        }
                    } else {
                        posibles.append(j)
                        return
                    }
                } else {
                    return                                      // No hemos encontrado pareja para este "i", continuamos
                }
            } else { j = j - 1}                                 // Sigo buscando hacia atrás
        }
        return
    }
    func buscarAbajoCadena (matrixCadena: [Int], etiqueta: Int, i: Int) {
        j = i + 9
        if j > matrixCadena.count - 1 {return}         // Última fila y no podemos ir hacia abajo. No hay pareja para ese i, continuamos
        while j < matrixCadena.count - 1 {
            if matrixCadena [j] != 0 {
                if  matrixCadena [j] == etiqueta {
                    if posibles.count > 1 {
                        if estaEnMatriz(matriz: posibles, numero: j) {
                            return
                        } else {
                            posibles.append(j)
                            return
                        }
                    } else {
                        posibles.append(j)
                        return
                    }
                } else {
                    return                                      // No hemos encontrado pareja para este "i", continuamos
                }
            } else { j = j + 9}                                 // Sigo buscando hacia abajo
        }
        return                                                  // No hemos encontrado pareja para este "i", continuamos
    }
    func buscarArribaCadena (matrixCadena: [Int], etiqueta: Int, i: Int) {
        j = i - 9
        if j < 0 {return}                               // Primera fila y no podemos ir hacia arriba. No hay pareja para ese i, continuamos
        while j > 0 {
            if matrixCadena [j] != 0 {
                if  matrixCadena [j] == etiqueta {
                    if posibles.count > 1 {
                        if estaEnMatriz(matriz: posibles, numero: j) {
                            return
                        } else {
                            posibles.append(j)
                            return
                        }
                    } else {
                        posibles.append(j)
                        return
                    }
                } else {
                    return                                      // No hemos encontrado pareja para este "i", continuamos
                }
            } else { j = j - 9}                                 // Sigo buscando hacia abajo
        }
        return                                                  // No hemos encontrado pareja para este "i", continuamos
    }
    
    
    
    // Funciones de Líneas a ceros
    func buscarFilasBlancoOrdenadorN1 (matrizFilasBlanco: [Int]) -> Int64 {
        let numFilasMatriz = (matrizFilasBlanco.count / 9) - 1
        cuentaFilasBlancoOrdenador = 0
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
                cuentaFilasBlancoOrdenador = cuentaFilasBlancoOrdenador + 1
            }
        }
        return cuentaFilasBlancoOrdenador
    }
    
    // **********************
    
    // Funciones de VALENCIA        ************ Ojo: ¿es útil?
    // Vamos a asignar a cada índice/celda el número de posibles parejas
    // Es decir: contamos no solo las celdas inmediatamente PAREJA de una dada
    // sino que contamos también las celdas que detrás de las anteriores hacen PAREJA quitamos la celda ya PAREJA
    
    func calcularValencias(grupoValencia: [Int], matrixCadena: [Int], etiqueta: Int) -> [Int] {
        indicesValencias.removeAll()
        valencias.removeAll()
        indicesAOrdenar = seleccionarIndices(grupoBuscar: grupoValencia)
        for i in 0...indicesAOrdenar.count - 1 {
            valenciaIndiceActual = 0
            buscarAdelanteValencia(matrixCadena: matrixCadena, etiqueta: etiqueta, i: indicesAOrdenar[i])
            buscarAtrasValencia(matrixCadena: matrixCadena, etiqueta: etiqueta, i: indicesAOrdenar[i])
            buscarAbajoValencia(matrixCadena: matrixCadena, etiqueta: etiqueta, i: indicesAOrdenar[i])
            buscarArribaValencia(matrixCadena: matrixCadena, etiqueta: etiqueta, i: indicesAOrdenar[i])
            valencias.append([indicesAOrdenar[i], valenciaIndiceActual])
        }
        for i in 0...valencias.count - 1{
            if valencias[i][1] == 1 {
                indicesValencias.append(valencias[i][0])
            }
        }
        // Ya tengo en primer lugar de indicesValencia las Celdas de VALENCIA = 1
        // Le añado las demás
        if indicesValencias.count > 0 {
            for i in 0...indicesAOrdenar.count - 1 {
                if estaEnMatriz(matriz: indicesValencias, numero: indicesAOrdenar[i]) == false {
                    indicesValencias.append(indicesAOrdenar[i])
                }
            }
        } else {
            indicesValencias = indicesAOrdenar
        }
        return indicesValencias
    }
    func buscarAdelanteValencia (matrixCadena: [Int], etiqueta: Int, i: Int) {
        if i == matrixCadena.count - 1 {return}
        for j in i + 1 ... numCasillas - 1 {          // Bucle hacia adelante desde la casilla siguiente a la recibida hasta el final de la tabla
            if matrixCadena [j] != 0 {
                if matrixCadena [j] == etiqueta {
                    valenciaIndiceActual = valenciaIndiceActual + 1
                } else {
                    return                                      // No hemos encontrado pareja para este "i", continuamos o se ha acabado la cadena de etiqueta
                }
            }
        }
    }
    func buscarAtrasValencia (matrixCadena: [Int], etiqueta: Int, i: Int) {
        j = i - 1
        if j < 0 {return}         // Estamos en la primera Celda y no podemos ir hacia atrás. No hemos encontrado pareja con ese i, continuamos
        while j > 0 {
            if matrixCadena [j] != 0 {
                if  matrixCadena [j] == etiqueta {
                    valenciaIndiceActual = valenciaIndiceActual + 1
                    j = j - 1
                } else {
                    return                                      // No hemos encontrado pareja para este "i", continuamos
                }
            } else { j = j - 1}                                 // Sigo buscando hacia atrás
        }
        return
    }
    func buscarAbajoValencia (matrixCadena: [Int], etiqueta: Int, i: Int) {
        j = i + 9
        //   print("buscar Abajo 1: \(etiqueta) \(i)")
        if j > matrixCadena.count - 1 {return}         // Estamos en la última fila y no podemos ir hacia abajo. No hemos encontrado pareja con ese i, continuamos
        while j < matrixCadena.count - 1 {
            if matrixCadena [j] != 0 {
                if  matrixCadena [j] == etiqueta {
                    valenciaIndiceActual = valenciaIndiceActual + 1
                    j = j + 9
                } else {
                    return                                      // No hemos encontrado pareja para este "i", continuamos
                }
            } else { j = j + 9}                                 // Sigo buscando hacia abajo
        }
        return                                                  // No hemos encontrado pareja para este "i", continuamos
    }
    func buscarArribaValencia (matrixCadena: [Int], etiqueta: Int, i: Int) {
        j = i - 9
        //   print("buscar Arriba 1: \(etiqueta) \(i)")
        if j < 0 {return}                               // Estamos en la primera fila y no podemos ir hacia arriba. No hemos encontrado pareja con ese i, continuamos
        while j > 0 {
            if matrixCadena [j] != 0 {
                if  matrixCadena [j] == etiqueta {
                    valenciaIndiceActual = valenciaIndiceActual + 1
                    j = j - 9
                } else {
                    return                                      // No hemos encontrado pareja para este "i", continuamos
                }
            } else { j = j - 9}                                 // Sigo buscando hacia abajo
        }
        return                                                  // No hemos encontrado pareja para este "i", continuamos
    }
    
    // Variables del Ordenador Nivel1
    // Variables de Cálculo de Ordenador Nivel1
    var matrixGrupos: [Int] = [Int]()
    var matrixTrabajoGrupos: [Int] = [Int]()
    var gruposEtiqueta: [[Int]] = [[Int]]()
    var gruposEtiquetaOrdenados: [[Int]] = [[Int]]()
    var gruposA: [Int] = [Int]()
    var gruposPar: [Int] = [Int]()
    var gruposImpar: [Int] = [Int]()
    var indicesPar: [Int] = [Int]()
    var indicesImpar: [Int] = [Int]()
    var gruposParMenor: Int = 0
    var gruposImparMenor: Int = 0
    var indiceParMenor: Int = 0
    var indiceImparMenor: Int = 0
    /*
     reGrupos [0] = estado del reGrupo (0 = sin usar para cálculo, 1 = usado, 2 = elegido)
     reGrupos [1] = k (valor de la celda: de 1 a 5 o 0)
     reGrupos [2 ... n + 1] = índice de las celdas implicadas en este grupo
     reGrupos [n + 3] = n (número de Celdas del grupo)
     */
    var reGrupos: [[Int]] = [[Int]]()
    var reGruposTrabajo: [[Int]] = [[Int]]()
    var reGruposFinal: [[Int]] = [[Int]]()
    var reGruposOrdenados: [[Int]] = [[Int]]()
    var reGruposEtiqueta: [[Int]] = [[Int]]()
    var reGruposEtiquetaOrdenados: [[Int]] = [[Int]]()
    var gruposEtiquetaOrdenados2: [[Int]] = [[Int]]()
    var grupo: [Int] = [Int]()
    var cola: [Int] = [Int]()
    var reCola: [Int] = [Int]()
    var puntosRegrupos: Int = 0
//    var valorGrupos: Int = 0
    var valorParcialGrupos: Int = 0
    var valorTotalGrupos: Int = 0
    var valorPar: Int64 = 0
    var valorParTotal: Int64 = 0
    var numParesOrdenador: Int64 = 0
    var valoresUsados: [Int] = [Int]()
    var vecesGrupos: [Int] = [Int]()
 //   var vueltas: Int = 0
    var ordGruposPuntos: Int64 = 0
    var ordGruposFilas: Int64 = 0
    var ordGruposPares: Int64 = 0
    var matrixOrdCalculo: [Int] = [Int]()
    var matrixOrdGrupos: [Int] = [Int]()
    var matrixOrdGruposInter: [Int] = [Int]()
    var matrixOrdenador: [String] = [String]()
    var ordenEtiquetas: [Int] = [Int]()
    var ordenEtiquetasOriginal: [Int] = [Int]()
    var filaMatriz: [Int] = [Int]()
    var primeraVez: Bool = true
    var finalTabla: Bool = false
    var finReGrupos: Bool = false
    var lineasBlancoOrdenador: Int = 0
    
    // Variables para Buscar el Camino
    var indicesAOrdenar: [Int] = [Int]()
    var indicesSinUsar: [Int] = [Int]()
    var indicesUsados: [Int] = [Int]()
    var matrixJugada: [Int] = [Int]()
    var matrixTrabajo: [Int] = [Int]()
    var caminosJugada: [[Int]] = [[Int]]()
    var caminoMayorJugada: [[Int]] = [[Int]]()      // Conjunto de PARES de Celdas Ordenados para el Camino Máximo
    var caminosTotalOrdenador: [[[Int]]] = [[[Int]]]()  // Conjunto de las JUGADAS (Conjunto de PARES Ordenados)
    var caminosJugadaOrdenador: [[[Int]]] = [[[Int]]]()  // Conjunto de las JUGADAS (Conjunto de PARES Ordenados)
    var caminosPartida: [[Int]] = [[Int]]()
    var caminoInter: [Int] = [Int]()
    var caminoInter2: [Int] = [Int]()
    var caminosPosibles: [[Int]] = [[Int]]()
    var posibles: [Int] = [Int]()
    var posiblesInter: [Int] = [Int]()
    var cadena: [Int] = [Int]()
    var numIndGrupo: Int = 0
    var mayorN: Int = 0
    var caminoExiste: Bool = false
    var cadenaPendiente: [Int] = [Int]()
    var mayorCamino: [Int] = [Int]()
    var primerEslabon: Int = 0
    var ultimoEslabon: Int = 0
    var mayorNivel: Int = 0
    var finalCadena: Bool = false
    var repetidos: Int = 0
    var mayorIndiceCaminosPosibles: Int = 0
    var mayorCaminosPosibles: [Int] = [Int]()
    
    // Variables de control
    var vueltasIndice: Int = 0
    var vueltasCaminosPosibles: Int = 0
    var vueltasCaminoJugadas: Int = 0
    var vueltasPar: Int = 0
    var vueltasImpar: Int = 0
    
    // Variables de VALENCIAS
    var valencias: [[Int]] = [[Int]]()
    var indicesValencias: [Int] = [Int]()
    var valenciaIndiceActual: Int = 0
    
    var valorPruebaReGrupos: [Int] = [Int]()
    var gruposPruebaReGrupos: [[Int]] = [[Int]]()
    var matrixCandidato: [Int] = [Int]()
    var grupoCandidato: [Int] = [Int]()
    var valorReGrupo: Int = 0
    var valorCandidato: Int = 0
    var reGrupoDelCandidato: [[Int]] = [[Int]]()
    var matrixPruebas: [Int] = [Int]()
    var matrixOriginal: [Int] = [Int]()
    var paresAValorar: Int = 0
    
    var cuentaFilasBlancoOrdenador: Int64 = 0
    var cerosEnFila: Int = 0

}
