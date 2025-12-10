import wollok.game.*
import estrellas.*

object opcionJugar {
    method position() = game.at(20, 17)
    method text() = "JUGAR (J)"
    method textColor() = "white"
}

object opcionSalir {
    method position() = game.at(20, 13)
    method text() = "SALIR (S)"
    method textColor() = "white"
}

object opcionVerPuntajes{
    method position()= game.at(20,15)
    method text()="VER PUNTAJES (V)"
    method textColor()="white"
}

object menuPrincipal {
    method iniciar() {
        game.width(50)
        game.height(30)
        game.cellSize(20)
        game.title("Atrapar Estrellas - Menú")
        game.boardGround("menu.png")  
        
        game.addVisual(opcionJugar)
        game.addVisual(opcionVerPuntajes)
        game.addVisual(opcionSalir)
        
        keyboard.j().onPressDo({
            self.iniciarJuego()
        })
        
       
        keyboard.s().onPressDo({
            game.stop()
        }) 

        keyboard.v().onPressDo{tablaPuntaje.mostrarTop5()}
        
    }
    
    method iniciarJuego() {
        game.removeVisual(opcionJugar)
        game.removeVisual(opcionSalir)
        game.removeVisual(opcionVerPuntajes)
        game.start()
    }
    

}

class Puntaje{
    var property puntos

    method mostrar() {
        return  puntos + " pts"
    }

}
object tablaPuntaje {
  const property todosPuntajes=[]
  const property top5=[]

  method agregarPuntajes(puntaje){
    todosPuntajes.add(puntaje)
    
  }
method  actualizarPuntajes(puntajes){
    top5.clear()
        
    const mejores = puntajes
        .sortedBy({ p1, p2 => p1.puntos() > p2.puntos() })
        .take(5)
    
        mejores.forEach({ p => top5.add(p) })
    }
method mostrarTop5(){
    console.println("TOP 5 PUNTAJES")

    if(top5.isEmpty()){
        console.println("NO HAY PUNTAJES TODAVIA")
    } else{
        var posicion = 1
        top5.forEach({ puntaje =>
        console.println(posicion.toString() + ". " + puntaje.mostrar())
        posicion += 1})
    }
}
}


