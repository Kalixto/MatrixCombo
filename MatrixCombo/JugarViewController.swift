//
//  JugarViewController.swift
//  MatrixCombo
//
//  Created by Edu Ardo on 12/3/18.
//  Copyright © 2018 neteamador. All rights reserved.
//

import UIKit
import CoreData

class JugarViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {

    // Variables de inicio y de CoreData
    let imageData = [" ", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    var colorElegido: UIColor = UIColor()
    let color1 = UIColor(displayP3Red: 0.952, green: 0.882, blue: 0.878, alpha: 0.7)
    let color2 = UIColor(displayP3Red: 0.956, green: 0.925, blue: 0.741, alpha: 0.7)
    let color3 = UIColor(displayP3Red: 0.666, green: 0.949, blue: 0.654, alpha: 0.7)
    let color4 = UIColor(displayP3Red: 0.635, green: 0.858, blue: 0.937, alpha: 0.7)
    let color5 = UIColor(displayP3Red: 0.964, green: 0.725, blue: 0.917, alpha: 0.7)
    let color6 = UIColor(displayP3Red: 0.478, green: 0.988, blue: 0.988, alpha: 0.7)
    var partidaSeleccionada: Partidas!
    var jugadorSeleccionado: Jugadores!
    var matrizCreada: Matrices!
    //    var matrizUsada: Matrices!
    var celdaCreada: Celdas!
    var logPartidaMatriz: LogMatriz!
    var codigoMatrizUsada: Int32 = 0
    var idMatrizUsada: Int32 = 0
    var puntosAntes: Int64 = 0
    
    var partidaCreada: Partidas!
    
    // Variable y función de CoreData
    var contexto: NSManagedObjectContext!
    func conexion() -> NSManagedObjectContext {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    // Funciones del sistema
    override func viewDidLoad() {
        super.viewDidLoad()
        matrixCollectionView2.delegate = self
        matrixCollectionView2.dataSource = self
        // Me pasan"partidaSeleccionada", compruebo si es una Partida nueva y hay que inicializar el idmatriz
        if primeraVezPartida() {
            // Esto es inútil tengo que cambiar la pregunta
            // Borro logJuego
            logJuego.removeAll()
            indiceLog = 0
            // Es una partida nueva, ya he creado la Matriz, las Celdas y la matrix
            // Inútil no uso codigoMatrizUsada ni idMatrizUsada
            codigoMatrizUsada = codigoMatrizCreada
            idMatrizUsada = idMatrizCreada
        } else {
            // Leo la Matriz correspondiente con estado < 2
            let contexto2 = conexion()
            let peticion = NSFetchRequest<Matrices>(entityName: "Matrices")
            let orderByCodigoMatriz = NSSortDescriptor(key: "codigoMatriz", ascending: false)
            peticion.sortDescriptors = [orderByCodigoMatriz]
            peticion.fetchLimit = 1
            let stringidMatriz = String(partidaSeleccionada.idMatriz)
            let stringversionActual = String(partidaSeleccionada.versionActual)
            peticion.predicate = NSPredicate(format: "idMatrix == %@ AND version == %@", stringidMatriz, stringversionActual)
            let resultados = try! contexto2.fetch(peticion)
            codigoMatrizCreada = resultados[0].codigoMatriz
            idMatrizCreada = resultados[0].idMatrix
            crearMatrix(codigoMatriz: codigoMatrizCreada)
            // Cargo Leo el LogMatriz
            cargarFilaLog()
            cargarGruposDesdeLog()
        }
        // Inicializo
        numIteraciones = Int32(partidaSeleccionada.versionActual)
        numCasillasOriginal = Int(partidaSeleccionada.numCasillasOriginal)
        puntosJugador = partidaSeleccionada.puntosJugador
        paresJugador = partidaSeleccionada.paresJugador
        filasJugador = partidaSeleccionada.filasJugador
        puntosOrdenador = partidaSeleccionada.puntosOrdenador
        paresOrdenador = partidaSeleccionada.paresOrdenador
        filasOrdenador = partidaSeleccionada.filasOrdenador
        puntosTotalJugador = jugadorSeleccionado.puntosTotal - partidaSeleccionada.puntosJugador
        paresTotalJugador = jugadorSeleccionado.paresTotal - partidaSeleccionada.paresJugador
        filasTotalJugador = jugadorSeleccionado.filasTotal - partidaSeleccionada.filasJugador
        tuPuntuacion2.text = "\(puntosJugador)"
        ordPuntuacion12.text = "\(puntosOrdenador)"
        // A jugar
    }
    override func viewWillAppear(_ animated: Bool) {
        //       self.collectionView!.reloadData
        super.viewWillAppear(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //        guardarMatriz(estado: 1)
        //        guardarCeldas()
        //        guardarPartida(estado: 1)
        //        guardarJugador()
        //        guardarLogMatriz()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        //        guardarMatriz(estado: 1)
        //        guardarCeldas()
        //        guardarPartida(estado: 1)
        //        guardarJugador()
        //        guardarLogMatriz()
    }
    
    // Funciones de Inicio
    func primeraVezPartida() -> Bool{
        // Me pasan"partidaSeleccionada", compruebo si es una Partida nueva y hay que inicializar el idmatriz
        if partidaSeleccionada.idMatriz == 0 {
            // Es nueva hay que crear Matriz y Celdas
            let contexto = conexion()
            let peticion = NSFetchRequest<Matrices>(entityName: "Matrices")
            peticion.predicate = NSPredicate(format: "codigoMatriz != nil")
            cantidadMatrices = try! contexto.count(for: peticion)
            if cantidadMatrices == 0 {
                codigoMatrizCreada = 1
                idMatrizCreada = 1
            } else {
                // Busco los códigos y me los deja en codigoMatrizCreada e idMatrizCreada
                buscarCodigoMatriz()
                buscarIdMatriz()
            }
            // Creo la Matriz -> Celdas -> matrix
            numIteraciones = 0
            celdasAnteriores = 0
            crearMatrizNueva(numCasillas: Int32(numCasillasOriginal), nueva: true)
            // Actualizo la Partida con el idMatrix = idMatrixCreada, los puntosOrdenador y la guardo en CoreData
            let contexto3 = conexion()
            let peticion3 = NSFetchRequest<Partidas>(entityName: "Partidas")
            let stringIdPartida = String(partidaSeleccionada.idPartida)
            peticion3.predicate = NSPredicate(format: "idPartida == %@", stringIdPartida)
            let partidaSel = try! contexto3.fetch(peticion3)
            partidaSeleccionada = partidaSel[0]
            partidaSeleccionada.idMatriz = Int32(idMatrizCreada)
            partidaSeleccionada.estado = 1
            partidaSeleccionada.puntosOrdenador = puntosOrdenador
            do {
                try contexto3.save()
            } catch let error as NSError {
                print("no puedo actualizar número de partidas del jugador", error)
            }
            numCasillasOriginal = Int(partidaSeleccionada.numCasillasOriginal)
            return true        }
        return false
    }
    // Buscar los codigoMatriz y idMatriz nuevos
    func buscarCodigoMatriz() {
        do {
            let contexto = conexion()
            let peticion = NSFetchRequest<Matrices>(entityName: "Matrices")
            let orderByCodigoMatriz = NSSortDescriptor(key: "codigoMatriz", ascending: false)
            peticion.sortDescriptors = [orderByCodigoMatriz]
            peticion.fetchLimit = 1
            let resultados = try contexto.fetch(peticion)
            codigoMatrizCreada = resultados[0].codigoMatriz + 1
        } catch let error as NSError {
            print("No pude recuperar datos \(error), \(error.userInfo)")
        }
    }
    func buscarIdMatriz() {
        do {
            let contexto = conexion()
            let peticion = NSFetchRequest<Matrices>(entityName: "Matrices")
            let orderByIdMatriz = NSSortDescriptor(key: "idMatrix", ascending: false)
            peticion.sortDescriptors = [orderByIdMatriz]
            peticion.fetchLimit = 1
            let resultados = try contexto.fetch(peticion)
            idMatrizCreada = resultados[0].idMatrix + 1
        } catch let error as NSError {
            print("No pude recuperar datos \(error), \(error.userInfo)")
        }
    }
    // crear Matriz Nueva
    func crearMatrizNueva (numCasillas: Int32, nueva: Bool) {
        // Ya tengo en los codigoMatrizCreada y idMatrizCreada los nuevos de antes
        let contexto = conexion()
        let entidad = NSEntityDescription.entity(forEntityName: "Matrices", in: contexto)!
        let matrizCreada = Matrices(entity: entidad,insertInto: contexto)
        matrizCreada.codigoMatriz = Int32(codigoMatrizCreada)
        matrizCreada.idMatrix = Int32(idMatrizCreada)
        matrizCreada.estado = 0
        matrizCreada.version = Int16(numIteraciones)
        matrizCreada.numCasillas = numCasillas
        matrizCreada.columnasJugador = 0
        matrizCreada.columnasOrdenador = 0
        matrizCreada.filasJugador = 0
        matrizCreada.filasOrdenador = 0
        matrizCreada.paresJugador = 0
        matrizCreada.paresOrdenador = 0
        matrizCreada.puntosJugador = 0
        matrizCreada.puntosOrdenador = 0
        try! contexto.save()
        if nueva {
            crearCeldas (numCasillas: numCasillas)
            crearMatrix(codigoMatriz: codigoMatrizCreada)
            duplicarMatriz(numcasillas: numCasillas, nueva: nueva)
            // Como duplicarMatriz cea un nuevo códigoMatrizCreada copio las celdas de matrix en las nuevas Celdas
            duplicarCeldas()
            
        } else {
            // Hay que crear las Celdas poniendo en primer lugar las celdas de matrix
            // Esto lo hace duplicarCeldas()
            duplicarCeldas()
            // Ahora tengo que crear las nuevas celdas: crearCeldas(numCasillasTotal: incremento)
            crearCeldas(numCasillas: Int32(incremento))
            crearMatrix(codigoMatriz: codigoMatrizCreada)
            duplicarMatriz(numcasillas: numCasillas, nueva: nueva)
            // Como duplicarMatriz cea un nuevo códigoMatrizCreada copio las celdas de matrix en las nuevas Celdas
            duplicarCeldas()
        }
        // Aprovecho y calculo los puntos del ordenador
        calculoOrdenador(matrixOrdCalculo: matrix)
        //       print("Puntos: \(ordPuntos) Filas: \(ordFilas)")
        puntosOrdenador = puntosOrdenador + ordPuntos
        filasOrdenador = filasOrdenador + ordFilas
        paresOrdenador = paresOrdenador + ordPares
        ordPuntuacion12.text = "\(puntosOrdenador)"
        
        self.matrixCollectionView2.reloadData()
        // Borro logJuego (antes lo he guardado en CoreData -> LogMatriz
        logJuego.removeAll()
        indiceLog = 0
    }
    func crearCeldas(numCasillas: Int32) {
        let contexto2 = conexion()
        let entidad2 = NSEntityDescription.entity(forEntityName: "Celdas", in: contexto2)!
        for j in celdasAnteriores + 1 ... numCasillas {
            aleatorio = 1 + Int(arc4random_uniform(9))
            let celda = Celdas(entity: entidad2,insertInto: contexto2)
            celda.codigoMatriz = Int32(codigoMatrizCreada)
            celda.numCelda = Int16(j)
            celda.valorCelda = Int16(aleatorio)
            try! contexto2.save()
        }
    }
    func duplicarMatriz (numcasillas: Int32, nueva:Bool) {
        buscarCodigoMatriz()
        let contexto = conexion()
        let entidad = NSEntityDescription.entity(forEntityName: "Matrices", in: contexto)!
        let matrizCreada = Matrices(entity: entidad,insertInto: contexto)
        matrizCreada.codigoMatriz = Int32(codigoMatrizCreada)
        matrizCreada.idMatrix = Int32(idMatrizCreada)
        matrizCreada.estado = 1
        matrizCreada.version = Int16(numIteraciones)
        matrizCreada.numCasillas = Int32(numCasillas)
        matrizCreada.columnasJugador = 0
        matrizCreada.columnasOrdenador = 0
        matrizCreada.filasJugador = 0
        matrizCreada.filasOrdenador = 0
        matrizCreada.paresJugador = 0
        matrizCreada.paresOrdenador = 0
        matrizCreada.puntosJugador = 0
        matrizCreada.puntosOrdenador = 0
        try! contexto.save()
        //        codigoMatrizUsada = codigoMatrizCreada
    }
    func duplicarCeldas() {
        let contexto2 = conexion()
        let entidad2 = NSEntityDescription.entity(forEntityName: "Celdas", in: contexto2)!
        for j in 0 ... matrix.count - 1 {
            let celda = Celdas(entity: entidad2,insertInto: contexto2)
            celda.codigoMatriz = Int32(codigoMatrizCreada)
            celda.numCelda = Int16(j)
            celda.valorCelda = Int16(matrix [j])
            //           print(celda)
            try! contexto2.save()
        }
    }
    func crearMatrix (codigoMatriz: Int32) {
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
        numCasillas = matrix.count
    }
    // Ver si Fin de matrix
    @IBAction func verificarSiQuedan2(_ sender: Any) {
//        calculoOrdenadorGrupos(matrixOrdCalculo: matrix)
        calculoOrdenador(matrixOrdCalculo: matrix)
        ordPuntuacion22.text = "\(ordPuntos)"
        //        print("Puntos: \(ordPuntos) Filas: \(ordFilas)")
        if ordPuntos == 0 {
            numIteraciones = numIteraciones + 1  // Ojo poner límite
            if numIteraciones > 10 {
                // Ha finalizado la partida pero tengo que:
                // guardar la Matriz con estado = 2 y los puntos/pares/filas/columnas del Jugador
                // actualizar la Partida con los puntos/pares/filas/columnas del Jugador
                //                               fechaFinal, estado, etc.
                finalPartida = true              // Fin de Partida para las versiones de Matrices y Partidas
                //      numIteraciones = 10
                guardarMatriz(estado: 2)
                guardarCeldas()
                guardarPartida(estado: 2)
                guardarJugador()
                guardarLogMatriz()
                guardarLogGrupos()
                let numDePartidaJugada = numDePartidas + 1
                self.performSegue(withIdentifier: "volverDeJugar", sender: numDePartidaJugada)
                //          return
            } else {
                /*
                 Se ha completado la Matriz actual, hay que:
                 guardar la Matriz con estado = 2 y los puntos/pares/filas/columnas del Jugador
                 actualizar la Partida con versionActual + 1 y los puntos/pares/filas/columnas del Jugador
                 */
                guardarMatriz(estado: 2)
                guardarCeldas()
                guardarPartida(estado: 1)
                guardarJugador()
                guardarLogMatriz()
                guardarLogGrupos()
                /*
                 Además:
                 Crear la nueva Matriz n
                 las Celdas correspondientes
                 los duplicados de ambas
                 y matrix
                 */
                incremento = (Int(numCasillasOriginal * Int(numIteraciones + 1)))       //  - numCasillas
                //          numCasillasTotal = numCasillasTotal + incremento
                celdasAnteriores = Int32(matrix.count)
                incremento = incremento + Int(celdasAnteriores)
                incrementarMatriz(numCasillas: Int32(incremento))
            }
        }
    }
    
    // crear Matriz Nueva añadiendo a la actual las casillas incrementales
    func incrementarMatriz (numCasillas: Int32) {
        // Busco máximo de codigoMatriz. El idMatrix es el mismo, cambia la versión
        buscarCodigoMatriz()
        crearMatrizNueva(numCasillas: numCasillas, nueva: false)
        // Ya tengo en los codigoMatrizCreada el nuevo y idMatrizCreada la actual
        
    }
    // Guardar Matriz con estado = ?, actualizando puntosJugador; después guardaré las Celdas con la matrix restante
    func guardarMatriz(estado: Int) {
        let contexto = conexion()
        let peticion = NSFetchRequest<Matrices>(entityName: "Matrices")
        let stringcodigoMatrizCreada = String(codigoMatrizCreada)
        peticion.predicate = NSPredicate(format: "codigoMatriz == %@", stringcodigoMatrizCreada)
        do {
            let resultados = try contexto.fetch(peticion)
            let matriz = resultados[0]
            matriz.estado = Int16(estado)
            matriz.columnasJugador = 0
            matriz.columnasOrdenador = 0
            matriz.filasJugador = Int64(filasJugador)
            matriz.filasOrdenador = Int64(filasOrdenador)
            matriz.numCasillas = Int32(matrix.count)
            matriz.paresJugador = Int64(paresJugador)
            matriz.paresOrdenador = Int64(paresOrdenador)
            matriz.puntosOrdenador = Int64(puntosOrdenador)
            matriz.puntosJugador = Int64(puntosJugador)
            if finalPartida || estado == 2 {
                matriz.version = Int16(numIteraciones - 1)
            } else {
                matriz.version = Int16(numIteraciones)
            }
            try! contexto.save()
        } catch let error as NSError {
            print("No pude recuperar datos \(error), \(error.userInfo)")
        }
    }
    func guardarCeldas() {
        // Primero borro las Celdas de ese codigoMatriz
        let contexto = conexion()
        let peticion = NSFetchRequest<Celdas>(entityName: "Celdas")
        let stringcodigoMatrizCreada = String(codigoMatrizCreada)
        peticion.predicate = NSPredicate(format: "codigoMatriz == %@", stringcodigoMatrizCreada)
        do {
            let resultados = try! contexto.fetch(peticion)
            if resultados.count > 0 {
                for i in resultados {
                    contexto.delete(i)
                    try! contexto.save()
                }
            }
        }
        // Ahora Creo de nuevo las Celdas a partir de matrix
        // Esto lo hace duplicarCeldas()
        duplicarCeldas()
    }
    /*
     grupoJugadas[j][0] = P = PUNTOS de la jugada
     grupoJugadas[j][1] = N = Número de PAREJAS de la jugada
     grupoJugadas[j][2] = ÍNDICE de la Celda 1 de la 1ª Pareja del GRUPO j
     grupoJugadas[j][3] = ÍNDICE de la Celda 2 de la 1ª Pareja del GRUPO j
     grupoJugadas[j][4] = VALOR de la Celda 1 de la 1ª Pareja del GRUPO j
     grupoJugadas[j][5] = VALOR de la Celda 2 de la 1ª Pareja del GRUPO j
     ...   ...   ...  ...   ...   ...   ...   ...   ...   ...   ...
     grupoJugadas[j][4*N - 2] = ÍNDICE de la Celda 1 de la última Pareja de la GRUPO j
     grupoJugadas[j][4*N - 1] = ÍNDICE de la Celda 2 de la última Pareja de la GRUPO j
     grupoJugadas[j][4*N]     = VALOR de la Celda 1 de la última Pareja de la GRUPO j
     grupoJugadas[j][4*N + 1] = VALOR de la Celda 2 de la última Pareja de la GRUPO j
     */
    func guardarLogGrupos() {
        // Compruebo que hay grupos en grupoJugadas, si no hay no guardo nada
        if grupoJugadas.count > 0 {
            // Primero borro el LogGruposCabecera y y el LogGrupos de ese codigoMatriz
            let contexto = conexion()
            let peticion = NSFetchRequest<LogGruposCabecera>(entityName: "LogGruposCabecera")
            let stringcodigoMatrizCreada = String(codigoMatrizCreada)
            peticion.predicate = NSPredicate(format: "codigoMatriz == %@", stringcodigoMatrizCreada)
            do {
                let resultados = try! contexto.fetch(peticion)
                if resultados.count > 0 {
                    for i in resultados {
                        contexto.delete(i)
                        try! contexto.save()
                    }
                }
            }
            let contexto2 = conexion()
            let peticion2 = NSFetchRequest<LogGrupos>(entityName: "LogGrupos")
            peticion2.predicate = NSPredicate(format: "codigoMatriz == %@", stringcodigoMatrizCreada)
            do {
                let resultados = try! contexto2.fetch(peticion2)
                if resultados.count > 0 {
                    for i in resultados {
                        contexto2.delete(i)
                        try! contexto2.save()
                    }
                }
            }
            // Ahora Creo LogGruposCabecera y LogGrupos a partir de grupoJugadas
            let contexto3 = conexion()
            let entidad3 = NSEntityDescription.entity(forEntityName: "LogGruposCabecera", in: contexto3)!
            let contexto4 = conexion()
            let entidad4 = NSEntityDescription.entity(forEntityName: "LogGrupos", in: contexto4)!
            for i in 0 ... grupoJugadas.count - 1 {
                let log = LogGruposCabecera(entity: entidad3,insertInto: contexto3)
                let grupoActual = grupoJugadas[i]
                log.codigoMatriz = codigoMatrizCreada
                log.numGrupo = Int16(i)
                log.puntosJugada = Int16(grupoActual[0])
                log.numParejas = Int16(grupoActual[1])
                try! contexto3.save()
                if grupoActual[1] > 0 {
                    for j in 0 ... grupoActual[1] - 1 {
                        let base = j * 4
                        let log2 = LogGrupos(entity: entidad4,insertInto: contexto4)
                        log2.codigoMatriz = codigoMatrizCreada
                        log2.numGrupo = Int16(i)
                        log2.numCelda1 = Int16(grupoActual[base + 2])
                        log2.numCelda2 = Int16(grupoActual[base + 3])
                        log2.valorCelda1 = Int16(grupoActual[base + 4])
                        log2.valorCelda2 = Int16(grupoActual[base + 5])
                        log2.numSubgrupo = Int16(j)
                        try! contexto4.save()
                    }
                }
            }
        }
    }
    func guardarLogMatriz() {
        // Compruebo que hay logJuego, si no hay no guardo nada
        if logJuego.count > 0 {
            // Primero borro el Log de ese codigoMatriz
            let contexto = conexion()
            let peticion = NSFetchRequest<LogMatriz>(entityName: "LogMatriz")
            let stringcodigoMatrizCreada = String(codigoMatrizCreada)
            peticion.predicate = NSPredicate(format: "codigoMatriz == %@", stringcodigoMatrizCreada)
            do {
                let resultados = try! contexto.fetch(peticion)
                if resultados.count > 0 {
                    for i in resultados {
                        contexto.delete(i)
                        try! contexto.save()
                    }
                }
            }
            // Ahora Creo LogMatriz a partir de logJuego
            let contexto2 = conexion()
            let entidad2 = NSEntityDescription.entity(forEntityName: "LogMatriz", in: contexto2)!
            for j in 0 ... logJuego.count - 1 {
                let log = LogMatriz(entity: entidad2,insertInto: contexto2)
                let filaActual = logJuego[j]
                log.codigoMatriz = codigoMatrizCreada
                log.movimiento = Int32(j)
                log.numCelda1 = Int16(filaActual[0])
                log.numCelda2 = Int16(filaActual[1])
                log.valorCelda1 = Int16(filaActual[2])
                log.valorCelda2 = Int16(filaActual[3])
                log.numFilasALimpiar = Int16(filaActual[4])
                log.filaLimpiada1 = Int16(filaActual[5])
                log.filaLimpiada2 = Int16(filaActual[6])
                try! contexto2.save()
            }
        }
    }
    func cargarGruposDesdeLog() {
        // Borro gruposJugadas
        grupoJugadas.removeAll()
        // Leo LogGruposCabecera y LosGrupos ordenados por numGrupo
        let stringCodigoMatriz = String(codigoMatrizCreada)
//        let stringNumGrupo = String(codigoMatrizCreada)
        let contexto = conexion()
        let peticion = NSFetchRequest<LogGruposCabecera>(entityName: "LogGruposCabecera")
        let orderBymovimiento = NSSortDescriptor(key: "numGrupo", ascending: true)
        peticion.sortDescriptors = [orderBymovimiento]
        peticion.predicate = NSPredicate(format: "codigoMatriz == %@", stringCodigoMatriz)
        do {
            let resultados = try contexto.fetch(peticion)
            for res in resultados as [NSManagedObject] {
                grupoJugadasParcial.removeAll()
                grupoJugadasParcial.append(res.value(forKey: "puntosJugada") as! Int)
                grupoJugadasParcial.append(res.value(forKey: "numParejas") as! Int)
                let stringNumGrupo = String(describing: res.value(forKey: "numGrupo"))
                let contexto2 = conexion()
                let peticion2 = NSFetchRequest<LogGrupos>(entityName: "LogGrupos")
                let orderBymovimiento2 = NSSortDescriptor(key: "numSubgrupo", ascending: true)
                peticion2.sortDescriptors = [orderBymovimiento2]
                peticion2.predicate = NSPredicate(format: "codigoMatriz == %@ AND numGrupo == %@", stringCodigoMatriz, stringNumGrupo)
                do {
                    let resultados2 = try contexto2.fetch(peticion2)
                    for res2 in resultados2 as [NSManagedObject] {
                        grupoJugadasParcial.append(res2.value(forKey: "numCelda1") as! Int)
                        grupoJugadasParcial.append(res2.value(forKey: "numCelda2") as! Int)
                        grupoJugadasParcial.append(res2.value(forKey: "valorCelda1") as! Int)
                        grupoJugadasParcial.append(res2.value(forKey: "valorCelda2") as! Int)
                    }
                    grupoJugadas.append(grupoJugadasParcial)
                }
            }
        } catch let error as NSError {
            print("No pude recuperar datos de LogGuposCabecera \(error), \(error.userInfo)")
        }
    }
    func cargarFilaLog() {
        // Borro el logJuego
        logJuego.removeAll()
        // Leo el logMatriz ordenado por movimiento
        let stringCodigoMatriz = String(codigoMatrizCreada)
        let contexto = conexion()
        let peticion = NSFetchRequest<LogMatriz>(entityName: "LogMatriz")
        let orderBymovimiento = NSSortDescriptor(key: "movimiento", ascending: true)
        peticion.sortDescriptors = [orderBymovimiento]
        peticion.predicate = NSPredicate(format: "codigoMatriz == %@", stringCodigoMatriz)
        do {
            let resultados = try contexto.fetch(peticion)
            for res in resultados as [NSManagedObject] {
                filaLog.removeAll()
                filaLog.append(res.value(forKey: "numCelda1") as! Int)
                filaLog.append(res.value(forKey: "numCelda2") as! Int)
                filaLog.append(res.value(forKey: "valorCelda1") as! Int)
                filaLog.append(res.value(forKey: "valorCelda2") as! Int)
                filaLog.append(res.value(forKey: "numFilasALimpiar") as! Int)
                filaLog.append(res.value(forKey: "filaLimpiada1") as! Int)
                filaLog.append(res.value(forKey: "filaLimpiada2") as! Int)
                logJuego.append(filaLog)
            }
            indiceLog = resultados.count
        } catch let error as NSError {
            print("No pude recuperar datos de logMatriz\(error), \(error.userInfo)")
        }
    }
    func guardarPartida(estado: Int) {
        let contexto = conexion()
        // Leo la partida del Jugador
        let peticion = NSFetchRequest<Partidas>(entityName: "Partidas")
        let stringidPartida = String(partidaSeleccionada.idPartida)
        //       let stringidJugador = String(describing: partidaSeleccionada.idJugador)
        let predicado = NSPredicate (format: "(idPartida == %@) && (idJugador == %@)", stringidPartida, partidaSeleccionada.idJugador!)
        peticion.predicate = predicado
        do {
            let resultados = try contexto.fetch(peticion)
            let partidaCreada = resultados.first!
            partidaCreada.fechaFinal = NSDate() as Date
            partidaCreada.estado = Int16(estado)
            if finalPartida {
                partidaCreada.versionActual = Int16(numIteraciones - 1)
            } else {
                partidaCreada.versionActual = Int16(numIteraciones)
            }
            partidaCreada.puntosJugador = puntosJugador
            partidaCreada.paresJugador = paresJugador
            partidaCreada.filasJugador = filasJugador
            partidaCreada.puntosOrdenador = puntosOrdenador
            partidaCreada.paresOrdenador = paresOrdenador
            partidaCreada.filasOrdenador = filasOrdenador
            if finalGlorioso {
                partidaCreada.columnasJugador = partidaCreada.columnasJugador + 1
            }
            try! contexto.save()
        } catch let error as NSError {
            print("No pude recuperar guardar partida \(error), \(error.userInfo)")
        }
    }
    func guardarJugador() {
        let contexto = conexion()
        // Leo el Jugador
        let peticion = NSFetchRequest<Jugadores>(entityName: "Jugadores")
        let predicado = NSPredicate (format: "idJugador == %@", partidaSeleccionada.idJugador!)
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
    
    // Funciones de cálculo del Ordenador
    func calculoOrdenador(matrixOrdCalculo: [Int]) {
        ordPuntos = 0
        ordFilas = 0
        ordPares = 0
        repetir = 0
        numCasillas = matrixOrdCalculo.count
        cambiarMatrix(matrixOrdCalculo: matrixOrdCalculo)
        while repetir == 0 {
            parejas = 0
            for i in 0 ... numCasillas - 1 {                        // Bucle para coger una casilla desde el principo al final y ver si tiene pareja
                if matrixOrdenador [i] != " " {
                    finalTabla = false
                    buscarAdelanteOrd(i: Int(i))                    // Una vez encontada una casilla <> 0 busco hacia adelante
                }
            }
            if parejas == 0 {repetir = 1}
        }
    }
    func cambiarMatrix(matrixOrdCalculo: [Int]) {
        matrixOrdenador.removeAll()
        for i in 0 ... numCasillas - 1 {
            switch matrixOrdCalculo[i] {
            case 1: matrixOrdenador.append("A")
            case 2: matrixOrdenador.append("B")
            case 3: matrixOrdenador.append("C")
            case 4: matrixOrdenador.append("D")
            case 5: matrixOrdenador.append("E")
            case 6: matrixOrdenador.append("D")
            case 7: matrixOrdenador.append("C")
            case 8: matrixOrdenador.append("B")
            case 9: matrixOrdenador.append("A")
            default: matrixOrdenador.append(" ")
            }
        }
    }
    // Búsquedas del Ordenador
    func ordEncuentra(i: Int, j: Int) {
        matrixOrdenador [i] = " "                              // Encontrada pareja los pongo a 0 e incremento contadores
        matrixOrdenador [j] = " "
        ordPuntos = ordPuntos + 1
        ordPares = ordPares + 1
        parejas = parejas + 1
        ordBuscaFilas(i: i, j: j)
    }
    func ordBuscaFilas(i: Int, j: Int) {
        filaALimpiar1 = i / 9
        filaALimpiar2 = j / 9
        if filaALimpiar1 == filaALimpiar2 {
            limpiarFilasOrd(fila: filaALimpiar1)
        } else {
            limpiarFilasOrd(fila: filaALimpiar2)
            limpiarFilasOrd(fila: filaALimpiar1)
        }
    }
    func limpiarFilasOrd (fila: Int) {
        for i in fila * 9 ... fila * 9 + 8 {
            if i > numCasillas - 1 {return}
            if matrixOrdenador [i] != " " {
                return
            }
        }
        ordFilas = ordFilas + 1
        ordPuntos = ordPuntos + 3
        return
    }
    func buscarAdelanteOrd (i: Int) {
        if finalTabla == true {return}
        if i >= numCasillas - 1 {buscarAtrasOrd(i: i); return}
        for j in i + 1 ... numCasillas - 1 {                   // Bucle hacia adelante desde la casilla siguiente a la recibida hasta el final de la tabla
            if matrixOrdenador [j] != " " {
                if (matrixOrdenador [i] == matrixOrdenador [j]) {
                    ordEncuentra(i: i, j: j)
                    return
                }
                buscarAtrasOrd(i: i)                                   // No encontrada pareja hacia adelante, busco haca atrás
                return
            }
        }
    }
    func buscarAtrasOrd (i: Int) {
        if finalTabla == true {return}
        j = i - 1
        if j < 0 {buscarArribaOrd(i: i); return}                     // Estamos en la primera casilla y no podemos ir hacia atrás, nos vamos a buscar hacia arriba
        while j >= 0 {                                              // Bucle hacia atrás desde la casilla anterior a la recibida hasta el principio de la tabla
            if matrixOrdenador[j] != " " {
                if (matrixOrdenador [i] == matrixOrdenador [j]) {
                    ordEncuentra(i: i, j: j)
                    return
                } else {
                    buscarArribaOrd(i: i)                              // No encontrada pareja hacia atrás, busco hacia arriba
                    return
                }
            } else { j = j - 1}                                     // Sigo buscando hacia atrás
        }
        buscarArribaOrd(i: i)                                          // Hemos llegado al principio y no hemos encontrado pareja hacia atrás, busco hacia arriba
        return
    }
    func buscarArribaOrd (i: Int) {
        if finalTabla == true {return}
        j = i - 9
        if j < 0 {buscarAbajoOrd(i: i); return}                               // Estamos en la primera fila y no podemos ir hacia arriba, nos vamos a buscar hacia abajo
        while j >= 0 {
            if matrixOrdenador [j] != " " {
                if (matrixOrdenador [i] == matrixOrdenador [j]) {
                    ordEncuentra(i: i, j: j)
                    return
                } else {
                    buscarAbajoOrd(i: i)                           // No hemos encontrado pareja buscando hacia arriba, busco hacia abajo
                    return
                }
            } else { j = j - 9}                                 // Sigo buscando hacia abajo
        }
        buscarAbajoOrd(i: i)                                           // Hemos llegado a arriba y no hemos encontrado pareja, busco hacia abajo
        return
    }
    func buscarAbajoOrd (i: Int) {
        j = i + 9
        if j > numCasillas {return}                               // Estamos en la última fila y no podemos ir hacia abajo. No hemos encontrado pareja con ese i, continuamos
        while j < numCasillas {
            if matrixOrdenador [j] != " " {
                if  matrixOrdenador [i] == matrixOrdenador [j] {
                    ordEncuentra(i: i, j: j)
                    return
                } else {
                    finalTabla = true
                    return                                      // No hemos encontrado pareja para este "i", continuamos
                }
            } else { j = j + 9}                                 // Sigo buscando hacia abajo
        }
        return                                                  // No hemos encontrado pareja para este "i", continuamos
    }
    
    // Funciones del collectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return matrix.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let celda = collectionView.dequeueReusableCell(withReuseIdentifier: "numeroCelda", for: indexPath) as! matrixCollectionViewCell
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
            default: colorElegido = color6
            }
            celda?.backgroundColor = colorElegido
            numPulsaciones = 1
            paresGrupo = 0
            puntosGrupo = 0
            pulsacionesPar = false
            tengoGrupo = false
            indexGrupoJugador.removeAll()
            indexGrupoParcial.removeAll()
  //          casillasGrupoJugador.removeAll()
  //          casillasGrupoParcial.removeAll()
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
                    // Si yaEstá al ser IMPAR -> ir a acumular la Jugada y empezar de nuevo
                    if yaEsta {
                        // Si yaEstá al ser IMPAR -> ir a acumular la Jugada y empezar de nuevo
                        anotarJugada()
                    } else {
                        // Es Nueva. Comprobar si esta Celda puede hacer pareja con cualquier Celda ya guardada
                        if haceGrupo {
                            // sigue la cadena y es la primera celda del nuevo eslabón. Pongo la celda como Celda1
                            celda?.backgroundColor = colorElegido
                            celda1 = indexPath
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
                    numPulsaciones = numPulsaciones - 2
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
                                celda?.backgroundColor = colorElegido
                                encontradaParejaGrupo(primero: celda1, segundo: celda2)
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
//        casillasGrupoParcial.removeAll()
//        casillasGrupoParcial.append(primero.row)
//        casillasGrupoParcial.append(segundo.row)
//        casillasGrupoJugador.append(casillasGrupoParcial)
        paresGrupo = paresGrupo + 1
        /*
         switch paresGrupo {
         case 1: puntosGrupo = paresGrupo + 0
         case 2: puntosGrupo = paresGrupo + 1
         case 3: puntosGrupo = paresGrupo + 2
         case 4: puntosGrupo = paresGrupo + 3
         case 5: puntosGrupo = paresGrupo + 0
         case 6: puntosGrupo = paresGrupo + 0
         case 7: puntosGrupo = paresGrupo + 0
         case 8: puntosGrupo = paresGrupo + 0
         case 9: puntosGrupo = paresGrupo + 0
         case 10: puntosGrupo = paresGrupo + 0
         case 11: puntosGrupo = paresGrupo + 0
         case 12: puntosGrupo = paresGrupo + 0
         case 13: puntosGrupo = paresGrupo + 0
         case 14: puntosGrupo = paresGrupo + 0
         case 15: puntosGrupo = paresGrupo + 0
         case 16: puntosGrupo = paresGrupo + 0
         case 17: puntosGrupo = paresGrupo + 0
         case 18: puntosGrupo = paresGrupo + 0
         case 19: puntosGrupo = paresGrupo + 0
         case 20: puntosGrupo = paresGrupo + 0
         case 21: puntosGrupo = paresGrupo + 0
         default: puntosGrupo = paresGrupo + 0
         }
 */
        puntosGrupo = paresGrupo + (paresGrupo - 1) * 2      // Ojo cambiar puntuación
        puntosParcial.text = "\(puntosGrupo)"
        tengoGrupo = true
    }
    func encontradaPareja (primero: IndexPath, segundo: IndexPath) {
//        puntosJugador = puntosJugador + 1
        paresJugador = paresJugador + 1
//        tuPuntuacion2.text = "\(puntosJugador)"
        filaLog.removeAll()
        /*
         filaLog[0] = número de la Celda 1
         filaLog[1] = número de la Celda 2
         filaLog[2] = valor de la Celda 1
         filaLog[3] = valor de la Celda 2
         filaLog[4] = número de Líneas a Limpiar
         filaLog[5] = número de la 1ª Línea a Limpiar si la hay
         filaLog[6] = número de la 2ª Línea a Limpiar si la hay
         */
        filaLog.append(primero.row)
        filaLog.append(segundo.row)
        filaLog.append(matrix [primero.row])
        filaLog.append(matrix [segundo.row])
        lineasALimpiarLog = 0
        lineaLimpiar1Log = 0
        lineaLimpiar2Log = 0
        limpiar(primero: primero, segundo: segundo)
        filaLog.append(lineasALimpiarLog)
        filaLog.append(lineaLimpiar1Log)
        filaLog.append(lineaLimpiar2Log)
        logJuego.append(filaLog)
        indiceLog = indiceLog + 1
        self.matrixCollectionView2.reloadData()
    }
    func limpiar (primero: IndexPath, segundo: IndexPath) {
        matrix [primero.row] = 0
        matrix [segundo.row] = 0
        numPulsaciones = 0
        if primero > segundo {
            filaALimpiar2 = primero.row / 9
            filaALimpiar1 = segundo.row / 9
        } else {
            filaALimpiar1 = primero.row / 9
            filaALimpiar2 = segundo.row / 9
        }
        if filaALimpiar1 == filaALimpiar2 {
            if limpiarFilas(fila: filaALimpiar1) {
                eliminarFilas(casilla: filaALimpiar1 * 9)
                self.matrixCollectionView2.reloadData()
                lineaLimpiar1Log = filaALimpiar1
            }
        } else {
            if limpiarFilas(fila: filaALimpiar2) {
                eliminarFilas(casilla: filaALimpiar2 * 9)
                self.matrixCollectionView2.reloadData()
                lineaLimpiar1Log = filaALimpiar2
            }
            if limpiarFilas(fila: filaALimpiar1) {
                eliminarFilas(casilla: filaALimpiar1 * 9)
                self.matrixCollectionView2.reloadData()
                lineaLimpiar2Log = filaALimpiar1
            }
        }
    }
    func limpiarFilas (fila: Int) -> Bool {
        for i in fila * 9 ... fila * 9 + 8 {
            if i > numCasillas - 1 {return false}
            if matrix [i] != 0 {
                return false
            }
        }
        filasJugador = filasJugador + 1
        puntosJugador = puntosJugador + 4
        tuPuntuacion2.text = "\(puntosJugador)"
        return true
    }
    func eliminarFilas (casilla: Int){
        numFilasLimpias = numFilasLimpias + 1
        for _ in 1 ... 9 {
            matrix.remove(at: casilla)
        }
        numFilasLimpias = numFilasLimpias + 1
        lineasALimpiarLog = lineasALimpiarLog + 1
        numCasillas = numCasillas - 9
    }
    
    // IBOutlets
    @IBOutlet weak var matrixCollectionView2: UICollectionView!
    
    @IBOutlet weak var ordPuntuacion12: UILabel!
    @IBOutlet weak var ordPuntuacion22: UILabel!
    @IBOutlet weak var tuPuntuacion2: UILabel!
    @IBOutlet weak var puntosParcial: UILabel!
    
    @IBAction func irAtras2(_ sender: Any) {
        let numDePartidaJugada = numDePartidas + 1
        guardarMatriz(estado: 1)
        guardarCeldas()
        guardarPartida(estado: 1)
        guardarJugador()
        guardarLogMatriz()
        guardarLogGrupos()
        self.performSegue(withIdentifier: "volverDeJugar", sender: numDePartidaJugada)
    }
    @IBAction func limpiarJugada(_ sender: Any) {
        // Tenemos que recorrer los grupos guardados o borrarlos e inicializar
        // creo que lo más sencillo es numPulsaciones = 0 y reload
        numPulsaciones = 0
        self.matrixCollectionView2.reloadData()
        // anotarJugada()
    }
    
    func anotarJugada() {
        /*
         grupoJugadas[j][0] = P = PUNTOS de la jugada
         grupoJugadas[j][1] = N = Número de PAREJAS de la jugada
         grupoJugadas[j][2] = ÍNDICE de la Celda 1 de la 1ª Pareja del GRUPO j
         grupoJugadas[j][3] = ÍNDICE de la Celda 2 de la 1ª Pareja del GRUPO j
         grupoJugadas[j][4] = VALOR de la Celda 1 de la 1ª Pareja del GRUPO j
         grupoJugadas[j][5] = VALOR de la Celda 2 de la 1ª Pareja del GRUPO j
         ...   ...   ...  ...   ...   ...   ...   ...   ...   ...   ...
         grupoJugadas[j][4*N - 2] = ÍNDICE de la Celda 1 de la última Pareja de la GRUPO j
         grupoJugadas[j][4*N - 1] = ÍNDICE de la Celda 2 de la última Pareja de la GRUPO j
         grupoJugadas[j][4*N]     = VALOR de la Celda 1 de la última Pareja de la GRUPO j
         grupoJugadas[j][4*N + 1] = VALOR de la Celda 2 de la última Pareja de la GRUPO j
        */
        
        if tengoGrupo {
            if indexGrupoJugador.count > 0 {
                grupoJugadasParcial.removeAll()
                grupoJugadasParcial.append(puntosGrupo)
                grupoJugadasParcial.append(indexGrupoJugador.count)
                for i in 0 ... indexGrupoJugador.count - 1 {
                    grupoJugadasParcial.append(indexGrupoJugador[i][0].row)
                    grupoJugadasParcial.append(indexGrupoJugador[i][1].row)
                    grupoJugadasParcial.append(matrix[indexGrupoJugador[i][0].row])
                    grupoJugadasParcial.append(matrix[indexGrupoJugador[i][1].row])
                    encontradaPareja(primero: indexGrupoJugador[i][0], segundo: indexGrupoJugador[i][1])
                }
                grupoJugadas.append(grupoJugadasParcial)
            }
            puntosJugador = puntosJugador + Int64(puntosGrupo)
            tuPuntuacion2.text = "\(puntosJugador)"
            numPulsaciones = 0
            puntosParcial.text = "0"
        }
    }
    @IBAction func borrarMovimiento2(_ sender: Any) {
        // habría que utilizar grupoJugadas y coger el último grupo jugado
        // Con este grupo actualizamos los puntos restando grupoJugadas[j][0]
        // y llamamos a borrarMovimientoIndividual las veces que diga grupoJugadas[j][0]
        // Después borro el grupoJugadas[j]
        if grupoJugadas.count > 0 {
            puntosGrupo = grupoJugadas.last![0]
            let parejasGrupo = grupoJugadas.last![1]
            puntosJugador = puntosJugador - Int64(puntosGrupo)
            tuPuntuacion2.text = "\(puntosJugador)"
            for _ in 1 ... parejasGrupo {
                borrarMovimientoIndividual()
            }
            grupoJugadas.remove(at: grupoJugadas.count - 1)
        }
    }
    func borrarMovimientoIndividual() {
        if indiceLog > 0 {
            filaLog = logJuego.last!
            celdaLog1 = filaLog [0]
            celdaLog2 = filaLog [1]
            valorLog1 = filaLog [2]
            valorLog2 = filaLog [3]
            lineasALimpiarLog = filaLog [4]
            lineaLimpiar1Log = filaLog [5]
            lineaLimpiar2Log = filaLog [6]
            if lineasALimpiarLog == 0 {                             // No hay lineas borradas
                matrix [celdaLog1] = valorLog1
                matrix [celdaLog2] = valorLog2
 //               puntosJugador = puntosJugador - 1
 //               tuPuntuacion2.text = "\(puntosJugador)"
                paresJugador = paresJugador - 1
                logJuego.remove(at: indiceLog - 1)
                indiceLog = indiceLog - 1
            } else {
                if lineasALimpiarLog == 1 {                         // Hay UNA linea borrada
                    if lineaLimpiar1Log >= lineaLimpiar2Log {       // La línea 1 es la borrada (es mayor o si es igual las dos son 0
                        celdaAInsertar = lineaLimpiar1Log * 9
                    } else {                                        // La línea 2 es la borrada (es mayor que la 1 es decir mayor que 0
                        celdaAInsertar = lineaLimpiar2Log * 9
                    }
                    for _ in 1 ... 9 {matrix.insert(0, at: celdaAInsertar) }
                    matrix [celdaLog1] = valorLog1
                    matrix [celdaLog2] = valorLog2
                    numCasillas = numCasillas + 9
                    puntosJugador = puntosJugador - 4
                    tuPuntuacion2.text = "\(puntosJugador)"
                    filasJugador = filasJugador - 1
                    logJuego.remove(at: indiceLog - 1)
                    indiceLog = indiceLog - 1
                    lineasALimpiarLog = 0
                } else {                                            // Hay DOS lineas borradas
                    
                    if lineaLimpiar1Log <= lineaLimpiar2Log {       // La línea 1 es la borrada menor: es la de más arriba
                        celdaAInsertar = lineaLimpiar1Log * 9
                    } else {                                        // La línea 2 es la borrada menor es la de más arriba
                        celdaAInsertar = lineaLimpiar2Log * 9
                    }
                    for _ in 1 ... 18 {matrix.insert(0, at: celdaAInsertar) }
                    matrix [celdaLog1] = valorLog1
                    matrix [celdaLog2] = valorLog2
                    numCasillas = numCasillas + 18
                    puntosJugador = puntosJugador - 8
                    tuPuntuacion2.text = "\(puntosJugador)"
                    filasJugador = filasJugador - 2
                    logJuego.remove(at: indiceLog - 1)
                    indiceLog = indiceLog - 1
                    lineasALimpiarLog = 0
                }
            }
            self.matrixCollectionView2.reloadData()
        }
    }
    
    
    // Flujo de ventanas
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "volverDeJugar" {
        }
    }
    
    // Variables
    
    var numCasillasOriginal: Int = 0
//    var idJugadorJugar: String?
    var numDePartidas: Int = 0
    var codigoMatrizCreada: Int32 = 0
    var idMatrizCreada: Int32 = 0
 //   var idPartidaCreada: Int = 0
 //   var nuevaPartida: Bool = false
    var idPartidaAJugar: Int = 0
    
    var matrix: [Int] = [Int]()
    var matrixOrdCalculo: [Int] = [Int]()
    var matrixOrdGrupos: [Int] = [Int]()
    var matrixOrdenador: [String] = [String]()
//    var matrixSolucionOrd: [Int] = [Int]()
    
    var pareja: Bool = false
    var primeraVez: Bool = true
    var finalTabla: Bool = false
    var finalPartida: Bool = false
    var finalGlorioso: Bool = false
    
    var aleatorio: Int = 0
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
    var puntosOrdenador: Int64 = 0
    var paresOrdenador: Int64 = 0
    var filasOrdenador: Int64 = 0
    var indiceLog: Int = 0
    var ordPuntos: Int64 = 0
    var ordFilas: Int64 = 0
    var ordPares: Int64 = 0
    var ordPuntos1: Int64 = 0
    var ordPuntos2: Int64 = 0
    var puntosValidar: Int64 = 0
    var numeroDeCeros: Int = 0
    
    var numIteraciones: Int32 = 0
    var cantidadMatrices: Int = 0
    var cantidadPartidas: Int = 0
    var versionActual: Int = 0
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
    var listaGrupoJugador: [[Int]] = [[Int]]()                 // Guarda los indexPath de las Celdas ya parejas y de la que está en juego IMPAR
    var indexGrupoJugador: [[IndexPath]] = [[IndexPath]]()     // Guarda los IndexPath de la pareja de Celdas que son PAREJA entre sí
//    var casillasGrupoJugador: [[Int]] = [[Int]]()              // Guarda los Valores de la pareja de Celdas que son PAREJA entre sí
    var grupoJugadas: [[Int]] = [[Int]]()                      // Guarda los Grupos: puntuación y las parejas de índices y valores del Grupo Jugado
    var indexGrupoParcial: [IndexPath] = [IndexPath]()
//    var casillasGrupoParcial: [Int] = [Int]()
    var grupoJugadasParcial: [Int] = [Int]()
    var valorCeldaPrimera: Int = 0
    var indiceCeldaPrimera: IndexPath = IndexPath()
    var celdaAnterior1 = IndexPath()
    var celdaAnterior2 = IndexPath()
    var valorAnterior1: Int = 0
    var valorAnterior2: Int = 0
    
    // Variables de GRUPOS
    var matrixGrupos: [Int] = [Int]()
    var matrixTrabajoGrupos: [Int] = [Int]()
    var gruposEtiqueta: [[Int]] = [[Int]]()
    var gruposEtiquetaOrdenados: [[Int]] = [[Int]]()
    var gruposA: [Int] = [Int]()
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
    var pares: Int = 0
    var valorGrupos: Int = 0
    var valorParcialGrupos: Int = 0
    var valorTotalGrupos: Int = 0
    var h: Int = 0
    var k: Int = 0
    var l: Int = 0
    var m: Int = 0
    var n: Int = 0
    var ordGruposPuntos: Int64 = 0
    var ordGruposFilas: Int64 = 0
    var ordGruposPares: Int64 = 0
    
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


}
