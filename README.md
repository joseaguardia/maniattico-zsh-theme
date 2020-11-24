# maniattico.zsh-theme

## Tema para ZSH basado en agnoster.

Vista general: hostname, IP, entorno y ruta actual
![captura1](https://github.com/joseaguardia/maniattico-zsh-theme/blob/master/images/zsh01.png?raw=true)

Iconos para: error en el último comando, trabajo en segundo plano ejecutándose y usuario root
![captura2](https://github.com/joseaguardia/maniattico-zsh-theme/blob/master/images/zsh02.png?raw=true)

Docker: si se detecta el servicio docker activo, muestra el número de contenedores activos y parados.
![captura3](https://github.com/joseaguardia/maniattico-zsh-theme/blob/master/images/zsh03.png?raw=true)

**Para que esto funcione es necesario añadir lo siguiente a ~/.zshrc:**                           
`/usr/bin/systemctl status docker > /dev/null 2> /dev/null && SERVICIODOCKER="1" || SERVICIODOCKER="0"`

Un color para cada tipo de entorno:
![captura4](https://github.com/joseaguardia/maniattico-zsh-theme/blob/master/images/zsh04.png?raw=true)
![captura5](https://github.com/joseaguardia/maniattico-zsh-theme/blob/master/images/zsh05.png?raw=true)
![captura6](https://github.com/joseaguardia/maniattico-zsh-theme/blob/master/images/zsh06.png?raw=true)
