#!/bin/bash

# --- CONFIGURAÇÃO DE LOGS ---
LOG_ERROS="$HOME/erros_instalacao.txt"
rm -f "$LOG_ERROS"

# Função para rodar comandos em silêncio e logar apenas erros
# Uso: run_silent "descrição" "comando"
run_silent() {
    local desc=$1
    local cmd=$2
    echo -n "=> $desc... "
    
    # Executa o comando, esconde a saída padrão e joga erros para o log
    eval "$cmd" > /dev/null 2>> "$LOG_ERROS"
    
    if [ $? -eq 0 ]; then
        echo "[ OK ]"
    else
        echo "[ ERRO ] - Verifique o log"
    fi
}

# --- INÍCIO DO SCRIPT ---

# Atualização Inicial
echo "Atualizando sistema (isso pode demorar)..."
sudo apt update -y -qq && sudo apt full-upgrade -y -qq 2>> "$LOG_ERROS"

mkdir -p ~/src

# Energia: Sempre Ligado
run_silent "Configurando energia (HandleLidSwitch)" "sudo sed -i 's/.*HandleLidSwitch=.*/HandleLidSwitch=ignore/' /etc/systemd/logind.conf && sudo sed -i 's/.*HandleLidSwitchExternalPower=.*/HandleLidSwitchExternalPower=ignore/' /etc/systemd/logind.conf && sudo sed -i 's/.*HandleLidSwitchDocked=.*/HandleLidSwitchDocked=ignore/' /etc/systemd/logind.conf && sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target"

#==============================================Acesso remoto==============================================
run_silent "Instalando XRDP e SSH" "sudo apt install xrdp ssl-cert openssh-server -y -qq && sudo adduser xrdp ssl-cert && sudo systemctl enable xrdp ssh"

#==============================================Python e Git==============================================
run_silent "Instalando Python Base e Git" "sudo apt install git python3 python3-pip python3-venv python3-full -y -qq"
run_silent "Instalando Libs de Compilação" "sudo apt install build-essential python3-dev libxml2-dev libxslt1-dev zlib1g-dev libssl-dev pkg-config libgmp-dev libbz2-dev libpcap-dev -y -qq"
run_silent "Instalando Dependências SET e Recon" "sudo apt install python3-pexpect python3-cryptography python3-requests python3-openssl python3-pyte -y -qq"

#==============================================Recon==============================================
run_silent "Instalando ferramentas de Recon (Nmap, etc)" "sudo apt install curl nmap wafw00f whatweb whois dnsutils hping3 nbtscan -y -qq"

#==============================================Amass via Snap==============================================
run_silent "Instalando Amass via Snap" "sudo apt install snapd -y -qq && sudo systemctl enable --now snapd.apparmor && sleep 2 && sudo snap install core && sudo snap install amass"

#==============================================WPSCAN==============================================
run_silent "Instalando WPScan" "sudo apt install ruby-full build-essential zlib1g-dev -y -qq && sudo gem install wpscan"

#==============================================LBD==============================================
echo -n "=> Instalando LBD... "
cd ~/src && git clone https://gitlab.com/kalilinux/packages/lbd > /dev/null 2>> "$LOG_ERROS"
cd ~/src/lbd && chmod +x lbd && sudo cp lbd /usr/bin/lbd && echo "[ OK ]"

#==============================================Nikto==============================================
echo -n "=> Instalando Nikto via Git... "
cd ~/src
git clone https://github.com/sullo/nikto > /dev/null 2>> "$LOG_ERROS"
chmod +x ~/src/nikto/program/nikto.pl
if ! grep -q "alias nikto=" ~/.bashrc; then 
    echo "alias nikto='~/src/nikto/program/nikto.pl'" >> ~/.bashrc 
fi 
echo "[ OK ]"

#==============================================John Jumbo==============================================
echo -n "=> Compilando John the Ripper (Jumbo)... "
cd ~/src
sudo apt install git build-essential libssl-dev zlib1g-dev pkg-config libgmp-dev libbz2-dev -y -qq 2>> "$LOG_ERROS"
if [ ! -d "john" ]; then
    git clone https://github.com/openwall/john -b bleeding-jumbo john > /dev/null 2>> "$LOG_ERROS"
fi
cd john/src
./configure > /dev/null 2>> "$LOG_ERROS" && make -s clean && make -sj$(nproc) > /dev/null 2>> "$LOG_ERROS"
echo "[ OK ]"

cd ~/src/john/run
echo "Testando John 🔄"
./john --test=0 > /dev/null
./john --list=build-info > /dev/null

