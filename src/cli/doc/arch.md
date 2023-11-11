- mcli
    1. editor
    2. controller
    3. commander

think mcli as a module which has a input port and two output ports (like stdin,stdout,stderr). Inside mcli, there are three modules like mcli-module, they have the same I/O ports. ports are single-direction channels used to send or receive string.