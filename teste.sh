#!/bin/bash

#=====REPARAR=====
# OWASP ZAP

user_pentest()
{
    clear
        echo "Com grandes poderes vêm grandes responsabilidades"
        sleep 2
        sudo apt install nmap wafw00f whatweb whois dnsutils hping3 nbtscan -y
        sudo snap install core && sudo snap install amass
        sudo apt install ruby-full build-essential zlib1g-dev -y && sudo gem install wpscan
        #==== LBD===
        cd ~/src && git clone https://github.com/HenriqueMei/AutoLinux.git
        cd ~/src/AutoLinux/prog/lbd
        chmod +x lbd
        sudo cp lbd /usr/bin/lbd
        #===Nikto===
        cd ~/src
        chmod +x ~/src/AutoLinux/prog/nikto/program/nikto.pl
        if ! grep -q "alias nikto=" ~/.bashrc; then
            echo "alias nikto='~/src/nikto/program/nikto.pl'" >> ~/.bashrc 
        fi 
        #===Jonh Jumbo===
        cd ~/src
        sudo apt install git build-essential libssl-dev zlib1g-dev pkg-config libgmp-dev libbz2-dev -y
        git clone https://github.com/openwall/john -b bleeding-jumbo john
        cd john/src
        ./configure && make -s clean && make -sj$(nproc)

        cd ~/src/john/run
        echo “Testando John”
        ./john --test=0
        ./john --list=build-info

        if [ ! -d "john" ]; then
            git clone https://github.com/openwall/john -b bleeding-jumbo john 
        fi

        if ! grep -q "alias john=" ~/.bashrc; then 
            echo "alias john='~/src/john/run/john'" >> ~/.bashrc 
        fi 
        sudo apt install hydra gobuster sqlmap proxychains4 tor mousepad -y
#=======The Harvester====
        cd ~/src
        # 1. Instalar o gerenciador 'uv' (necessário para o theHarvester novo) 
        curl -LsSf https://astral.sh/uv/install.sh | sh 
        export PATH="$HOME/.local/bin:$PATH"

        # 2. Instalar theHarvester 
        if [ ! -d "theHarvester" ]; then 
            git clone https://github.com/laramies/theHarvester.git 
        fi 
        cd theHarvester 
        uv sync 
        cd ..

        # --- Criando Aliases para facilitar o uso --- 
        if ! grep -q "alias theharvester=" ~/.bashrc; then 
            echo "alias theharvester='cd ~/src/theHarvester && uv run theHarvester.py'" >> ~/.bashrc 
        fi 

#=======SetoolKit e MetaSploit======
        cd ~/src
        if [ ! -d "setoolkit" ]; then 
            git clone https://github.com/trustedsec/social-engineer-toolkit/ setoolkit 
        fi

        cd setoolkit
        sed -i 's/pycrypto/pycryptodome/g' requirements.txt
        sudo PIP_BREAK_SYSTEM_PACKAGES=1 python3 setup.py install
        #sudo python3 setup.py install

        curl -sL https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
        chmod 755 msfinstall
        sudo ./msfinstall
        sudo sed -i 's|^METASPLOIT_PATH=.*|METASPLOIT_PATH=/opt/metasploit-framework/bin|g' /etc/setoolkit/set.config
        rm msfinstall

        # Alias para facilitar (precisa de sudo para rodar o SET) 
        if ! grep -q "alias setoolkit=" ~/.bashrc; then 
            echo "alias setoolkit='sudo setoolkit'" >> ~/.bashrc 
        fi

#=======WordLists======
        echo "Baixando Wordlists (isso pode demorar)..."
        sudo mkdir -p /usr/share/
        sudo mv ~/src/AutoLinux/wordlist /usr/share/
        cd /usr/share/wordlist
        tar xvzf rockyou.tar.gz && tar xvzf metasploit.tar.gz
        rm rockyou.tar.gz && rm metasploit.tar.gz

        # SecLists (Depth 1 para ser mais rápido)
        if [ ! -d "SecLists" ]; then 
            sudo git clone --depth 1 https://github.com/danielmiessler/SecLists.git 
        fi
#=======OWASP ZAP======
        cd ~/src
        wget https://github.com/zaproxy/zaproxy/releases/download/v2.17.0/ZAP_2.17.0_Linux.tar.gz
        tar xvzf ZAP_2.17.0_Linux.tar.gz && rm ZAP_2.17.0_Linux.tar.gz
        cd ZAP_2.17.0

        # Define o caminho absoluto
        ZAP_PATH="$HOME/src/ZAP_2.17.0"
        cd "$ZAP_PATH"
        chmod +x zap.sh

        # Cria um link simbólico em /usr/local/bin
        sudo ln -sf "$ZAP_PATH/zap.sh" /usr/local/bin/zap

        # Criar atalho no Desktop
        echo "[Desktop Entry]
        Name=OWASP ZAP
        Comment=Web Application Security Testing
        Exec=$HOME/src/ZAP_2.17.0/zap.sh
        Icon=$HOME/src/ZAP_2.17.0/zap.ico
        Terminal=false
        Type=Application
        Categories=Development;Security;" > ~/.local/share/applications/zaproxy.desktop

        chmod +x ~/.local/share/applications/zaproxy.desktop
        cp ~/.local/share/applications/zaproxy.desktop ~/Desktop/
        
}

