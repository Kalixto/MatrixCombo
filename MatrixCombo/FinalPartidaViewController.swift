//
//  FinalPartidaViewController.swift
//  MatrixCombo
//
//  Created by Edu Ardo on 16/5/18.
//  Copyright © 2018 neteamador. All rights reserved.
//

import UIKit
import CoreData

class FinalPartidaViewController: UIViewController {
    var partidaComboSeleccionada: PartidasCombo!
    var jugadorSeleccionado: Jugadores!
    var numDePartidaJugada: Int32 = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        numDePartidaJugada = partidaComboSeleccionada.codigoPartida
        let tipoPartida = partidaComboSeleccionada.tipoPartida
        switch tipoPartida {
        case 1: idPartida.text = "facilón"
        case 2: idPartida.text = "mimosín"
        case 3: idPartida.text = "regu"
        case 4: idPartida.text = "desafío"
        case 5: idPartida.text = "ikea"
        case 6: idPartida.text = "tormenta"
        case 7: idPartida.text = "borrasca"
        case 8: idPartida.text = "ciclón"
        case 9: idPartida.text = "huracán"
        case 10: idPartida.text = "tsunami"
        default:
            idPartida.text = "edu"
        }
        nombreJugador.text = partidaComboSeleccionada.idJugador
        puntosJugadorText.text = "\(partidaComboSeleccionada.puntosJugador)"
        puntosOrdenadorText.text = "\(partidaComboSeleccionada.puntosOrdenador)"
        paresJugadorText.text = "\(partidaComboSeleccionada.paresJugador)"
        paresOrdenadorText.text = "\(partidaComboSeleccionada.paresOrdenador)"
        lineasJugadorText.text = "\(partidaComboSeleccionada.filasBlancoJugador)"
        lineasOrdenadorText.text = "\(partidaComboSeleccionada.filasBlancoOrdenador)"
        grupoJugadorText.text = "\(partidaComboSeleccionada.mayorGrupoJugador)"
        grupoOrdenadorText.text = "\(partidaComboSeleccionada.mayorGrupoOrdenador)"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func irAtras(_ sender: Any) {
        self.performSegue(withIdentifier: "volverDeJugar", sender: numDePartidaJugada)
    }
    @IBOutlet weak var nombreJugador: UILabel!
    @IBOutlet weak var idPartida: UILabel!
    @IBOutlet weak var puntosJugadorText: UILabel!
    @IBOutlet weak var puntosOrdenadorText: UILabel!
    @IBOutlet weak var paresJugadorText: UILabel!
    @IBOutlet weak var paresOrdenadorText: UILabel!
    @IBOutlet weak var lineasJugadorText: UILabel!
    @IBOutlet weak var lineasOrdenadorText: UILabel!
    @IBOutlet weak var grupoJugadorText: UILabel!
    @IBOutlet weak var grupoOrdenadorText: UILabel!
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "volverDeJugar" {
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
