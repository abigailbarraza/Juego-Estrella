import wollok.game.*
import menu.*

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
  
  method reiniciar() {
    position = game.at(25, 0)
    puntos = 0
    vidas = 3
    monedas = 0
    multiplicador = false
    escudo = false
    relentizacion = false
  }
  
  method sumarPuntos() {
    if (multiplicador) {
      puntos += 20
      monedas += 2
    } else {
      puntos += 10
      monedas += 1
    }
  }
  
  method sumaMonedas(){
    monedas += 10
  }

  method restarPuntos() {
    if ((puntos >= 10) and (not escudo)) {
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

class Indicador {
  const property position
  const property text
  const property textColor
}

class IndicadorDinamico {
  const property position
  const closure
  const property textColor
  
  method text() = closure.apply()
}

class ObjetoCaible {
    var property position
    const property image
    method caer(){
        position = position.down(1)
    }
    method atrapado(personaje)
}

class Estrella inherits ObjetoCaible(image = "estrella.png") {
    override method atrapado(personaje){
        personaje.sumarPuntos()
    }
}

class Meteorito inherits ObjetoCaible(image = "meteorito.png") {
    override method atrapado(personaje){
        personaje.restarVidas()
    }
}

class Banana inherits ObjetoCaible(image = "banana.png") {
    override method atrapado(personaje){
        personaje.restarPuntos()
    }
}

class Monedas inherits ObjetoCaible(image= "moneda.png"){
    override method atrapado(personaje){
        personaje.sumaMonedas()
    }
}

class Vidaas inherits ObjetoCaible(image = "vidaas.png"){
    override method atrapado(personaje){
        personaje.sumarVidas()
    }
}

object juego{   
    const objetosCaen = []
    var property pausado = false
    var juegoTerminado = false
    
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
        personaje.reiniciar()
        objetosCaen.clear()
        pausado = false
        juegoTerminado = false  
        
        
        game.title("Atrapar Estrellas")
        game.boardGround("fondo.png")
        
        game.addVisual(personaje)
        
       
        const indicadorVidas = new IndicadorDinamico(
            position = game.at(58, 22), 
            closure = {  personaje.vidas().stringValue() }, 
            textColor = "white"
        )
        const indicadorPuntos = new IndicadorDinamico(
            position = game.at(58, 19), 
            closure = { personaje.puntos().stringValue() }, 
            textColor = "white"
        )
        const indicadorMonedas = new IndicadorDinamico(
            position = game.at(58, 15), 
            closure = {  personaje.monedas().stringValue() }, 
            textColor = "white"
        )
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
                const obj = self.elegir_entidadAleatoria(game.at(0.randomUpTo(45), 30))
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
    }
    
method elegir_entidadAleatoria(pos){
    const n = 1.randomUpTo(100) 
    var obj = null

    if(n >= 1 and n <= 40){
        obj = new Estrella(position = pos); 
    } else if(n >= 41 and n <= 60){
        obj = new Banana(position = pos); 
    } else if(n >= 61 and n <= 80){
        obj = new Meteorito(position = pos); 
    } else if(n >= 81 and n <= 90){
        obj = new Monedas(position = pos); 
    } else {
        obj = new Vidaas(position = pos); 
    }
    return obj;   
}
    
    method estadoJuego(){
        
        if(not juegoTerminado) {
            if(personaje.vidas()<=0){
                juegoTerminado = true  
                
               
                const puntajeFinal = personaje.puntos()
                tablaPuntaje.agregarPuntajes(new Puntaje(puntos = puntajeFinal))
                tablaPuntaje.actualizarPuntajes(tablaPuntaje.todosPuntajes())
                
                console.println("Puntaje guardado: " + puntajeFinal)
                console.println("Total de puntajes: " + tablaPuntaje.todosPuntajes().size())
                
                game.say(personaje, "Game Over! Puntos: " + puntajeFinal)
                game.schedule(2000, { self.volverAlMenu() })
            }
            if(personaje.puntos()>=500){
                juegoTerminado = true  
                
                const puntajeFinal = personaje.puntos()
                tablaPuntaje.agregarPuntajes(new Puntaje(puntos = puntajeFinal))
                tablaPuntaje.actualizarPuntajes(tablaPuntaje.todosPuntajes())
                
                console.println("Puntaje guardado: " + puntajeFinal)
                console.println("Total de puntajes: " + tablaPuntaje.todosPuntajes().size())
                
                game.say(personaje, "¡Ganaste! Puntos: " + puntajeFinal)
                game.schedule(2000, { self.volverAlMenu() })
            }
        }
    }
    
    method volverAlMenu() {
        game.clear()
        menuPrincipal.iniciar()
    }
}