system_install()
{
    clear
    echo "====================================="
    echo "           Preparar Ambiente         "
    echo "====================================="
    echo "Atualizando o Sistema"
    sleep 1
    sudo apt update && sudo apt full-upgrade -y
    echo "Adicionando layouts de teclado (ABNT + US)"
    gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'br'), ('xkb', 'us')]"
    echo "Instalando pacotes basicos"
    sleep 1
    sudo apt install build-essential curl wget dkms git gnupg golang-go -y
    sudo apt install python3 python3-pip python3-venv python3-full snapd -y
    sudo apt install apt-transport-https ca-certificates lsb-release -y #software-properties-common
    sudo systemctl enable --now snapd.apparmor
    echo "Finalizando"
    sleep 4
    clear
    echo "Finalizado... Vamos para a próxima etapa"
    desktop
}

user_install()
{
    clear
    echo "====================================="
    echo "    INSTALADOR DE PROGRAMAS          "
    echo "====================================="
    echo "Escolha os programas:"
    echo "1 - Steam"
    echo "2 - Discord"
    echo "3 - Spotify"
    echo "4 - Telegram"
    echo "5 - OBS"
    echo "6 - Google Chrome"
    echo "7 - Proton VPN"
    echo "8 - Burp"
    echo "---------------------------"
    echo "Digite os números separados por espaço"
    echo "Exemplo: 1 2 3"
    read -p "Lista de Programas: " listProg

    for item in $listProg; do
        case $item in
        1)
            echo "[+] Instalando Steam"
            sudo snap install steam
            ;;
        2)
            echo "[+] Instalando Discord"
            sudo snap install discord
            ;;
        3)
            echo "[+] Instalando Spotify"
            sudo snap install spotify
            ;;
        4)
            echo "[+] Instalando Telegram"
            sudo snap install telegram-desktop
            ;;
        5)
            echo "[+] Instalando OBS"
            sudo snap install obs-studio --classic
            ;;
        6)
            echo "[+] Instalando Google"
            wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
            sudo apt install ./google-chrome-stable_current_amd64.deb -y
            rm google-chrome-stable_current_amd64.deb
            ;;
        7)
            echo "[+] Instalando Proton VPN"
            wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.8_all.deb
            sudo dpkg -i ./protonvpn-stable-release_1.0.8_all.deb && sudo apt update
            sudo apt install proton-vpn-gnome-desktop -y
            rm protonvpn-stable-release_1.0.8_all.deb
            ;;
        8)
            echo "[+] Instalando Burp Suite Community"
            wget -O ~/burp.sh "https://portswigger.net/burp/releases/download?product=community&version=2026.2.4&type=Linux"
            chmod +x ~/burp.sh
            ~/burp.sh --quiet --user-install
            sudo ln -sf ~/BurpSuiteCommunity/BurpSuiteCommunity /usr/local/bin/burpsuite
            rm ~/burp.sh
            ;;
        0)
            desktop
            ;;
        *)
            echo "[-] Opção '$item' não existe."
        esac
    done
}

desktop()
{
    clear
    while true; do
    echo "---------------------------"
    echo "Escolha uma opção:"
    echo "1 - Configurações para Notebook "
    echo "2 - Instalar Programas"
    echo "3 - Ambiente para Pentest"
    echo "9 - Menu Principal"
    echo "0 - Sair"
    echo "---------------------------"
    echo "Se for um computador recem formatado, recomendo a opção 1 primeiro"

    read -p "Opção: " opcao

    case $opcao in
    1)
        echo "Preparando para configurar ambiente"
        system_install
    ;;
    2)
        echo "Carregando lista de programas..."
        echo "Aguarde um momento"
        user_install
        ;;
    3)
        user_pentest
    9)
        echo "Retornando para o Menu Principal"
        sleep 1
        menu_principal
        ;;
    0)
                    echo "Saindo..."
                sleep 1
                clear
                exit 0
    ;;
                *)
                echo "Opção inválida!"
                sleep 1
                ;;
    esac
    done
}

# Loop 'while true' fará o código repetir infinitamente
menu_principal()
{
clear
    while true; do
        echo "====================================="
        echo "            Menu Principal           "
        echo "====================================="
        echo "Escolha uma opção:"
        echo "1 - Computador/Notebook"
        echo "2 - VM"
        echo "3 - Sair"
        echo "---------------------------"

        read -p "Opção: " opcao

        case $opcao in
            1)
                echo "Montando ambiente..."
                sleep 1
                desktop
                ;;
            2)
                echo "Executando Opção 2..."
                ;;
            3)
                echo "Saindo..."
                sleep 1
                clear
                exit 0
                ;;
            *)
                echo "Opção inválida!"
                sleep 1
                ;;
        esac
        clear
    done
}

menu_principal
