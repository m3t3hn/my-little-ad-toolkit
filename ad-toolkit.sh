#!/bin/bash

declare -A tools=(
    ["responder"]="responder"
    ["netexec"]="netexec"
    ["mimikatz"]="mimikatz"
    ["enum4linux"]="enum4linux"
    ["smbmap"]="smbmap"
    ["bloodhound-ui"]="bloodhound"
    ["bloodhound-ingestor"]="https://github.com/dirkjanm/BloodHound.py"
    ["impacket"]="https://github.com/SecureAuthCorp/impacket.git"
    ["pkinittools"]="https://github.com/dirkjanm/PKINITtools.git"
    ["certipy"]="https://github.com/ly4k/Certipy.git"
    ["petitpotam.py"]="https://github.com/topotam/PetitPotam.git"
    ["dfscoerce.py"]="https://github.com/Wh04m1001/DFSCoerce.git"
    ["nopac.py"]="https://github.com/Ridter/noPac.git"
    ["zerologon"]="https://github.com/dirkjanm/CVE-2020-1472.git"
    ["printnightmare"]="https://github.com/cube0x0/CVE-2021-1675.git"
)

tools_dir="$HOME/tools"
mkdir -p "$tools_dir"

echo "tools or exploits to be installed:"
for tool in "${!tools[@]}"; do
    echo " - $tool"
done

read -p "install? (y/anything else): " response
if [[ "$response" != "y" ]]; then
    echo "Bye!"
    exit 0
fi

sudo apt update

if ! dpkg -l | grep -q python3-venv; then
    sudo apt-get install -y python3-venv
fi

venv_dir="$tools_dir/venv"
if [[ ! -d "$venv_dir" ]]; then
    python3 -m venv "$venv_dir"
fi

source "$venv_dir/bin/activate"

for tool in "${!tools[@]}"; do
    case $tool in
        bloodhound|mimikatz|netexec|responder|enum4linux|smbmap)
            if ! dpkg -l | grep -q "$tool"; then
                sudo apt-get install -y "$tool"
            fi
            ;;
        *)
            tool_dir="$tools_dir/$(basename ${tools[$tool]%.git})"
            if [[ ! -d "$tool_dir" ]]; then
                git clone "${tools[$tool]}" "$tool_dir"
                cd "$tool_dir"
                if [[ -f "requirements.txt" ]]; then
                    pip install -r requirements.txt
                elif [[ -f "setup.py" ]]; then
                    python setup.py install
                fi
                cd "$tools_dir"
            fi
            ;;
    esac
done

clear
echo "installation complete! thx <31"
exec bash
