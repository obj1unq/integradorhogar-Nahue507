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
	method mudanza(casa){
		hogar=casa
		casa.integrantes().add(self)
	}
	method nivelDeConfort(casa){
		return casa.habitaciones().sum({habitacion=>habitacion.nivelDeConfort(self)})
	}
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
	var confortBase=10
	var ocupantes=#{}
	method noEstaEnUnaHabitacion(persona){
		return  persona.habitacionActual()==null
	}
	method nivelDeConfort(persona)=confortBase
	method entrar(persona){
		if(self.puedeEntrar(persona))
		{ocupantes.add(persona)if(self.noEstaEnUnaHabitacion(persona))
			{persona.cambioDeHabitacion(self)}else{persona.habitacionActual().seFue(persona) persona.habitacionActual().cambioDeHabitacion(self)}
			
		} 
		else{self.error("Habitacion Ocupada")}
	}
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
			confortBase+10/duenhos.size()
		}
		else{
			super(persona)
		}
	}
	override method puedeEntrar(persona){
		return duenhos==ocupantes or self.esDuenho(persona)
	}
	method esDuenho(persona){
		return duenhos.contains(persona)
	}
}
class Bathroom inherits Habitacion{
	override method nivelDeConfort(persona){
		return 
		if(persona.soyPeque()){confortBase+2}
		else{confortBase+4}
	}
	override method puedeEntrar(persona){
		return ocupantes.any({ocupante=>ocupante.soyPeque()}) or ocupantes.isEmpty()
	}
	
	
}
class Cocina inherits Habitacion{
	var dimension
	override method nivelDeConfort(persona){
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