if ! grep -q "alias john=" ~/.bashrc; then 
    echo "alias john='~/src/john/run/john'" >> ~/.bashrc 
fi 

#==============================================Tools Extras==============================================
run_silent "Instalando Hydra, Gobuster, SQLMap" "sudo apt install hydra gobuster sqlmap proxychains4 tor mousepad -y -qq"

#==============================================OSINT==============================================
echo -n "=> Instalando theHarvester e SpiderFoot... "
cd ~/src 
curl -LsSf https://astral.sh/uv/install.sh | sh > /dev/null 2>> "$LOG_ERROS"
export PATH="$HOME/.local/bin:$PATH"

if [ ! -d "theHarvester" ]; then 
    git clone https://github.com/laramies/theHarvester.git > /dev/null 2>> "$LOG_ERROS"
fi 
cd theHarvester && uv sync > /dev/null 2>> "$LOG_ERROS"
cd .. 

if [ ! -d "spiderfoot-4.0" ]; then 
    wget -q https://github.com/smicallef/spiderfoot/archive/v4.0.tar.gz 
    tar zxvf v4.0.tar.gz > /dev/null 2>> "$LOG_ERROS"
    rm v4.0.tar.gz 
fi 

cd spiderfoot-4.0 
python3 -m venv venv > /dev/null
source venv/bin/activate 
pip install --upgrade pip -q
pip install "PyYAML>=6.0" "lxml>=5.2.0" -q
sed -i '/pyyaml/d' requirements.txt
sed -i '/lxml/d' requirements.txt
pip install -r requirements.txt -q
deactivate 
cd .. 
echo "[ OK ]"

if ! grep -q "alias theharvester=" ~/.bashrc; then 
    echo "alias theharvester='cd ~/src/theHarvester && uv run theHarvester.py'" >> ~/.bashrc 
fi 

if ! grep -q "alias spiderfoot=" ~/.bashrc; then 
    echo "alias spiderfoot='cd ~/src/spiderfoot-4.0 && source venv/bin/activate && python3 sf.py'" >> ~/.bashrc 
fi

#==============================================Setoolkit==============================================
echo -n "=> Instalando SEToolkit... "
cd ~/src
if [ ! -d "setoolkit" ]; then 
    git clone https://github.com/trustedsec/social-engineer-toolkit/ setoolkit > /dev/null 2>> "$LOG_ERROS"
fi
cd setoolkit
sudo python3 setup.py install > /dev/null 2>> "$LOG_ERROS"
echo "[ OK ]"

if ! grep -q "alias setoolkit=" ~/.bashrc; then 
    echo "alias setoolkit='sudo setoolkit'" >> ~/.bashrc 
fi

#==============================================H8mail==============================================
run_silent "Instalando h8mail" "sudo pip install h8mail --break-system-packages -q"

#==============================================Holehe==============================================
echo -n "=> Instalando Holehe... "
sudo apt install -y python3-setuptools python3-pip -qq 2>> "$LOG_ERROS"
cd ~/src/
if [ ! -d "holehe" ]; then
    git clone https://github.com/megadose/holehe > /dev/null 2>> "$LOG_ERROS"
fi
cd holehe
sudo pip install . --break-system-packages -q 2>> "$LOG_ERROS"
echo "[ OK ]"

#==============================================Wordlists============================================== 
echo -n "=> Baixando SecLists... "
sudo mkdir -p /usr/share/wordlists 
cd /usr/share/wordlists 
if [ ! -d "SecLists" ]; then 
    sudo git clone --depth 1 https://github.com/danielmiessler/SecLists.git > /dev/null 2>> "$LOG_ERROS"
fi
echo "[ OK ]"

#==============================================Owasp ZAP==============================================
run_silent "Instalando OWASP ZAP" "sudo snap install zaproxy --classic"

###================================================================================================###
# VERIFICAÇÃO FINAL
if [ -s "$LOG_ERROS" ]; then
    echo ""
    echo "------------------------------------------------------------------"
    echo "⚠️  CONFIGURAÇÃO FINALIZADA COM ERROS!"
    echo "Alguns pacotes falharam. Verifique o arquivo: $LOG_ERROS"
    echo "O sistema NÃO será reiniciado automaticamente para você conferir."
    echo "------------------------------------------------------------------"
else
    echo ""
    echo "✅ CONFIGURAÇÃO FINALIZADA COM SUCESSO!"
    echo "Tudo pronto. Reiniciando em 10 segundos..."
    rm -f "$LOG_ERROS"
    sleep 10
    sudo reboot
fi