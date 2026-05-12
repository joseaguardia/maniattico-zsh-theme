#!/bin/bash

#Instalamos zsh y OhMyZsh 

# One line
# ENVIRONMENT=""; ENTORNO=""; . ~/.zshrc; wget https://raw.githubusercontent.com/joseaguardia/maniattico-zsh-theme/master/maniattico.zsh-theme -O ~/.oh-my-zsh/themes/maniattico.zsh-theme; wget https://raw.githubusercontent.com/joseaguardia/maniattico-zsh-theme/master/maniattico.zsh-theme.cfg -O ~/.oh-my-zsh/themes/maniattico.zsh-theme.cfg; ENTORNO="$(echo $ENTORNO$ENVIRONMENT)"; EXTRA_INFO="$(echo $EXTRA_INFO)"; sed -i "/ENVIRONMENT=/c\ENVIRONMENT=\"$ENTORNO\"" ~/.oh-my-zsh/themes/maniattico.zsh-theme.cfg; sed -i "/EXTRA_INFO=/c\EXTRA_INFO=\"$EXTRA_INFO\"" ~/.oh-my-zsh/themes/maniattico.zsh-theme.cfg; sed -i '/^ZSH_THEME=/c\ZSH_THEME="maniattico"' ~/.zshrc; . ~/.zshrc; [ "$(crontab -l | grep maniattico.zsh-theme)" ] || (crontab -l 2>/dev/null; echo "00 2 * * * wget https://raw.githubusercontent.com/joseaguardia/maniattico-zsh-theme/master/maniattico.zsh-theme -O ~/.oh-my-zsh/themes/maniattico.zsh-theme" ) | crontab -


echo "Selecciona el entorno:"
echo "[1] PRODUCCIÓN"
echo "[2] PREPRODUCCIÓN"
echo "[3] DESARROLLO"
echo "[4] INTERNO"
read -n 1 -e -p "Seleccionar:" ENTORNO
[[ $ENTORNO = 1 ]] && ENTORNO="PRODUCCIÓN"
[[ $ENTORNO = 2 ]] && ENTORNO="PREPRODUCCIÓN"
[[ $ENTORNO = 3 ]] && ENTORNO="DESARROLLO"
[[ $ENTORNO = 4 ]] && ENTORNO="INTERNO"

echo "Introduce información extra (al lado del entorno)"
read EXTRA_INFO
 
dnf install -y wget git zsh

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

#Tema
sed -i '/^ZSH_THEME=/c\ZSH_THEME="maniattico"' ~/.zshrc
wget https://raw.githubusercontent.com/joseaguardia/maniattico-zsh-theme/master/maniattico.zsh-theme -O ~/.oh-my-zsh/themes/maniattico.zsh-theme
wget https://raw.githubusercontent.com/joseaguardia/maniattico-zsh-theme/master/maniattico.zsh-theme.cfg -O ~/.oh-my-zsh/themes/maniattico.zsh-theme.cfg
sed -i "/^EXTRA_INFO=/c\EXTRA_INFO=\"$EXTRA_INFO\"" ~/.oh-my-zsh/themes/maniattico.zsh-theme.cfg
sed -i "/^ENTORNO=/c\ENTORNO=\"$ENTORNO\"" ~/.oh-my-zsh/themes/maniattico.zsh-theme.cfg


#Plugins
sed -i '/^plugins=/c\plugins=(git zsh-interactive-cd docker zsh-syntax-highlighting zsh-autosuggestions)' ~/.zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Añadimos la variable para ver si docker está activo
#sed -i '1s/^/\/usr\/bin\/systemctl status docker > \/dev\/null 2> \/dev\/null \&\& SERVICIODOCKER="1" || SERVICIODOCKER="0" \nexport TERM="xterm-256color"\n/' ~/.zshrc

#Aplicamos
. ~/.zshrc
chsh -s $(which zsh)

echo "Si estás en RockyLinux tendrás que editar /etc/passwd para cambiar /bin/bash por /usr/bin/zsh"
