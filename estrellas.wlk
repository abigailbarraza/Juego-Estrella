import wollok.game.*

object personaje {
    var property image = "personaje.png"
    var property position = game.at(5,3)
    
    var puntos = 0
    var vidas = 3
    var monedas = 0
    var multiplicador = false
    var escudo = false
    var relentizacion = false
    
    method sumarPuntos() {
        puntos = puntos + 30 * self.tieneMulti()
        monedas = monedas + 1
    }
    
    method restarPuntos() {
        puntos = puntos - 10
    }
    
    method sumarVidas() {
        vidas = vidas + 1
    }
    
    method restarVidas() {
        if (not escudo) {
            vidas = vidas - 1
        }
    }
    
    method moverIzq() {
        position = position.left(1)
    }
    
    method moverDer() {
        position = position.right(1)
    }
    
    method tieneMulti() {
        if (multiplicador) {
            return 2
        } 
        return 1
    }
    
    method comprarMulti() {
        if (monedas >= 15) {
            multiplicador = true
            monedas = monedas - 15
            game.schedule(5000, { multiplicador = false })
        } else {
            game.say(self, "No hay suficiente dinero disponible")
        }
    }

    method comprarVidaExtra() {
        if (monedas >= 20 and vidas <= 3) {
            vidas += 1
            monedas -= 20
        } else {
            game.say(self, "No hay suficiente dinero disponible")
        }
    }
    
    method comprarEscudo() {
        if (monedas >= 10) {
            escudo = true
            monedas -= 10
            game.schedule(5000, { escudo = false })
        } else {
            game.say(self, "no hay suficiente dinero disponible")
        }
    }
    
    method comprarRelentizar() {
        if (monedas >= 5) {
            relentizacion = true
            monedas -= 5
        } else {
            game.say(self, "no hay suficiente dinero disponible")
        }
    }

    method tieneRelentizador() {
        if (relentizacion) {
            return 1000
        }
        return 1500
    }
}

class Estrella {
    var property position
    const property image = "estrella.png"
    
    method caer() {
        position = position.down(1)
    }
    
    method atrapado(personaje) {
        personaje.sumarPuntos()
    }
}

class Meteorito {
    var property position
    const property image = "meteorito.jpg"

    method caer() {
        position = position.down(1)
    }
    
    method atrapado(personaje) {
        personaje.restarVidas()
    }
}

class Banana {
    var property position
    const property image = "banana.png"

    method caer() {
        position = position.down(1)
    }
    
    method atrapado(personaje) {
        personaje.restarPuntos()
    }
}

object juego {
    const objetosCaen = []
    
    method iniciar() {
        game.width(20)
        game.height(10)
        game.cellSize(20)
        game.title("Atrapar Estrellas")
        game.addVisual(personaje)
        
        game.whenCollideDo(personaje, { objeto =>
            objeto.atrapado(personaje)
            game.removeVisual(objeto)
            objetosCaen.remove(objeto)
        })

        game.onTick(1000, "generar", {
            const obj = self.elegir_entidadAleatoria(game.at(0.randomUpTo(20), 10))
            objetosCaen.add(obj)
            game.addVisual(obj)  
        })

        game.onTick(personaje.tieneRelentizador(), "caer", { 
        self.estadoJuego()
        })

        keyboard.a().onPressDo { personaje.moverIzq() }
        keyboard.d().onPressDo { personaje.moverDer() }
        keyboard.num(1).onPressDo { personaje.comprarMulti() }
        keyboard.num(2).onPressDo { personaje.comprarEscudo() }
        keyboard.num(3).onPressDo { personaje.comprarVidaExtra() }
        keyboard.num(4).onPressDo { personaje.comprarRelentizar() }

        game.start()
    }
    
    method elegir_entidadAleatoria(pos) {
        const n = 1.randomUpTo(10)
        var obj = null

        if (n >= 0 and n < 5) {
            obj = new Estrella(position = pos)
        } else if (n >= 5 and n <= 8) {
            obj = new Meteorito(position = pos)
        } else {
            obj = new Banana(position = pos)
        }
        return obj
    }
    
    method estadoJuego() {
        if (personaje.vidas <= 0) {
            game.say(personaje, "Game Over! Puntos: " + personaje.puntos)
            game.stop()
        }
        if (personaje.puntos >= 500) {
            game.say(personaje, "¡Ganaste! Puntos: " + personaje.puntos)
            game.stop()
        }
    }
}