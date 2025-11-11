import wollok.game.*

object personaje{
    var property image = "personaje.png"
    var property position = game.at(25, 0)
    
    var   puntos =0
    var   vidas = 3
    var   monedas = 0
    var  property multiplicador = false
    var  property escudo = false
    var  property relentizacion = false

    method vidas() = vidas
    method puntos() = puntos
    method monedas() = monedas


    method sumarPuntos(){
        if (multiplicador){
            puntos = puntos + 20
            monedas = monedas + 2
        } else {
            puntos = puntos + 10
            monedas = monedas + 1
        }
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
        if(position.x()>0){
            position=position.left(1)
        }
    }
    method moverDer(){
        if(position.x()< 100){
            position=position.right(1)
        }
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
            game.schedule(7000, {multiplicador = false})
        } else {
            game.say(self, "No tengo un peso")
        }
    }

    method comprarVidaExtra(){
        if(monedas >= 20 and vidas <= 5){
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
            game.schedule(7000, {escudo = false})
        } else {
            game.say(self,"no tengo un peso")
        }
    }
    method comprarRelentizar(){
        if(monedas>=5){
            relentizacion=true
            monedas -= 5
            game.schedule(8000, {relentizacion = false})
    } else{
        game.say(self, "no tengo un peso")
    }
    }

    method tieneRelentizador(){
        if(relentizacion){
            return 3000
        }
        return 5000

    }
}
object indicadorVidas{
    method position() = game.at(0, 29)
    method text() = "Vidas: " + personaje.vidas()
    method textColor() = "white"

}
object indicadorPuntos{
    method position() = game.at(40, 29)
    method text() = "Puntos: " + personaje.puntos()
    method textColor() = "white"
}
object indicadorMonedas{
    method position() = game.at(20, 29)
    method text() = "Monedas: " + personaje.monedas()
    method textColor() = "white"
}


object iconoMultiplicador {
    method position() = game.at(1, 2)
    method text() = "[1] Multi x2 - 15"
    method textColor() = if(personaje.monedas() >= 15) "green" else "white"
}

object iconoEscudo {
    method position() = game.at(15, 2)
    method text() = "[2] Escudo - 10"
    method textColor() = if(personaje.monedas() >= 10) "green" else "white"
}

object iconoVidaExtra {
    method position() = game.at(28, 2)
    method text() = "[3] Vida+ - 20"
    method textColor() = if(personaje.monedas() >= 20 and personaje.vidas() <= 5) "green" else "white"
}

object iconoRelentizar {
    method position() = game.at(41, 2)
    method text() = "[4] Lento - 5"
    method textColor() = if(personaje.monedas() >= 5) "green" else "white"
}
class Estrella{
    var property position
    const property image ="estrella.png"
    
    method caer(){
        position = position.down(1)
    }
    method atrapado(personaje){
        personaje.sumarPuntos()
    }
}
class Meteorito{
    var property position
    const property image="meteorito.png"

    method caer(){
        position= position.down(1)
    }
    method atrapado(personaje){
        personaje.restarVidas()
    }
}
class Banana{
    var property position
    const property image ="banana.png"

    method caer(){
        position = position.down(1)
    }
    method atrapado(personaje){
        personaje.restarPuntos()
    }
}
object juego{
    const objetosCaen = []
    method hacerCaerYLimpiar(obj){
    obj.caer()
    if(obj.position().y()< 0){
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
        game.width(50)
        game.height(30)
        game.cellSize(20)
        game.title("Atrapar Estrellas")
        game.boardGround("fondo.png")
        const rain = game.sound("lluvia.mp3")
         rain.shouldLoop(true)
        game.addVisual(personaje)
        game.addVisual(indicadorVidas)
        game.addVisual(indicadorPuntos)
        game.addVisual(indicadorMonedas)
        game.addVisual(iconoMultiplicador)
        game.addVisual(iconoEscudo)
        game.addVisual(iconoVidaExtra)
        game.addVisual(iconoRelentizar)
        
        game.whenCollideDo(personaje, { objeto =>
            objeto.atrapado(personaje)
            game.removeVisual(objeto)
            objetosCaen.remove(objeto)

    })

        game.onTick(3000, "generar", {
        const obj = self.elegir_entidadAleatoria(game.at(0.randomUpTo(50), 30))
        objetosCaen.add(obj)
        game.addVisual(obj)  
    })

        game.onTick(500, "caer", {  
        objetosCaen.forEach({ n => 
            n.caer()
            self.hacerCaerYLimpiar(n)
            
            if(self.hayColision(personaje, n)){
                n.atrapado(personaje)
                game.removeVisual(n)
                objetosCaen.remove(n)
        } 
    }) 
})


        self.estadoJuego()

        keyboard.a().onPressDo {personaje.moverIzq()}
        keyboard.d().onPressDo {personaje.moverDer()}
        keyboard.left().onPressDo {personaje.moverIzq()}
        keyboard.right().onPressDo {personaje.moverDer()}
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