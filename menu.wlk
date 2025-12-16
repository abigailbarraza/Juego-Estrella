import wollok.game.*
import estrellas.*

object opcionJugar {
    method position() = game.at(28, 17)
    method text() = "JUGAR (J)"
    method textColor() = "white"

}

object opcionSalir {
    method position() = game.at(28, 13)
    method text() = "SALIR (S)"
    method textColor() = "white"

}

object opcionVerPuntajes{
    method position()= game.at(28,15)
    method text()="VER PUNTAJES (V)"
    method textColor()="white"

}

object menuPrincipal {
    method iniciar() {
        game.title("Atrapar Estrellas - Menú")
        game.boardGround("fondo.png")  
        
        game.addVisual(opcionJugar)
        game.addVisual(opcionVerPuntajes)
        game.addVisual(opcionSalir)
        
        keyboard.j().onPressDo({
            self.iniciarJuego()

 })
        keyboard.s().onPressDo({
            game.stop()
        }) 

        keyboard.v().onPressDo({
            self.mostrarPantallaPuntajes()
        })
    }
    
    method iniciarJuego() {
        game.clear()
        juego.iniciar()
    }
    
    method mostrarPantallaPuntajes() {
        game.clear()
        game.title("Top 5 Puntajes")
        game.boardGround("fondo.png")
        
        const titulo = new IndicadorFijo(position = game.at(22, 25), text = "TOP 5 PUNTAJES", textColor = "white")
        game.addVisual(titulo)
        
        if(tablaPuntaje.top5().isEmpty()) {
            const mensaje = new IndicadorFijo(position = game.at(18, 18), text = "NO HAY PUNTAJES TODAVIA", textColor = "white")
            game.addVisual(mensaje)
        } else {
            var posY = 20
            var posicion = 1
            tablaPuntaje.top5().forEach({ puntaje =>
                const textoMostrar = posicion.stringValue() + ". " + puntaje.puntos().stringValue() + " pts"
                const linea = new IndicadorFijo(
                    position = game.at(28, posY), 
                    text = textoMostrar, 
                    textColor = "white"
                )
                game.addVisual(linea)
                posY -= 2
                posicion += 1
            })
        }
        
        const volver = new IndicadorFijo(position = game.at(28, 5), text = "Apreta M para volver al menu", textColor = "white")
        game.addVisual(volver)
        
        keyboard.m().onPressDo({
            game.clear()
            self.iniciar()
        })
    }
}

class Puntaje{
    const property puntos

    method mostrar() {
        return puntos.stringValue() + " pts"
    }
}

object tablaPuntaje {
  const property todosPuntajes=[]
  const property top5=[]

  method agregarPuntajes(puntaje){
    todosPuntajes.add(puntaje)
  }
  
  method actualizarPuntajes(puntajes){
    top5.clear()
    const mejores = puntajes
        .sortedBy({ p1, p2 => p1.puntos() > p2.puntos() })
        .take(5)
    mejores.forEach({ p => top5.add(p) })
  }
  
  method mostrarTop5(){
    console.println("TOP 5 PUNTAJES")
    if(top5.isEmpty()){
        console.println("TODAVIA NO HAY PUNTAJES")
    } else{
        var posicion = 1
        top5.forEach({ puntaje =>
            console.println(posicion.toString() + ". " + puntaje.mostrar())
            posicion += 1
        })
    }
  }
}