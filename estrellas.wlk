import wollok.game.*

object personaje{
    const property image = ""
    var property position = game.at(1,5)
    
    var puntos =0
    var vidas = 3
    var monedas = 0
    var multiplicador = false
    var escudo = false
  
    method sumarPuntos(){
        puntos = puntos + 30 * self.tieneMulti()
        monedas = monedas + 1
    }
    method restarPuntos(){
        puntos = puntos - 10
    }
    method sumarVidas(){
        vidas = vidas + 1
    }
    method restarVidas(){
        if(not escudo){
            vidas = vidas - 1
        }
    }
    method moverIzq(){
        position = position.left(1)
    }
    method moverDer(){
        position = position.right(1)
    }
    method tieneMulti(){
        if(multiplicador){
            return 2
        } 
        return 1
    }
    method comprarMulti(){
        if(monedas >= 15 ){
            multiplicador = true
            monedas = monedas - 15
            game.schedule(5000, {multiplicador = false})
        } else {
            game.say(self, "No tengo un peso")
        }
    }

    method comprarVidaExtra(){
        if(monedas >= 20 and vidas <= 3){
            vidas += 1
            monedas -= 20
        } else {
            game.say(self, "No tengo un peso")
        }
    }
    method comprarEscudo(){
        if(monedas>=10){
            escudo = true
            monedas -= 10
            game.schedule(5000, {escudo = false})
        } else {
            game.say(self,"no tengo un peso")
        }
    }
    method comprarRelentizar(){}
}

class Estrella{
    var property position
    const property image 
    
    method caer(){
        position = position.down(1)
    }
}

object juego{
    method iniciar(){
        game.width(20)
        game.height(10)
        game.cellSize(20)
        game.title("Atrapar Estrellas")

        keyboard.a().onPressDo {personaje.moverIzq()}
        keyboard.d().onPressDo {personaje.moverDer()}

        keyboard.num(1).onPressDo{personaje.comprarMulti()}
        keyboard.num(2).onPressDo{personaje.comprarEscudo()}
        keyboard.num(3).onPressDo{personaje.comprarVidaExtra()}
        keyboard.num(4).onPressDo{personaje.comprarRelentizar()}
   
    }
}