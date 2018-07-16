//Nota 4 cuatro
//Test: faltan test de varios puntos, el ultimo test falla
//1.1) R no hay un buen manejo del super, duplicando código
//1.2) MB
//2.1) R muy desprolijo, no usa la superclase para las cosas en comun, algunas funcionalidades están mal
//2.2) OK
//2.3) B tiene un poco de código duplicado y problemas de delegacion
//3.1) MB
//3.2) R (confunde map con filter)
//3.3) B
//3.4) R código duplicado

class Casa{
	var habitaciones=#{}
	var flia=#{}
	method habitaciones()=habitaciones
	method integrantes()=flia 
	method nuevaHabitacion(habitacion){
		habitaciones.add(habitacion)
	}
	method habitacionesOcupadas(){
		return habitaciones.filter({habitacion=>habitacion.estaOcupada()})
	}
	method responsablesDeLaCasa(){
		//TODO: acá hay que usar map
		return self.habitacionesOcupadas().filter({habitacion=>habitacion.ocupanteMasViejo()})
	}
	method nivelDeConfort(){
		return flia.sum({integrante=>integrante.nivelDeConfort(self)})
	}
	method nivelDeConfortPromedio(){
		return self.nivelDeConfort()/flia.size()
	}
	method familiaAGusto(){
		return self.nivelDeConfortPromedio()>40 and flia.all({integrante=>integrante.estoyAGusto()})
	}
}
class IntegranteFamiliar{
	var sabeCocinar
	var edad
	var habitacionActual
	var hogar
	method sabeCocinar()=sabeCocinar
	method edad()=edad
	
	//TODO: Mejorar los nombres: los mensajes se suelen poner en 3ra persona porque lo más comun es que otro objeto sea el emisor
	//TODO: Además hay mezcla de estilos: algunos en 3ra persona, otros en primera, algunos en infinitivo y otros conjugados
	method soyPeque(){
		return edad<=4
	}
	method aprenderACocinar(){
		sabeCocinar=true
	}
	method habitacionActual()=habitacionActual
	method cambioDeHabitacion(h){
		habitacionActual=h
	}
	//TODO: requerimiento inventado
	method mudanza(casa){
		hogar=casa
		casa.integrantes().add(self)
	}
	method nivelDeConfort(casa){
		return casa.habitaciones().sum({habitacion=>habitacion.nivelDeConfort(self)})
	}
	//TODO: acá debería estar el código de si puede entrar a alguna habitacion
	//quedó duplicado en todas las subclases
	method estoyAGusto()
	
	method puedoEntrarEnUna(){
		return hogar.habitaciones().any({habitacion=>habitacion.puedeEntrar(self)})
	}
}
class IntegranteObsesivo inherits IntegranteFamiliar{
	override method estoyAGusto(){
		return self.puedoEntrarEnUna() and hogar.habitaciones().all({habitacion=>habitacion.ocupantes().size()<=2})
	}
}
class IntegranteGolozo inherits IntegranteFamiliar{
	override method estoyAGusto(){
		return self.puedoEntrarEnUna() and hogar.integrantes().any({integrante=>integrante.sabeCocinar()})
	}
}
class IntegranteSencillo inherits IntegranteFamiliar{
	override method estoyAGusto(){
		return self.puedoEntrarEnUna() and hogar.habitaciones().size()>hogar.integrantes().size()
	}
}
class Habitacion{
	
	//TODO: variable innecesaria
	var confortBase=10
	var ocupantes=#{}
	method noEstaEnUnaHabitacion(persona){
		return  persona.habitacionActual()==null
	}
	method nivelDeConfort(persona)=confortBase
	method entrar(persona){
		if(self.puedeEntrar(persona))
		//TODO: indentar el código
		{ocupantes.add(persona)if(self.noEstaEnUnaHabitacion(persona))
			//TODO: Código duplicado en ambas ramas del if
			//TODO: Delegar mejor: persona.salirDeHabitacion()
			{persona.cambioDeHabitacion(self)}else{persona.habitacionActual().seFue(persona) persona.habitacionActual().cambioDeHabitacion(self)}
			
		} 
		else{self.error("Habitacion Ocupada")}
	}
	//TODO: acá hay que verificar si la habitacion está vacia
	method puedeEntrar(persona)
	method ocupantes()=ocupantes
	method seFue(persona){ocupantes.remove(persona) persona.cambioDeHabitacion(null)}
	method estaOcupada(){
		return not ocupantes.isEmpty()
	}
	method ocupanteMasViejo(){
		return ocupantes.max({ocupante=>ocupante.edad()})
	}
}

class HabitacionDeUsoGral inherits Habitacion{
	override method puedeEntrar(persona)=true
}

class Dormitorio inherits Habitacion{
	var duenhos=#{}
	override method nivelDeConfort(persona){
		return 
		if(self.esDuenho(persona)){
			//TODO: usar super(). El super debería estar por fuera del if ya que se necesita en ambas ramas
			confortBase+10/duenhos.size()
		}
		else{
			super(persona)
		}
	}
	override method puedeEntrar(persona){
		//TODO: no, puede ser que en ocupantes haya más personas que los duenios y debería ser válido
		//TODO: Tampoco se está verificando que la habitación está vacía (requerido en el enunciado y los test entregados por la catedra)
		return duenhos==ocupantes or self.esDuenho(persona)
	}
	method esDuenho(persona){
		return duenhos.contains(persona)
	}
}
//TODO: Por qué si todo está en español esta habitacion lo ponés en castellano?
class Bathroom inherits Habitacion{
	override method nivelDeConfort(persona){
		return 
		//TODO: usar super(). El super debería estar por fuera del if ya que se necesita en ambas ramas
		if(persona.soyPeque()){confortBase+2}
		else{confortBase+4}
	}
	
	//TODO: Ocupantes isEmpty debería estar en la superclase
	override method puedeEntrar(persona){
		return ocupantes.any({ocupante=>ocupante.soyPeque()}) or ocupantes.isEmpty()
	}
	
	
}
class Cocina inherits Habitacion{
	var dimension
	override method nivelDeConfort(persona){
		//TODO: usar super(). El super debería estar por fuera del if ya que se necesita en ambas ramas
		return if(persona.sabeCocinar()){
			confortBase+porcentajeCocina.porcentaje()*dimension/100
		}
		else{super(persona)}
	}
	override method puedeEntrar(persona){
		return if(persona.sabeCocinar()){
			not ocupantes.any({ocupante=>ocupante.sabeCocinar()})
		}
		else{true}
	}
}

object porcentajeCocina{
	var valor=10
	method porcentaje()=valor
	method cambiarPorcentaje(n){
		valor=n
	}
}