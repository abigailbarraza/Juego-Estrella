import wollok.game.*

object personaje {
  var property image = "personaje.png"
  var property position = game.at(25, 0)
  var puntos = 0
  var vidas = 3
  var monedas = 0
  var property multiplicador = false
  var property escudo = false
  var property relentizacion = false
  
  method vidas() = vidas
  
  method puntos() = puntos
  
  method monedas() = monedas
  
  method sumarPuntos() {
    if (multiplicador) {
      puntos += 20
      monedas += 2
    } else {
      puntos += 10
      monedas += 1
    }
  }
  
  method restarPuntos() {
    if ((puntos > 0) and (not escudo)) {
      puntos -= 10
    }
  }
  
  method sumarVidas() {
    vidas += 1
  }
  
  method restarVidas() {
    if ((not escudo) and (vidas > 0)) {
      vidas -= 1
    }
  }
  
  method moverIzq() {
    if ((position.x() > 0) and (not juego.pausado())) {
      position = position.left(1)
    }
  }
  
  method moverDer() {
    if ((position.x() < 46) and (not juego.pausado())) {
      position = position.right(1)
    }
  }
  
  method tieneMulti() {
    if (multiplicador) {
      return 2
    }
    return 1
  }
  
  method comprarMulti() {
    if ((monedas >= 15) and (not multiplicador)) {
      multiplicador = true
      monedas -= 15
      game.schedule(15000, { multiplicador = false })
      game.schedule(15000, { game.say(self, "Multiplicador desactivado") })
      game.say(self, "¡Multiplicador activado!")
    } else {
      game.say(self, "No tengo un peso")
    }
  }
  
  method comprarVidaExtra() {
    if ((monedas >= 20) and (vidas <= 5)) {
      vidas += 1
      monedas -= 20
      game.say(self, "vida extra obtenida!!")
    } else {
      game.say(self, "No tengo un peso")
    }
  }
  
  method comprarEscudo() {
    if ((monedas >= 10) and (not escudo)) {
      escudo = true
      monedas -= 10
      game.schedule(15000, { escudo = false })
      game.say(self, "¡escudo activado!")
      game.schedule(15000, { game.say(self, "escudo desactivado") })
    } else {
      game.say(self, "no tengo un peso")
    }
  }
  
  method comprarRelentizar() {
    if ((monedas >= 5) and (not relentizacion)) {
      relentizacion = true
      monedas -= 5
      game.schedule(10000, { relentizacion = false })
      game.say(self, "¡relentizador activado!")
      game.schedule(10000, { game.say(self, "relentizador desactivado") })
    } else {
      game.say(self, "no tengo un peso")
    }
  }
  
  method tieneRelentizador() {
    if (relentizacion) {
      return 3000
    }
    return 5000
  }
}

object indicadorVidas{
    method position() = game.at(58, 22)
    method text() = "Vidas: " + personaje.vidas()
    method textColor() = "black"
}

object indicadorPuntos{
    method position() = game.at(58, 19)
    method text() = "Puntos: " + personaje.puntos()
    method textColor() = "black"
}

object indicadorMonedas{
    method position() = game.at(58, 15)
    method text() = "Monedas: " + personaje.monedas()
    method textColor() = "black"
}


class ObjetoCaible {
    var property position
    method caer(){
        position = position.down(1)
    }
    method atrapado(personaje)
}
class Estrella inherits ObjetoCaible {
    const property image = "estrella.png"

    override method atrapado(personaje){
        personaje.sumarPuntos()
    }
}
class Meteorito inherits ObjetoCaible {
    const property image = "meteorito.png"
    
    override method atrapado(personaje){
        personaje.restarVidas()
    }
}
class Banana inherits ObjetoCaible {
    const property image = "banana.png"
    
    override method atrapado(personaje){
        personaje.restarPuntos()
    }
}

object juego{   
    const objetosCaen = []
    var property pausado = false
    
    method pausar(){
        pausado = true
        game.say(personaje, "PAUSADO")
    }
    
    method reanudar(){
        pausado = false
        game.say(personaje, "REANUDADO")
    }
    
    method hacerCaerYLimpiar(obj){
        obj.caer()
        if(obj.position().y()< 0 or obj.position().y() > 29 or obj.position().x() < 0 or obj.position().x() > 49){
            game.removeVisual(obj)
            objetosCaen.remove(obj)
        }
    }

    method hayColision(obj1, obj2){
        const distanciaX = (obj1.position().x() - obj2.position().x()).abs()
        const distanciaY = (obj1.position().y() - obj2.position().y()).abs()       
        return distanciaX <= 1 and distanciaY <= 1
    }
    
    method iniciar(){
        game.width(65)
        game.height(30)
        game.cellSize(20)
        game.title("Atrapar Estrellas")
        game.boardGround("fondo.png")
        game.addVisual(personaje)
        game.addVisual(indicadorVidas)
        game.addVisual(indicadorPuntos)
        game.addVisual(indicadorMonedas)

        
        game.whenCollideDo(personaje, { objeto =>
            objeto.atrapado(personaje)
            game.removeVisual(objeto)
            objetosCaen.remove(objeto)
        })

        game.onTick(3000, "generar", {
            if(not self.pausado()){
                const obj = self.elegir_entidadAleatoria(game.at(0.randomUpTo(50), 30))
                objetosCaen.add(obj)
                game.addVisual(obj)
            }
        })

        game.onTick(500, "caer", {  
            if(not self.pausado()){
                objetosCaen.forEach({ n => 
                    n.caer()
                    self.hacerCaerYLimpiar(n)
                    
                    if(self.hayColision(personaje, n)){
                        n.atrapado(personaje)
                        game.removeVisual(n)
                        objetosCaen.remove(n)
                    } 
                })
            }
        })

        game.onTick(100, "verificarEstado", { self.estadoJuego() })

        keyboard.a().onPressDo {personaje.moverIzq()}
        keyboard.d().onPressDo {personaje.moverDer()}
        keyboard.left().onPressDo {personaje.moverIzq()}
        keyboard.right().onPressDo {personaje.moverDer()}
        keyboard.p().onPressDo {
            if(self.pausado()){
                self.reanudar()
            } else {
                self.pausar()
            }
        }
        keyboard.num(1).onPressDo{personaje.comprarMulti()}
        keyboard.num(2).onPressDo{personaje.comprarEscudo()}
        keyboard.num(3).onPressDo{personaje.comprarVidaExtra()}
        keyboard.num(4).onPressDo{personaje.comprarRelentizar()}

        game.start()
    }
    
    method elegir_entidadAleatoria(pos){
        const n = 1.randomUpTo(10)

        var obj = null

        if(n >= 0 and n < 5){
            obj = new Estrella(position = pos);
        } else if(n>=5 and n<=8){
            obj = new Meteorito(position = pos);
        } else {
            obj = new Banana(position = pos);
        }
        return obj;   
    }
    
    method estadoJuego(){
        if(personaje.vidas()<=0){
            game.say(personaje, "Game Over! Puntos: " + personaje.puntos())
            game.stop()
        }
        if(personaje.puntos()>=500){
            game.say(personaje, "¡Ganaste! Puntos: " + personaje.puntos())
            game.stop()
        }
    }
}