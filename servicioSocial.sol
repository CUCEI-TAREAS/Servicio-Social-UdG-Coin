pragma solidity ^0.4.18;
//Enrique Coronado Naranjo

//Este contrato es para controlar los medios de pago (criptomoneda con valor de tiempo)
//de los prestadores de servicio UDG

contract SocialService{
    //variables
    address public student;
    address public judgeschool;
    address public judgeservice;
    address public judgeinst1; // validacion de personal de empresa o institucion
    address public judgeinst2; // validacion de personal de empresa o institucion
    uint public validation;    // contador de validaciones
    uint public VI;            // VI y VS indicadores para que no voten mas de una vez
    uint public VS;
    //Estado del servicio, Aceptado o no Aceptado
    enum State { notAccept, Accept }
    State public state;
    //Estado del pago, se realiza o no se realiza 
    enum PayStatus { notExecuted, Executed }
    PayStatus public payStatus;
    
    //contructor
    function SocialService ( address _judgeschool,
                             address _judgeservice,
                           // address _judgeinst1,
                             address _judgeinst2) public {
                                //El estudiante genera la llamada
                                student = msg.sender;
                                judgeschool = _judgeschool;
                                judgeservice = _judgeservice;
                               // judgeinst1 = _judgeinst1;
                                judgeinst2 = _judgeinst2;
    }
    //Aqui el estudiante eligira una de las opciones que vera
    function selectService () public payable {
        //comprobamos que el que esta realizando la solicitud sea el estudiante
        require( msg.sender == student );
    }
    
    //Aqui se acepta o no, la opcion de servicio elegido por el Estudiante
    function confirmService (uint opt) {
        //comprobamos que el que acepta la solicitud sea el encargado del proceso
        //del servico
        require ( msg.sender == judgeservice );
        //si se ingresa un "1" en "opt" el servicio elegido por el Estudiante es Aceptado
        //en caso contrario se deniega el acceso al servicio elegido
        if ( opt == 1 ){
            state = State.Accept;
            opt = 0;
        } else {
            state = State.notAccept;
        }
    }
    
    // Se valida que se presto el servicio correspondiente por parte de la empresa
    // o institucion
    function validateInst (uint respinst) {
        // Se verifica que sea el encarcado de la institucion o empresa
        require ( msg.sender == judgeinst2);
        //para que se pueda validar este servicio prestado a la institucion o empresa
        //este tuvo que haber sido aceptado anteriormente
        require ( state == State.Accept );
        // si la respuesta de la institucion (respinst) o empresa es 1, la empresa
        //esta validando el servicio realizado
        if( respinst == 1 && VI == 0 ){
            validation = validation + 1;
            // se resetea la respuesta para evitar que se quede en 1 y active los
            // indicadoros Accept y Executed
            respinst == 0;
        } else {
            validation = validation + 0;
        }
        //agregamos un 1 al indicador para que no vuelva a validar
        VI = 1;
    }
    
    // Valida la persona encargada de los procesos de servicio
    function validateService (uint respser) {
        // Se verifica que sea el encarcado de los procesos de servicio
        require ( msg.sender == judgeservice );
        //para que se pueda validar este servicio prestado a la institucion o empresa
        //este tuvo que haber sido aceptado anteriormente
        require ( state == State.Accept );
        // si la respuesta de la persona de servicio (respser) es 1, la persona
        //esta validando el servicio realizado
        if( respser == 1 && VS == 0){
            validation = validation + 1;
            respser = 0;
        } else {
            validation = validation + 0;
        }
        //agregamos un 1 al indicador para que no vuelva a validar
        VS = 1;
    }
    
    // revisamos que el numero de validaciones se cumpla
    function validateJudges(){
        // si se cumple el numero de validaciones se puede ejecutar el pago
        // de servicio
        if ( validation == 2 ){
            payStatus = PayStatus.Executed;
        } else {
            payStatus = PayStatus.notExecuted;
        }
        
    }
    
    
    // La institucion o empresa propone pago por servicio prestado
    // este pago queda en espera
    function giveCripto () payable {
        // Se verifica que sea la institucion o empresa
        // falta agregar indicador para que no se pueda mover la cantidad
        require ( msg.sender == judgeinst2 );
    }
    
    // se muestra la cantidad de ether que se propone pagar en la transaccion 
    //que se realizo, esperando validacion para poder ser tranferida a la cuenta
    //de alumno
    function showBalance () public constant returns ( uint ){
        return this.balance;
    }
    
    // la institucion o empresa puede cancelar el pago que se prensento
    // ***falta agregar que se valide la cancelacion por parte de la escuela y
    // encargado de servicio social para evitar que la institucion o empresa
    // cancele la transaccion sin justificacion
    function payCancel () {
        require ( msg.sender == judgeinst2 );
        // se regresa la cantidad propuesta a la institucion o empresa
        judgeinst2.transfer(this.balance);
    }
    
    //ya que esta todo validado se confirma el pago por parte de la institucion
    // o empresa
    function confirmCripto() {
        // se valida que sea la institucion o empresa la que de la confirmacion de pago,
        //Que la institucion o empresa  haya sido validada anteriormente y Que
        // se tengan las validaciones necesarias para poder realizar el pago
        require ( msg.sender == judgeinst2 );
        require ( state == State.Accept );
        require ( payStatus == PayStatus.Executed );
        // si cumple se efectua el pago tranfiriendo la cantidad al estudiante por payStatus
        //por sus servicios prestados
        student.transfer(this.balance);
        // se reician los parametros
        state = State.notAccept;
        payStatus = PayStatus.notExecuted;
        validation = 0;
        VI = 0;
        VS = 0;
    }
    
    
}
