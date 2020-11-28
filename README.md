# maniattico.zsh-theme

## ZSH theme, fork of 'agnoster'

Normal view: hostname, IP, environment and pwd
![captura1](https://github.com/joseaguardia/maniattico-zsh-theme/blob/master/images/zsh2_a.png?raw=true)

**New icons** for last command status and background task
![captura2](https://github.com/joseaguardia/maniattico-zsh-theme/blob/master/images/zsh2_b.png?raw=true)

New feature: if an **openVPN connection** is established, it shows current IP address.
![captura3](https://github.com/joseaguardia/maniattico-zsh-theme/blob/master/images/zsh2_c.png?raw=true)


**Docker**: with the docker service running, it shows the containers that are started and stopped
![captura4](https://github.com/joseaguardia/maniattico-zsh-theme/blob/master/images/zsh2_d.png?raw=true)

**To use it, you need to add the following line to ~/.zshrc:**                           
`/usr/bin/systemctl status docker > /dev/null 2> /dev/null && SERVICIODOCKER="1" || SERVICIODOCKER="0"`

You can **disable the gradient** at the end of first prompt line:
![captura5](https://github.com/joseaguardia/maniattico-zsh-theme/blob/master/images/zsh2_e.png?raw=true)


**Different colours** for every environment:
![captura6](https://github.com/joseaguardia/maniattico-zsh-theme/blob/master/images/zsh2_f.png?raw=true)

