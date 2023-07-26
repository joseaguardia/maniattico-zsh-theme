# maniattico.zsh-theme

### ZSH theme for OhMyZSH, fork of 'agnoster'

**General view**: hostname, IP, environment and pwd
![image](https://github.com/joseaguardia/maniattico-zsh-theme/assets/16305835/10b48d81-c8dc-4f3a-91c8-03c5e23d3376)



**New icons** for last command status and background task (also for screen terminals)
![image](https://github.com/joseaguardia/maniattico-zsh-theme/assets/16305835/884815ce-4492-4f15-8c52-568c81c342e6)


If  **openVPN,WireGuard, FortiClient or Cisco Anyconnect connection** is established, it shows current IP address and icons and background color for each of them.
![image](https://github.com/joseaguardia/maniattico-zsh-theme/assets/16305835/cba435a5-0c84-4f35-a3c9-26c4f5a7a47e)


**Docker**: with the docker service running, it shows the containers that are started and stopped
![captura4](https://github.com/joseaguardia/maniattico-zsh-theme/blob/master/images/zsh2_d.png?raw=true)
To use it, you need to add the following line to ~/.zshrc:                           
`/usr/bin/systemctl status docker > /dev/null 2> /dev/null && SERVICIODOCKER="1" || SERVICIODOCKER="0"`


When **no local IP address** is detected, add icons instead of IP
![image](https://github.com/joseaguardia/maniattico-zsh-theme/assets/16305835/7fe3578b-4cc4-494e-8301-94f9e9a249bc)


**Git** status, brach, and so on (lighter colours).
![image](https://github.com/joseaguardia/maniattico-zsh-theme/assets/16305835/cf283f9e-c70b-46a7-b433-85a8ac1f20a4)



You can **enable the gradient** at the end of first prompt line:
![image](https://github.com/joseaguardia/maniattico-zsh-theme/assets/16305835/f3b8d4d5-b155-48a0-a767-3fa264ec621e)


**Different colours** for every environment:
![image](https://github.com/joseaguardia/maniattico-zsh-theme/assets/16305835/fa2bf8f9-d27c-4454-88c8-567d0992afa6)


