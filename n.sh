#!/bin/bash
set -e

[ ! -f /etc/arch-release ] && { echo "Apenas Arch Linux é suportado."; exit 1; }

STATE_DIR="$HOME/.config/arch_scripts"
mkdir -p "$STATE_DIR"

confirm() {
    local prompt="$1"
    read -p "$prompt (s/n): " -n 1 resposta
    echo
    [[ "$resposta" = "s" || "$resposta" = "S" ]]
}

cleanup_files() {
    local files=("$@")
    for file in "${files[@]}"; do
        [ -e "$file" ] && rm -rf "$file" || true
    done
}

ensure_flatpak() {
    if ! pacman -Q flatpak &>/dev/null; then
        if confirm "Flatpak não está instalado. Instalar?"; then
            sudo pacman -S --noconfirm flatpak
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        else
            return 1
        fi
    fi
    return 0
}

ensure_yay() {
    if ! pacman -Q yay &>/dev/null; then
        if confirm "Yay não está instalado. Instalar?"; then
            sudo pacman -S --noconfirm base-devel yay
        else
            return 1
        fi
    fi
    return 0
}

ensure_docker() {
    if ! pacman -Q docker &>/dev/null; then
        if confirm "Docker não está instalado. Instalar?"; then
            sudo pacman -S --noconfirm docker docker-compose
            sudo systemctl enable --now docker.service docker.socket
            sudo usermod -aG docker "$USER"
        else
            return 1
        fi
    fi
    return 0
}

android_studio() {
    local state_file="$STATE_DIR/android_studio"
    
    if [ -f "$state_file" ] || (flatpak list --app 2>/dev/null | grep -q com.google.AndroidStudio); then
        if confirm "Android Studio detectado. Desinstalar?"; then
            echo "Desinstalando Android Studio..."
            flatpak uninstall --user -y com.google.AndroidStudio 2>/dev/null || true
            cleanup_files "$state_file"
            echo "Android Studio desinstalado."
        fi
    else
        if confirm "Instalar Android Studio?"; then
            echo "Instalando Android Studio..."
            if ensure_flatpak; then
                flatpak install --user --noninteractive flathub com.google.AndroidStudio
                touch "$state_file"
                echo "Android Studio instalado."
            fi
        fi
    fi
}

godot() {
    local state_file="$STATE_DIR/godot"
    
    if [ -f "$state_file" ] || (flatpak list --app 2>/dev/null | grep -q org.godotengine.Godot); then
        if confirm "Godot Engine detectado. Desinstalar?"; then
            echo "Desinstalando Godot Engine..."
            flatpak uninstall --user -y org.godotengine.Godot 2>/dev/null || true
            cleanup_files "$state_file" "$HOME/.local/share/applications/godot.desktop"
            echo "Godot Engine desinstalado."
        fi
    else
        if confirm "Instalar Godot Engine?"; then
            echo "Instalando Godot Engine..."
            if ensure_flatpak; then
                flatpak install --user --noninteractive flathub org.godotengine.Godot
                touch "$state_file"
                echo "Godot Engine instalado."
            fi
        fi
    fi
}

httpie() {
    local state_file="$STATE_DIR/httpie"
    
    if [ -f "$state_file" ] || (flatpak list --app 2>/dev/null | grep -q io.httpie.Httpie); then
        if confirm "HTTPie detectado. Desinstalar?"; then
            echo "Desinstalando HTTPie..."
            flatpak uninstall --user -y io.httpie.Httpie 2>/dev/null || true
            cleanup_files "$state_file"
            echo "HTTPie desinstalado."
        fi
    else
        if confirm "Instalar HTTPie?"; then
            echo "Instalando HTTPie..."
            if ensure_flatpak; then
                flatpak install --user --noninteractive flathub io.httpie.Httpie
                touch "$state_file"
                echo "HTTPie instalado."
            fi
        fi
    fi
}

insomnia() {
    local state_file="$STATE_DIR/insomnia"
    
    if [ -f "$state_file" ] || (flatpak list --app 2>/dev/null | grep -q rest.insomnia.Insomnia); then
        if confirm "Insomnia detectado. Desinstalar?"; then
            echo "Desinstalando Insomnia..."
            flatpak uninstall --user -y rest.insomnia.Insomnia 2>/dev/null || true
            cleanup_files "$state_file"
            echo "Insomnia desinstalado."
        fi
    else
        if confirm "Instalar Insomnia?"; then
            echo "Instalando Insomnia..."
            if ensure_flatpak; then
                flatpak install --user --noninteractive flathub rest.insomnia.Insomnia
                touch "$state_file"
                echo "Insomnia instalado."
            fi
        fi
    fi
}

jetbrains_toolbox() {
    local state_file="$STATE_DIR/jetbrains_toolbox"
    local toolbox_dir="$HOME/.local/share/JetBrains/Toolbox"
    
    if [ -f "$state_file" ] || [ -f "$toolbox_dir/bin/jetbrains-toolbox" ]; then
        if confirm "JetBrains Toolbox detectado. Desinstalar?"; then
            echo "Desinstalando JetBrains Toolbox..."
            "$toolbox_dir/bin/jetbrains-toolbox" --uninstall 2>/dev/null || true
            cleanup_files "$state_file" "$HOME/.local/share/applications/jetbrains-toolbox.desktop" "$toolbox_dir" "$HOME/.local/share/JetBrains"
            echo "JetBrains Toolbox desinstalado."
        fi
    else
        if confirm "Instalar JetBrains Toolbox?"; then
            echo "Instalando JetBrains Toolbox..."
            
            curl -fsSL 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' | \
            grep -Po '"linux":\{"link":"\K[^"]+' | \
            curl -L -o- | tar -xz -C /tmp
            
            /tmp/jetbrains-toolbox-*/jetbrains-toolbox
            rm -rf /tmp/jetbrains-toolbox-*
            
            touch "$state_file"
            echo "JetBrains Toolbox instalado."
        fi
    fi
}

postman() {
    local state_file="$STATE_DIR/postman"
    
    if [ -f "$state_file" ] || (flatpak list --app 2>/dev/null | grep -q com.getpostman.Postman); then
        if confirm "Postman detectado. Desinstalar?"; then
            echo "Desinstalando Postman..."
            flatpak uninstall --user -y com.getpostman.Postman 2>/dev/null || true
            cleanup_files "$state_file"
            echo "Postman desinstalado."
        fi
    else
        if confirm "Instalar Postman?"; then
            echo "Instalando Postman..."
            if ensure_flatpak; then
                flatpak install --user --noninteractive flathub com.getpostman.Postman
                touch "$state_file"
                echo "Postman instalado."
            fi
        fi
    fi
}

sublime_text() {
    local state_file="$STATE_DIR/sublime_text"
    local pkg_sublime="sublime-text"
    
    if [ -f "$state_file" ] || (pacman -Q sublime-text &>/dev/null); then
        if confirm "Sublime Text detectado. Desinstalar?"; then
            echo "Desinstalando Sublime Text..."
            sudo pacman -Rsnu --noconfirm $pkg_sublime || true
            cleanup_files "$state_file"
            echo "Sublime Text desinstalado."
        fi
    else
        if confirm "Instalar Sublime Text?"; then
            echo "Instalando Sublime Text..."
            
            curl -O https://download.sublimetext.com/sublimehq-pub.gpg
            sudo pacman-key --add sublimehq-pub.gpg
            sudo pacman-key --lsign-key 8A8F901A
            rm sublimehq-pub.gpg
            
            echo -e "\n[sublime-text]\nServer = https://download.sublimetext.com/arch/stable/x86_64" | sudo tee -a /etc/pacman.conf
            sudo pacman -Syu --noconfirm $pkg_sublime
            
            touch "$state_file"
            echo "Sublime Text instalado."
        fi
    fi
}

vscodium() {
    local state_file="$STATE_DIR/vscodium"
    
    if [ -f "$state_file" ] || (flatpak list --app 2>/dev/null | grep -q com.vscodium.codium); then
        if confirm "VSCodium detectado. Desinstalar?"; then
            echo "Desinstalando VSCodium..."
            flatpak uninstall --user -y com.vscodium.codium 2>/dev/null || true
            cleanup_files "$state_file"
            echo "VSCodium desinstalado."
        fi
    else
        if confirm "Instalar VSCodium?"; then
            echo "Instalando VSCodium..."
            if ensure_flatpak; then
                flatpak install --user --noninteractive flathub com.vscodium.codium
                touch "$state_file"
                echo "VSCodium instalado."
            fi
        fi
    fi
}

visual_studio_code() {
    local state_file="$STATE_DIR/visual_studio_code"
    local pkg_vscode="visual-studio-code-bin"
    
    if [ -f "$state_file" ] || (pacman -Q visual-studio-code-bin &>/dev/null); then
        if confirm "Visual Studio Code detectado. Desinstalar?"; then
            echo "Desinstalando Visual Studio Code..."
            if pacman -Qq visual-studio-code-bin &>/dev/null; then
                if ensure_yay; then
                    yay -Rsnu --noconfirm $pkg_vscode || true
                fi
            fi
            cleanup_files "$state_file"
            echo "Visual Studio Code desinstalado."
        fi
    else
        if confirm "Instalar Visual Studio Code?"; then
            echo "Instalando Visual Studio Code..."
            if ensure_yay; then
                yay -S --noconfirm $pkg_vscode
                touch "$state_file"
                echo "Visual Studio Code instalado."
            fi
        fi
    fi
}

zed() {
    local state_file="$STATE_DIR/zed"
    
    if [ -f "$state_file" ] || (flatpak list --app 2>/dev/null | grep -q dev.zed.Zed); then
        if confirm "Zed detectado. Desinstalar?"; then
            echo "Desinstalando Zed..."
            flatpak uninstall --user -y dev.zed.Zed 2>/dev/null || true
            cleanup_files "$state_file"
            echo "Zed desinstalado."
        fi
    else
        if confirm "Instalar Zed?"; then
            echo "Instalando Zed..."
            if ensure_flatpak; then
                flatpak install --user --noninteractive flathub dev.zed.Zed
                touch "$state_file"
                echo "Zed instalado."
            fi
        fi
    fi
}

portainer() {
    local state_file="$STATE_DIR/portainer"
    
    if [ -f "$state_file" ] || (docker ps -a --format "{{.Names}}" 2>/dev/null | grep -q portainer); then
        if confirm "Portainer detectado. Desinstalar?"; then
            echo "Desinstalando Portainer..."
            docker stop portainer 2>/dev/null || true
            docker rm portainer 2>/dev/null || true
            docker volume rm portainer_data 2>/dev/null || true
            cleanup_files "$state_file"
            echo "Portainer desinstalado."
        fi
    else
        if confirm "Instalar Portainer CE?"; then
            echo "Instalando Portainer CE..."
            if ensure_docker; then
                docker volume create portainer_data
                docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
                touch "$state_file"
                echo "Portainer instalado. Acesse: https://localhost:9443"
            fi
        fi
    fi
}

docker() {
    local state_file="$STATE_DIR/docker"
    local pkg_docker="docker docker-compose"
    
    if [ -f "$state_file" ] || (pacman -Q docker &>/dev/null); then
        if confirm "Docker detectado. Desinstalar?"; then
            echo "Desinstalando Docker..."
            
            if docker ps -a --format "{{.Names}}" 2>/dev/null | grep -q portainer; then
                if confirm "Portainer está instalado. Desinstalar também?"; then
                    portainer
                fi
            fi
            
            sudo systemctl stop docker.service docker.socket 2>/dev/null || true
            sudo systemctl disable docker.service docker.socket 2>/dev/null || true
            
            if pacman -Qq docker docker-compose &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_docker || true
            fi
            
            sudo rm -rf /var/lib/docker 2>/dev/null || true
            sudo groupdel docker 2>/dev/null || true
            
            cleanup_files "$state_file"
            echo "Docker desinstalado."
        fi
    else
        if confirm "Instalar Docker?"; then
            echo "Instalando Docker..."
            
            sudo pacman -S --noconfirm $pkg_docker
            sudo systemctl enable --now docker.service docker.socket
            sudo usermod -aG docker "$USER"
            
            touch "$state_file"
            echo "Docker instalado. Reinicie para aplicar."
        fi
    fi
}

java_openjdk() {
    local state_file="$STATE_DIR/java_openjdk"
    local pkg_jdk="jdk-openjdk"
    
    if [ -f "$state_file" ] || (pacman -Q jdk-openjdk &>/dev/null); then
        if confirm "Java OpenJDK detectado. Desinstalar?"; then
            echo "Desinstalando Java OpenJDK..."
            
            sudo pacman -Rsnu --noconfirm $pkg_jdk || true
            
            cleanup_files "$state_file"
            echo "Java OpenJDK desinstalado."
        fi
    else
        if confirm "Instalar Java OpenJDk?"; then
            echo "Instalando Java OpenJDK..."
            
            sudo pacman -S --noconfirm $pkg_jdk
            
            touch "$state_file"
            echo "Java OpenJDK instalado."
        fi
    fi
}

maven() {
    local state_file="$STATE_DIR/maven"
    local pkg_maven="maven"
    
    if [ -f "$state_file" ] || (pacman -Q maven &>/dev/null); then
        if confirm "Maven detectado. Desinstalar?"; then
            echo "Desinstalando Maven..."
            
            if pacman -Qq maven &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_maven || true
            fi
            
            cleanup_files "$state_file"
            echo "Maven desinstalado."
        fi
    else
        if confirm "Instalar Maven?"; then
            echo "Instalando Maven..."
            
            sudo pacman -S --noconfirm $pkg_maven
            touch "$state_file"
            echo "Maven instalado."
        fi
    fi
}

mise() {
    local state_file="$STATE_DIR/mise"
    local pkg_mise="mise"
    
    if [ -f "$state_file" ] || (pacman -Q mise &>/dev/null); then
        if confirm "Mise detectado. Desinstalar?"; then
            echo "Desinstalando Mise..."
            
            if pacman -Qq mise &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_mise || true
            fi
            
            cleanup_files "$state_file"
            echo "Mise desinstalado."
        fi
    else
        if confirm "Instalar Mise?"; then
            echo "Instalando Mise..."
            
            sudo pacman -S --noconfirm $pkg_mise
            touch "$state_file"
            echo "Mise instalado."
        fi
    fi
}

nvm() {
    local state_file="$STATE_DIR/nvm"
    local pkg_nvm="nvm"
    
    if [ -f "$state_file" ] || (pacman -Q nvm &>/dev/null); then
        if confirm "NVM detectado. Desinstalar?"; then
            echo "Desinstalando NVM..."
            
            if pacman -Qq nvm &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_nvm || true
            fi
            
            cleanup_files "$state_file" "$HOME/.nvm"
            echo "NVM desinstalado."
        fi
    else
        if confirm "Instalar NVM (Node Version Manager)?"; then
            echo "Instalando NVM..."
            
            sudo pacman -S --noconfirm $pkg_nvm
            touch "$state_file"
            echo "NVM instalado."
        fi
    fi
}

oh_my_zsh() {
    local state_file="$STATE_DIR/oh_my_zsh"
    local pkg_zsh="zsh"
    
    if [ -f "$state_file" ] || (pacman -Q zsh &>/dev/null); then
        if confirm "Oh My Zsh detectado. Desinstalar?"; then
            echo "Desinstalando Oh My Zsh..."
            
            if pacman -Qq zsh &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_zsh || true
            fi
            
            rm -rf "$HOME/.oh-my-zsh" 2>/dev/null || true
            sudo chsh -s "$(which bash)" "$USER" 2>/dev/null || true
            
            cleanup_files "$state_file"
            echo "Oh My Zsh desinstalado."
        fi
    else
        if confirm "Instalar Oh My Zsh?"; then
            echo "Instalando Oh My Zsh..."
            
            sudo pacman -S --noconfirm $pkg_zsh
            sudo chsh -s "$(which zsh)" "$USER"
            touch "$state_file"
            echo "Oh My Zsh instalado."
        fi
    fi
}

pyenv() {
    local state_file="$STATE_DIR/pyenv"
    local pkg_pyenv="pyenv"
    
    if [ -f "$state_file" ] || (pacman -Q pyenv &>/dev/null); then
        if confirm "PyEnv detectado. Desinstalar?"; then
            echo "Desinstalando PyEnv..."
            
            if pacman -Qq pyenv &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_pyenv || true
            fi
            
            cleanup_files "$state_file" "$HOME/.pyenv"
            echo "PyEnv desinstalado."
        fi
    else
        if confirm "Instalar PyEnv?"; then
            echo "Instalando PyEnv..."
            
            sudo pacman -S --noconfirm $pkg_pyenv
            touch "$state_file"
            echo "PyEnv instalado."
        fi
    fi
}

sdkman() {
    local state_file="$STATE_DIR/sdkman"
    
    if [ -f "$state_file" ] || [ -d "$HOME/.sdkman" ]; then
        if confirm "SDKMAN detectado. Desinstalar?"; then
            echo "Desinstalando SDKMAN..."
            
            rm -rf "$HOME/.sdkman" 2>/dev/null || true
            
            sed -i '/SDKMAN/d' "$HOME/.bashrc" 2>/dev/null || true
            sed -i '/SDKMAN/d' "$HOME/.zshrc" 2>/dev/null || true
            
            cleanup_files "$state_file"
            echo "SDKMAN desinstalado."
        fi
    else
        if confirm "Instalar SDKMAN?"; then
            echo "Instalando SDKMAN..."
            
            sudo pacman -S --noconfirm zip unzip
            curl -s "https://get.sdkman.io?ci=true" | bash
            
            touch "$state_file"
            echo "SDKMAN instalado."
        fi
    fi
}

tailscale() {
    local state_file="$STATE_DIR/tailscale"
    local pkg_tailscale="tailscale"
    
    if [ -f "$state_file" ] || (pacman -Q tailscale &>/dev/null); then
        if confirm "Tailscale detectado. Desinstalar?"; then
            echo "Desinstalando Tailscale..."
            
            sudo systemctl stop tailscaled 2>/dev/null || true
            sudo systemctl disable tailscaled 2>/dev/null || true
            
            if pacman -Qq tailscale &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_tailscale || true
            fi
            
            cleanup_files "$state_file"
            echo "Tailscale desinstalado."
        fi
    else
        if confirm "Instalar Tailscale?"; then
            echo "Instalando Tailscale..."
            
            sudo pacman -S --noconfirm $pkg_tailscale
            sudo systemctl enable --now tailscaled
            
            touch "$state_file"
            echo "Tailscale instalado."
        fi
    fi
}

zerotier() {
    local state_file="$STATE_DIR/zerotier"
    local pkg_zerotier="zerotier-one"
    
    if [ -f "$state_file" ] || (pacman -Q zerotier-one &>/dev/null); then
        if confirm "ZeroTier detectado. Desinstalar?"; then
            echo "Desinstalando ZeroTier..."
            
            sudo systemctl stop zerotier-one 2>/dev/null || true
            sudo systemctl disable zerotier-one 2>/dev/null || true
            
            if pacman -Qq zerotier-one &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_zerotier || true
            fi
            
            cleanup_files "$state_file"
            echo "ZeroTier desinstalado."
        fi
    else
        if confirm "Instalar ZeroTier?"; then
            echo "Instalando ZeroTier..."
            
            sudo pacman -S --noconfirm $pkg_zerotier
            sudo systemctl enable --now zerotier-one
            
            touch "$state_file"
            echo "ZeroTier instalado."
        fi
    fi
}

pnpm() {
    local state_file="$STATE_DIR/pnpm"
    local pkg_pnpm="pnpm"
    
    if [ -f "$state_file" ] || (pacman -Q pnpm &>/dev/null); then
        if confirm "PNPM detectado. Desinstalar?"; then
            echo "Desinstalando PNPM..."
            
            if pacman -Qq pnpm &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_pnpm || true
            fi
            
            cleanup_files "$state_file"
            echo "PNPM desinstalado."
        fi
    else
        if confirm "Instalar PNPM?"; then
            echo "Instalando PNPM..."
            
            sudo pacman -S --noconfirm $pkg_pnpm
            touch "$state_file"
            echo "PNPM instalado."
        fi
    fi
}

archsb() {
    local state_file="$STATE_DIR/archsb"
    local pkg_archsb="sbctl efibootmgr"
    
    if [ -f "$state_file" ] || (pacman -Q sbctl &>/dev/null); then
        if confirm "Secure Boot detectado. Desinstalar?"; then
            echo "Desinstalando Secure Boot..."
            
            sudo sbctl remove-keys 2>/dev/null || true
            sudo rm -rf /usr/share/secureboot 2>/dev/null || true
            sudo rm -f /boot/*.efi.signed 2>/dev/null || true
            
            if pacman -Qq sbctl efibootmgr &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_archsb || true
            fi
            
            cleanup_files "$state_file"
            echo "Secure Boot desinstalado."
        fi
    else
        if confirm "Configurar Secure Boot?"; then
            echo "Configurando Secure Boot..."
            
            sudo pacman -S --noconfirm $pkg_archsb
            
            if sbctl status | grep -qi "secure boot.*disabled" && sbctl status | grep -qi "setup mode.*enabled"; then
                if command -v grub-install &>/dev/null; then
                    sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --modules="tpm" --disable-shim-lock
                fi
                
                sudo sbctl create-keys
                sudo sbctl enroll-keys -m -f
                
                while IFS= read -r line; do
                    if [[ "$line" =~ ✗ ]]; then
                        file=$(echo "$line" | awk '{print $2}')
                        echo "Assinando: $file"
                        sudo sbctl sign -s "$file"
                    fi
                done < <(sudo sbctl verify)
                
                sudo sbctl verify
                touch "$state_file"
                echo "Secure Boot configurado."
            else
                echo "Secure Boot não está desabilitado ou Setup Mode não está ativado."
                return 1
            fi
        fi
    fi
}

preload() {
    local state_file="$STATE_DIR/preload"
    local pkg_preload="preload"
    
    if [ -f "$state_file" ] || (pacman -Q preload &>/dev/null); then
        if confirm "Preload detectado. Desinstalar?"; then
            echo "Desinstalando Preload..."
            
            sudo systemctl stop preload 2>/dev/null || true
            sudo systemctl disable preload 2>/dev/null || true
            
            if pacman -Qq preload &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_preload || true
            fi
            
            cleanup_files "$state_file"
            echo "Preload desinstalado."
        fi
    else
        local total_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        local total_gb=$(( total_kb / 1024 / 1024 ))
        
        if [ $total_gb -gt 12 ]; then
            if confirm "Instalar Preload (otimização de RAM > 12GB)?"; then
                echo "Instalando Preload..."
                
                sudo pacman -S --noconfirm $pkg_preload
                sudo systemctl enable --now preload
                
                touch "$state_file"
                echo "Preload instalado."
            fi
        else
            echo "RAM insuficiente para Preload (requer > 12GB)."
        fi
    fi
}

minfreefix() {
    local state_file="$STATE_DIR/minfreefix"
    local sysctl_file="/etc/sysctl.d/99-minfreefix.conf"
    
    if [ -f "$state_file" ] || [ -f "$sysctl_file" ]; then
        if confirm "MinFreeFix detectado. Desinstalar?"; then
            echo "Desinstalando MinFreeFix..."
            
            sudo rm -f "$sysctl_file" 2>/dev/null || true
            sudo sysctl --system 2>/dev/null || true
            
            cleanup_files "$state_file"
            echo "MinFreeFix desinstalado."
        fi
    else
        if confirm "Configurar vm.min_free_kbytes dinâmico?"; then
            echo "Configurando MinFreeFix..."
            
            local total_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
            local min_free_kbytes=$(( total_kb / 128 ))
            
            echo "vm.min_free_kbytes = $min_free_kbytes" | sudo tee "$sysctl_file" > /dev/null
            sudo sysctl -p "$sysctl_file"
            
            touch "$state_file"
            echo "MinFreeFix configurado. vm.min_free_kbytes = $min_free_kbytes"
        fi
    fi
}

mscorefonts() {
    local state_file="$STATE_DIR/mscorefonts"
    local font_dir="$HOME/.local/share/fonts/mscorefonts"
    local pkg_cabextract="cabextract"
    
    if [ -f "$state_file" ] || [ -d "$font_dir" ]; then
        if confirm "Microsoft Core Fonts detectado. Desinstalar?"; then
            echo "Desinstalando Microsoft Core Fonts..."
            
            if pacman -Qq cabextract &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_cabextract || true
            fi
            
            cleanup_files "$state_file" "$font_dir" "$HOME/*32.exe" "$HOME/fonts"
            fc-cache -f
            
            echo "Microsoft Core Fonts desinstalado."
        fi
    else
        if confirm "Instalar Microsoft Core Fonts?"; then
            echo "Instalando Microsoft Core Fonts..."
            
            sudo pacman -S --noconfirm $pkg_cabextract
            
            local fonts=(
                "http://downloads.sourceforge.net/corefonts/andale32.exe"
                "http://downloads.sourceforge.net/corefonts/arial32.exe"
                "http://downloads.sourceforge.net/corefonts/arialb32.exe"
                "http://downloads.sourceforge.net/corefonts/comic32.exe"
                "http://downloads.sourceforge.net/corefonts/courie32.exe"
                "http://downloads.sourceforge.net/corefonts/georgi32.exe"
                "http://downloads.sourceforge.net/corefonts/impact32.exe"
                "http://downloads.sourceforge.net/corefonts/times32.exe"
                "http://downloads.sourceforge.net/corefonts/trebuc32.exe"
                "http://downloads.sourceforge.net/corefonts/verdan32.exe"
                "http://downloads.sourceforge.net/corefonts/webdin32.exe"
            )
            
            mkdir -p "$HOME/fonts"
            
            for font_url in "${fonts[@]}"; do
                curl -s -L "$font_url" -o "$HOME/$(basename "$font_url")"
                cabextract "$HOME/$(basename "$font_url")" -d "$HOME/fonts"
                rm "$HOME/$(basename "$font_url")"
            done
            
            mkdir -p "$font_dir"
            cp -v "$HOME/fonts"/*.ttf "$HOME/fonts"/*.TTF "$font_dir/"
            rm -rf "$HOME/fonts"
            
            fc-cache -f
            touch "$state_file"
            echo "Microsoft Core Fonts instalado."
        fi
    fi
}

psaver() {
    local state_file="$STATE_DIR/psaver"
    
    if [ -f "$state_file" ] || [ -f "/etc/systemd/system/powersave.service" ]; then
        if confirm "Powersave detectado. Desinstalar?"; then
            echo "Desinstalando Powersave..."
            
            sudo systemctl stop powersave.service 2>/dev/null || true
            sudo systemctl disable powersave.service 2>/dev/null || true
            
            sudo rm -f /etc/systemd/system/powersave.service 2>/dev/null || true
            sudo rm -f /usr/local/bin/powersave.sh 2>/dev/null || true
            
            sudo sed -i '/powersave/d' /etc/default/grub 2>/dev/null || true
            sudo rm -f /etc/default/grub.d/powersave.cfg 2>/dev/null || true
            sudo mkdir -p /boot/grub 2>/dev/null || true
            sudo grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || true
            
            cleanup_files "$state_file"
            echo "Powersave desinstalado. Reinicie para aplicar."
        fi
    else
        if confirm "Instalar Powersave?"; then
            echo "Instalando Powersave..."
            
            echo '#!/bin/bash
set -e

CPU_GOV="powersave"
SCHEDULER="none"
ENERGY_PERF="power"
CPU_MAX="100"
CPU_MIN="0"

apply_settings() {
    echo "$CPU_GOV" | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null 2>&1 || true
    echo "$ENERGY_PERF" | tee /sys/devices/system/cpu/cpu*/power/energy_performance_preference >/dev/null 2>&1 || true
    
    if [ -f /sys/devices/system/cpu/intel_pstate/max_perf_pct ]; then
        echo "$CPU_MAX" | tee /sys/devices/system/cpu/intel_pstate/max_perf_pct >/dev/null
        echo "$CPU_MIN" | tee /sys/devices/system/cpu/intel_pstate/min_perf_pct >/dev/null
    fi
    
    if [ -f /sys/block/sda/queue/scheduler ]; then
        echo "$SCHEDULER" | tee /sys/block/sd*/queue/scheduler >/dev/null 2>&1 || true
    fi
}

apply_settings
exit 0' | sudo tee /usr/local/bin/powersave.sh >/dev/null
            
            sudo chmod +x /usr/local/bin/powersave.sh
            
            echo '[Unit]
Description=Power Save Settings
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/powersave.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/powersave.service >/dev/null
            
            sudo systemctl enable powersave.service
            sudo systemctl start powersave.service
            
            sudo mkdir -p /etc/default/grub.d
            echo 'GRUB_CMDLINE_LINUX_DEFAULT="${GRUB_CMDLINE_LINUX_DEFAULT} intel_pstate=passive"' | sudo tee /etc/default/grub.d/powersave.cfg >/dev/null
            
            sudo mkdir -p /boot/grub 2>/dev/null || true
            sudo grub-mkconfig -o /boot/grub/grub.cfg
            
            touch "$state_file"
            echo "Powersave instalado. Reinicie para aplicar."
        fi
    fi
}

swapfile_create() {
    local location="$1"
    local size="$2"
    
    case $location in
        1)
            if findmnt -n -o FSTYPE / | grep -q "btrfs"; then
                sudo btrfs subvolume create /swap 2>/dev/null || true
                sudo btrfs filesystem mkswapfile --size ${size}g --uuid clear /swap/swapfile
                sudo swapon /swap/swapfile
                echo "/swap/swapfile none swap defaults 0 0" | sudo tee -a /etc/fstab
            else
                sudo dd if=/dev/zero of=/swapfile bs=1G count=$size status=progress 2>/dev/null || true
                sudo chmod 600 /swapfile
                sudo mkswap /swapfile
                sudo swapon /swapfile
                echo "/swapfile none swap defaults 0 0" | sudo tee -a /etc/fstab
            fi
            ;;
        2)
            if findmnt -n -o FSTYPE /home | grep -q "btrfs"; then
                sudo btrfs subvolume create /home/swap 2>/dev/null || true
                sudo btrfs filesystem mkswapfile --size ${size}g --uuid clear /home/swap/swapfile
                sudo swapon /home/swap/swapfile
                echo "/home/swap/swapfile none swap defaults 0 0" | sudo tee -a /etc/fstab
            else
                sudo dd if=/dev/zero of=/home/swapfile bs=1G count=$size status=progress 2>/dev/null || true
                sudo chmod 600 /home/swapfile
                sudo mkswap /home/swapfile
                sudo swapon /home/swapfile
                echo "/home/swapfile none swap defaults 0 0" | sudo tee -a /etc/fstab
            fi
            ;;
        *)
            echo "Opção inválida"
            return 1
            ;;
    esac
    
    echo "# swapfile" | sudo tee -a /etc/fstab
    return 0
}

swapfile_menu_location() {
    clear
    echo "=== Seleção de Local do Swapfile ==="
    echo "1) / (root)"
    echo "2) /home"
    echo "3) Voltar"
    echo
    read -p "Opção: " location
    
    case $location in
        1|2) swapfile_menu_size "$location" ;;
        3) return ;;
        *) echo "Opção inválida" ;;
    esac
}

swapfile_menu_size() {
    local location="$1"
    clear
    echo "=== Tamanho do Swapfile ==="
    read -p "Tamanho em GB (padrão: 8): " size
    size=${size:-8}
    
    if ! [[ "$size" =~ ^[0-9]+$ ]]; then
        echo "Tamanho inválido"
        return
    fi
    
    swapfile_menu_confirm "$location" "$size"
}

swapfile_menu_confirm() {
    local location="$1"
    local size="$2"
    clear
    echo "=== Confirmação ==="
    echo "Local: $( [ "$location" = "1" ] && echo "/ (root)" || echo "/home" )"
    echo "Tamanho: ${size}GB"
    echo
    
    if confirm "Criar swapfile de ${size}GB?"; then
        echo "Criando swapfile de ${size}GB..."
        
        if swapfile_create "$location" "$size"; then
            touch "$STATE_DIR/swapfile"
            echo "Swapfile criado com sucesso."
        fi
    fi
}

swapfile() {
    local state_file="$STATE_DIR/swapfile"
    
    if [ -f "$state_file" ] || swapon --show | grep -q '.'; then
        if confirm "Swapfile detectado. Desinstalar?"; then
            echo "Desinstalando Swapfile..."
            
            sudo swapoff -a 2>/dev/null || true
            
            if [ -f "/swapfile" ]; then
                sudo swapoff /swapfile 2>/dev/null || true
                sudo rm -f /swapfile 2>/dev/null || true
                sudo sed -i '/\/swapfile/d' /etc/fstab 2>/dev/null || true
            fi
            
            if [ -f "/home/swapfile" ]; then
                sudo swapoff /home/swapfile 2>/dev/null || true
                sudo rm -f /home/swapfile 2>/dev/null || true
                sudo sed -i '/\/home\/swapfile/d' /etc/fstab 2>/dev/null || true
            fi
            
            if [ -d "/swap" ]; then
                sudo swapoff /swap/swapfile 2>/dev/null || true
                sudo rm -rf /swap 2>/dev/null || true
                sudo sed -i '/\/swap\/swapfile/d' /etc/fstab 2>/dev/null || true
            fi
            
            if [ -d "/home/swap" ]; then
                sudo swapoff /home/swap/swapfile 2>/dev/null || true
                sudo rm -rf /home/swap 2>/dev/null || true
                sudo sed -i '/\/home\/swap\/swapfile/d' /etc/fstab 2>/dev/null || true
            fi
            
            sudo sed -i '/# swapfile/d' /etc/fstab 2>/dev/null || true
            
            cleanup_files "$state_file"
            echo "Swapfile desinstalado."
        fi
    else
        swapfile_menu_location
    fi
}

cpu_ondemand() {
    local state_file="$STATE_DIR/cpu_ondemand"
    
    if [ -f "$state_file" ] || [ -f "/etc/systemd/system/set-ondemand-governor.service" ]; then
        if confirm "CPU Ondemand detectado. Desinstalar?"; then
            echo "Desinstalando CPU Ondemand..."
            
            sudo systemctl stop set-ondemand-governor.service 2>/dev/null || true
            sudo systemctl disable set-ondemand-governor.service 2>/dev/null || true
            
            sudo rm -f /etc/systemd/system/set-ondemand-governor.service 2>/dev/null || true
            sudo rm -f /etc/default/grub.d/01_intel_pstate_disable 2>/dev/null || true
            sudo rm -f /etc/kernel/cmdline.d/10-intel-pstate-disable.conf 2>/dev/null || true
            
            sudo rm -f /usr/local/bin/set-ondemand-governor.sh 2>/dev/null || true
            
            sudo mkdir -p /boot/grub 2>/dev/null || true
            sudo grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || true
            sudo bootctl update 2>/dev/null || true
            
            cleanup_files "$state_file"
            echo "CPU Ondemand desinstalado. Reinicie para aplicar."
        fi
    else
        if confirm "Instalar CPU Ondemand?"; then
            echo "Instalando CPU Ondemand..."
            
            echo '#!/bin/bash
echo "ondemand" | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor' | sudo tee /usr/local/bin/set-ondemand-governor.sh
            
            sudo chmod +x /usr/local/bin/set-ondemand-governor.sh
            
            echo '[Unit]
Description=Set CPU governor to ondemand
After=sysinit.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/set-ondemand-governor.sh

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/set-ondemand-governor.service
            
            sudo systemctl enable set-ondemand-governor.service
            
            sudo mkdir -p /etc/default/grub.d
            echo 'GRUB_CMDLINE_LINUX_DEFAULT="${GRUB_CMDLINE_LINUX_DEFAULT} intel_pstate=disable"' | sudo tee /etc/default/grub.d/01_intel_pstate_disable
            
            sudo mkdir -p /boot/grub 2>/dev/null || true
            sudo grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || true
            
            touch "$state_file"
            echo "CPU Ondemand instalado. Reinicie para aplicar."
        fi
    fi
}

cachyconfs() {
    local state_file="$STATE_DIR/cachyconfs"
    
    if [ -f "$state_file" ] || [ -f "/usr/lib/sysctl.d/99-cachyos-settings.conf" ]; then
        if confirm "CachyOS Configs detectado. Desinstalar?"; then
            echo "Desinstalando CachyOS Configs..."
            
            sudo rm -f /usr/lib/sysctl.d/99-cachyos-settings.conf 2>/dev/null || true
            sudo sysctl --system 2>/dev/null || true
            
            cleanup_files "$state_file"
            echo "CachyOS Configs desinstalado. Reinicie para aplicar."
        fi
    else
        if confirm "Instalar CachyOS Configs?"; then
            echo "Instalando CachyOS Configs..."
            
            sudo mkdir -p /usr/lib/sysctl.d
            curl -s https://raw.githubusercontent.com/CachyOS/CachyOS-Settings/main/sysctl/99-cachyos-settings.conf | sudo tee /usr/lib/sysctl.d/99-cachyos-settings.conf > /dev/null
            sudo sysctl --system
            
            touch "$state_file"
            echo "CachyOS Configs instalado. Reinicie para aplicar."
        fi
    fi
}

dsplitm() {
    local state_file="$STATE_DIR/dsplitm"
    
    if [ -f "$state_file" ] || grep -q "split_lock_detect=off" /proc/cmdline 2>/dev/null; then
        if confirm "Split-lock Mitigation desativado detectado. Desinstalar?"; then
            echo "Desinstalando desativação de Split-lock Mitigation..."
            
            sudo sed -i '/split_lock_detect=off/d' /etc/default/grub 2>/dev/null || true
            sudo rm -f /etc/default/grub.d/99-split-lock-disable.cfg 2>/dev/null || true
            sudo rm -f /etc/kernel/cmdline.d/99-split-lock-disable.conf 2>/dev/null || true
            
            sudo mkdir -p /boot/grub 2>/dev/null || true
            sudo grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || true
            sudo bootctl update 2>/dev/null || true
            
            cleanup_files "$state_file"
            echo "Split-lock Mitigation reativado. Reinicie para aplicar."
        fi
    else
        if confirm "Desativar Split-lock Mitigation?"; then
            echo "Desativando Split-lock Mitigation..."
            
            if pacman -Qq grub &>/dev/null; then
                sudo mkdir -p /etc/default/grub.d
                echo 'GRUB_CMDLINE_LINUX_DEFAULT="${GRUB_CMDLINE_LINUX_DEFAULT} split_lock_detect=off"' | sudo tee /etc/default/grub.d/99-split-lock-disable.cfg
                sudo mkdir -p /boot/grub 2>/dev/null || true
                sudo grub-mkconfig -o /boot/grub/grub.cfg
            else
                sudo mkdir -p /etc/kernel/cmdline.d
                echo "split_lock_detect=off" | sudo tee /etc/kernel/cmdline.d/99-split-lock-disable.conf
                sudo bootctl update 2>/dev/null || true
            fi
            
            touch "$state_file"
            echo "Split-lock Mitigation desativado. Reinicie para aplicar."
        fi
    fi
}

distrobox_handler() {
    local state_file="$STATE_DIR/distrobox_handler"
    local handler_dir="$HOME/.local/distrobox-handler"
    
    if [ -f "$state_file" ] || [ -f "$handler_dir/command_not_found_handle" ]; then
        if confirm "Distrobox Command Handler detectado. Desinstalar?"; then
            echo "Desinstalando Distrobox Command Handler..."
            
            rm -rf "$handler_dir" 2>/dev/null || true
            sudo rm -f /etc/bash.bashrc.d/99-distrobox-cnf 2>/dev/null || true
            sudo rm -f /etc/zsh/zshrc.d/99-distrobox-cnf.zsh 2>/dev/null || true
            sudo rm -f /etc/profile.d/distrobox-host-aliases.sh 2>/dev/null || true
            
            if [ -f "$HOME/.bashrc" ]; then
                grep -v "distrobox-handler" "$HOME/.bashrc" > "$HOME/.bashrc.tmp" && mv "$HOME/.bashrc.tmp" "$HOME/.bashrc"
            fi
            
            if [ -f "$HOME/.zshrc" ]; then
                grep -v "distrobox-handler" "$HOME/.zshrc" > "$HOME/.zshrc.tmp" && mv "$HOME/.zshrc.tmp" "$HOME/.zshrc"
            fi
            
            cleanup_files "$state_file"
            echo "Distrobox Command Handler desinstalado."
        fi
    else
        if confirm "Instalar Distrobox Command Handler?"; then
            echo "Instalando Distrobox Command Handler..."
            
            mkdir -p "$handler_dir"
            
            echo '#!/bin/bash
command_not_found_handle() {
    local cmd="$1"
    shift
    if command -v distrobox-host-exec >/dev/null 2>&1; then
        if distrobox-host-exec which "$cmd" >/dev/null 2>&1; then
            echo "Command \"$cmd\" not found in container, executing on host..." >&2
            exec distrobox-host-exec "$cmd" "$@"
        else
            echo "bash: $cmd: command not found" >&2
            return 127
        fi
    else
        echo "bash: $cmd: command not found" >&2
        return 127
    fi
}' > "$handler_dir/command_not_found_handle"
            
            echo '#!/bin/bash
zsh_command_not_found_handler() {
    local cmd="$1"
    shift
    if command -v distrobox-host-exec >/dev/null 2>&1; then
        if distrobox-host-exec which "$cmd" >/dev/null 2>&1; then
            echo "Command \"$cmd\" not found in container, executing on host..." >&2
            exec distrobox-host-exec "$cmd" "$@"
        else
            echo "zsh: command not found: $cmd" >&2
            return 127
        fi
    else
        echo "zsh: command not found: $cmd" >&2
        return 127
    fi
}' > "$handler_dir/zsh_command_not_found_handler"
            
            chmod +x "$handler_dir/command_not_found_handle" "$handler_dir/zsh_command_not_found_handler"
            
            sudo mkdir -p /etc/bash.bashrc.d
            echo '# Distrobox Command-Not-Found Handler Integration
if [ -f "$HOME/.local/distrobox-handler/command_not_found_handle" ]; then
    source "$HOME/.local/distrobox-handler/command_not_found_handle"
fi' | sudo tee /etc/bash.bashrc.d/99-distrobox-cnf > /dev/null
            
            sudo mkdir -p /etc/zsh/zshrc.d
            echo '# Distrobox Command-Not-Found Handler Integration for ZSH
if [ -f "$HOME/.local/distrobox-handler/zsh_command_not_found_handler" ]; then
    source "$HOME/.local/distrobox-handler/zsh_command_not_found_handler"
fi' | sudo tee /etc/zsh/zshrc.d/99-distrobox-cnf.zsh > /dev/null
            
            echo '# Common host command aliases for distrobox containers
alias xdg-open="distrobox-host-exec xdg-open"
alias nautilus="distrobox-host-exec nautilus"
alias dolphin="distrobox-host-exec dolphin"
alias htop="distrobox-host-exec htop"
alias lscpu="distrobox-host-exec lscpu"
alias lsusb="distrobox-host-exec lsusb"
alias lspci="distrobox-host-exec lspci"
alias nmcli="distrobox-host-exec nmcli"
alias nmtui="distrobox-host-exec nmtui"
alias flatpak="distrobox-host-exec flatpak"
alias firefox="distrobox-host-exec firefox"
alias chromium="distrobox-host-exec chromium"' | sudo tee /etc/profile.d/distrobox-host-aliases.sh > /dev/null
            
            if [ -f "$HOME/.bashrc" ]; then
                grep -q "distrobox-handler" "$HOME/.bashrc" || echo -e '\nif [ -f "$HOME/.local/distrobox-handler/command_not_found_handle" ]; then\n    source "$HOME/.local/distrobox-handler/command_not_found_handle"\nfi' >> "$HOME/.bashrc"
            fi
            
            if [ -f "$HOME/.zshrc" ]; then
                grep -q "distrobox-handler" "$HOME/.zshrc" || echo -e '\nif [ -f "$HOME/.local/distrobox-handler/zsh_command_not_found_handler" ]; then\n    source "$HOME/.local/distrobox-handler/zsh_command_not_found_handler"\nfi' >> "$HOME/.zshrc"
            fi
            
            touch "$state_file"
            echo "Distrobox Command Handler instalado."
        fi
    fi
}

winboat() {
    local state_file="$STATE_DIR/winboat"
    local pkg_winboat="winboat-bin"
    
    if [ -f "$state_file" ] || (pacman -Q winboat-bin &>/dev/null); then
        if confirm "WinBoat detectado. Desinstalar?"; then
            echo "Desinstalando WinBoat..."
            
            if ensure_yay; then
                yay -Rsnu --noconfirm $pkg_winboat || true
            fi
            
            flatpak uninstall --user -y com.freerdp.FreeRDP 2>/dev/null || true
            sudo rm -f /etc/modules-load.d/iptables.conf 2>/dev/null || true
            
            cleanup_files "$state_file"
            echo "WinBoat desinstalado."
        fi
    else
        if ! lsmod | grep -q kvm; then
            echo "KVM não está disponível. Verifique se a virtualização está habilitada no BIOS."
            return 1
        fi
        
        if confirm "Instalar WinBoat (Windows em container Docker)?"; then
            echo "Instalando WinBoat..."
            
            if ensure_docker; then
                if ensure_flatpak; then
                    flatpak install --user --noninteractive flathub com.freerdp.FreeRDP 2>/dev/null || true
                fi
                
                echo -e "ip_tables\niptable_nat" | sudo tee /etc/modules-load.d/iptables.conf > /dev/null
                
                if ensure_yay; then
                    yay -S --noconfirm $pkg_winboat
                    touch "$state_file"
                    echo "WinBoat instalado. Reinicie para carregar módulos do kernel."
                fi
            fi
        fi
    fi
}

grub_btrfs() {
    local state_file="$STATE_DIR/grub_btrfs"
    local pkg_grub_btrfs="grub-btrfs"
    
    if [ -f "$state_file" ] || (pacman -Q grub-btrfs &>/dev/null); then
        if confirm "GRUB Btrfs detectado. Desinstalar?"; then
            echo "Desinstalando GRUB Btrfs..."
            
            sudo systemctl stop grub-btrfsd 2>/dev/null || true
            sudo systemctl disable grub-btrfsd 2>/dev/null || true
            
            if pacman -Qq grub-btrfs &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_grub_btrfs || true
            fi
            
            if pacman -Qq snapper &>/dev/null; then
                sudo systemctl stop snapper-boot.timer snapper-cleanup.timer 2>/dev/null || true
                sudo systemctl disable snapper-boot.timer snapper-cleanup.timer 2>/dev/null || true
                sudo pacman -Rsnu --noconfirm snapper || true
            fi
            
            sudo rm -rf /.snapshots 2>/dev/null || true
            sudo rm -rf /etc/snapper/configs 2>/dev/null || true
            sudo mkdir -p /boot/grub 2>/dev/null || true
            sudo grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || true
            
            cleanup_files "$state_file"
            echo "GRUB Btrfs desinstalado. Reinicie para aplicar."
        fi
    else
        if ! findmnt -n -o FSTYPE / | grep -q "btrfs"; then
            echo "Sistema de arquivos raiz não é Btrfs."
            return 1
        fi
        
        if confirm "Instalar GRUB Btrfs (snapshots no GRUB)?"; then
            echo "Instalando GRUB Btrfs..."
            
            sudo pacman -S --noconfirm snapper
            sudo btrfs subvolume delete -R /.snapshots 2>/dev/null || true
            sudo snapper -c root create-config /
            sudo snapper -c root create --command pacman 2>/dev/null || true
            
            sudo sed -i 's/^TIMELINE_CREATE=.*/TIMELINE_CREATE="no"/' /etc/snapper/configs/root 2>/dev/null || true
            sudo sed -i 's/^NUMBER_LIMIT=.*/NUMBER_LIMIT="5"/' /etc/snapper/configs/root 2>/dev/null || true
            sudo sed -i 's/^NUMBER_LIMIT_IMPORTANT=.*/NUMBER_LIMIT_IMPORTANT="5"/' /etc/snapper/configs/root 2>/dev/null || true
            
            sudo systemctl enable snapper-boot.timer snapper-cleanup.timer
            sudo systemctl start snapper-cleanup.timer
            
            sudo pacman -S --noconfirm $pkg_grub_btrfs
            sudo mkdir -p /boot/grub 2>/dev/null || true
            sudo grub-mkconfig -o /boot/grub/grub.cfg
            sudo systemctl enable --now grub-btrfsd
            
            touch "$state_file"
            echo "GRUB Btrfs instalado. Reinicie para aplicar."
        fi
    fi
}

btrfs_assistant() {
    local state_file="$STATE_DIR/btrfs_assistant"
    local pkg_btrfs_assistant="btrfs-assistant"
    
    if [ -f "$state_file" ] || (pacman -Q btrfs-assistant &>/dev/null); then
        if confirm "Btrfs Assistant detectado. Desinstalar?"; then
            echo "Desinstalando Btrfs Assistant..."
            
            if pacman -Qq btrfs-assistant &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_btrfs_assistant || true
            fi
            
            cleanup_files "$state_file"
            echo "Btrfs Assistant desinstalado."
        fi
    else
        if ! findmnt -n -o FSTYPE / | grep -q "btrfs"; then
            echo "Sistema de arquivos raiz não é Btrfs."
            return 1
        fi
        
        if confirm "Instalar Btrfs Assistant?"; then
            echo "Instalando Btrfs Assistant..."
            
            sudo pacman -S --noconfirm $pkg_btrfs_assistant
            
            touch "$state_file"
            echo "Btrfs Assistant instalado."
        fi
    fi
}

thumbnailer() {
    local state_file="$STATE_DIR/thumbnailer"
    local pkg_thumbnailer="ffmpegthumbnailer"
    
    if [ -f "$state_file" ] || (pacman -Q ffmpegthumbnailer &>/dev/null); then
        if confirm "Thumbnailer detectado. Desinstalar?"; then
            echo "Desinstalando Thumbnailer..."
            
            if pacman -Qq ffmpegthumbnailer &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_thumbnailer || true
            fi
            
            cleanup_files "$state_file"
            echo "Thumbnailer desinstalado."
        fi
    else
        if confirm "Instalar Thumbnailer?"; then
            echo "Instalando Thumbnailer..."
            
            sudo pacman -S --noconfirm $pkg_thumbnailer
            touch "$state_file"
            echo "Thumbnailer instalado."
        fi
    fi
}

iwd() {
    local state_file="$STATE_DIR/iwd"
    local pkg_iwd="iwd"
    
    if [ -f "$state_file" ] || (pacman -Q iwd &>/dev/null); then
        if confirm "IWD detectado. Desinstalar?"; then
            echo "Desinstalando IWD..."
            
            if pacman -Qq iwd &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_iwd || true
            fi
            
            sudo rm -f /etc/NetworkManager/conf.d/iwd.conf 2>/dev/null || true
            sudo systemctl restart NetworkManager 2>/dev/null || true
            sudo systemctl enable --now wpa_supplicant 2>/dev/null || true
            
            cleanup_files "$state_file"
            echo "IWD desinstalado."
        fi
    else
        if confirm "Instalar IWD (iNet Wireless Daemon)?"; then
            echo "Instalando IWD..."
            
            sudo pacman -S --noconfirm $pkg_iwd
            
            echo "[device]
wifi.backend=iwd" | sudo tee /etc/NetworkManager/conf.d/iwd.conf > /dev/null
            
            sudo systemctl stop NetworkManager 2>/dev/null || true
            sleep 1
            sudo systemctl restart NetworkManager 2>/dev/null || true
            sudo systemctl enable --now iwd 2>/dev/null || true
            sudo systemctl disable wpa_supplicant 2>/dev/null || true
            
            touch "$state_file"
            echo "IWD instalado. Reinicie para aplicar."
        fi
    fi
}

yay() {
    local state_file="$STATE_DIR/yay"
    local pkg_yay="yay"
    
    if [ -f "$state_file" ] || (pacman -Q yay &>/dev/null); then
        if confirm "Yay detectado. Desinstalar?"; then
            echo "Desinstalando Yay..."
            
            if pacman -Qq yay &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_yay || true
            fi
            
            cleanup_files "$state_file" "/tmp/yay"
            echo "Yay desinstalado."
        fi
    else
        if confirm "Instalar Yay (AUR helper)?"; then
            echo "Instalando Yay..."
            
            sudo pacman -S --noconfirm base-devel yay
            
            touch "$state_file"
            echo "Yay instalado."
        fi
    fi
}

fish_basic() {
    local state_file="$STATE_DIR/fish_basic"
    local pkg_fish="fish"
    
    if [ -f "$state_file" ] || (pacman -Q fish &>/dev/null); then
        if confirm "Fish básico detectado. Desinstalar?"; then
            echo "Desinstalando Fish básico..."
            
            if pacman -Qq fish &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_fish || true
            fi
            
            sudo chsh -s "$(which bash)" "$USER" 2>/dev/null || true
            
            cleanup_files "$state_file" "$HOME/.config/fish"
            echo "Fish básico desinstalado."
        fi
    else
        if confirm "Instalar Fish básico?"; then
            echo "Instalando Fish básico..."
            
            sudo pacman -S --noconfirm $pkg_fish
            sudo chsh -s "$(which fish)" "$USER"
            
            mkdir -p ~/.config/fish
            echo "set fish_greeting" > ~/.config/fish/config.fish
            
            touch "$state_file"
            echo "Fish básico instalado."
        fi
    fi
}

fisher() {
    local state_file="$STATE_DIR/fisher"
    local pkg_fish="fish fisher"
    
    if [ -f "$state_file" ] || (pacman -Q fisher &>/dev/null); then
        if confirm "Fisher detectado. Desinstalar?"; then
            echo "Desinstalando Fisher..."
            
            if pacman -Qq fish fisher &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_fish || true
            fi
            
            sudo chsh -s "$(which bash)" "$USER" 2>/dev/null || true
            
            cleanup_files "$state_file" "$HOME/.config/fish"
            echo "Fisher desinstalado."
        fi
    else
        if confirm "Instalar Fisher?"; then
            echo "Instalando Fisher..."
            
            sudo pacman -S --noconfirm $pkg_fish
            sudo chsh -s "$(which fish)" "$USER"
            
            mkdir -p ~/.config/fish
            echo "set fish_greeting" > ~/.config/fish/config.fish
            
            fish -c "fisher install jorgebucaran/fisher" 2>/dev/null || true
            
            touch "$state_file"
            echo "Fisher instalado."
        fi
    fi
}

fish_menu() {
    while true; do
        clear
        echo "=== Fish Shell ==="
        echo "1) Fish Básico (sem Fisher)"
        echo "2) Fish com Fisher"
        echo "3) Voltar"
        echo
        read -p "Selecione uma opção: " opcao
        
        case $opcao in
            1) clear; fish_basic ;;
            2) clear; fisher ;;
            3) return ;;
            *) ;;
        esac
        
        [ "$opcao" -ge 1 ] && [ "$opcao" -le 2 ] && read -p "Pressione Enter para continuar..."
    done
}

ufw() {
    local state_file="$STATE_DIR/ufw"
    local pkg_ufw="ufw"
    
    if [ -f "$state_file" ] || (pacman -Q ufw &>/dev/null); then
        if confirm "UFW detectado. Desinstalar?"; then
            echo "Desinstalando UFW..."
            
            if systemctl is-active --quiet ufw 2>/dev/null; then
                sudo systemctl stop ufw || true
            fi
            
            if systemctl is-enabled --quiet ufw 2>/dev/null; then
                sudo systemctl disable ufw || true
            fi
            
            if pacman -Qq ufw &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_ufw || true
            fi
            
            sudo rm -rf /etc/ufw /lib/ufw /usr/share/ufw /var/lib/ufw 2>/dev/null || true
            sudo rm -f /usr/bin/ufw /usr/sbin/ufw 2>/dev/null || true
            
            cleanup_files "$state_file"
            echo "UFW desinstalado."
        fi
    else
        if confirm "Instalar UFW?"; then
            echo "Instalando UFW..."
            
            sudo pacman -S --noconfirm $pkg_ufw
            
            sudo ufw default deny incoming
            sudo ufw default allow outgoing
            sudo ufw allow 53317/udp
            sudo ufw allow 53317/tcp
            sudo ufw allow 1714:1764/udp
            sudo ufw allow 1714:1764/tcp
            
            sudo systemctl enable ufw
            sudo ufw --force enable
            
            sudo ufw status verbose
            touch "$state_file"
            echo "UFW instalado e configurado."
        fi
    fi
}

gamescope() {
    local state_file="$STATE_DIR/gamescope"
    local pkg_gamescope="gamescope"
    
    if [ -f "$state_file" ] || (pacman -Q gamescope &>/dev/null); then
        if confirm "Gamescope detectado. Desinstalar?"; then
            echo "Desinstalando Gamescope..."
            
            if pacman -Qq gamescope &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_gamescope || true
            fi
            
            flatpak uninstall --user -y org.freedesktop.Platform.VulkanLayer.gamescope 2>/dev/null || true
            
            cleanup_files "$state_file"
            echo "Gamescope desinstalado."
        fi
    else
        if confirm "Instalar Gamescope?"; then
            echo "Instalando Gamescope..."
            
            sudo pacman -S --noconfirm $pkg_gamescope
            
            if ensure_flatpak; then
                flatpak install --user --noninteractive flathub org.freedesktop.Platform.VulkanLayer.gamescope 2>/dev/null || true
            fi
            
            touch "$state_file"
            echo "Gamescope instalado."
        fi
    fi
}

starship() {
    local state_file="$STATE_DIR/starship"
    local pkg_starship="starship"
    
    if [ -f "$state_file" ] || (pacman -Q starship &>/dev/null); then
        if confirm "Starship detectado. Desinstalar?"; then
            echo "Desinstalando Starship..."
            
            if pacman -Qq starship &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_starship || true
            fi
            
            sed -i '/starship init/d' ~/.bashrc 2>/dev/null || true
            sed -i '/starship init/d' ~/.zshrc 2>/dev/null || true
            
            if [ -f ~/.config/fish/config.fish ]; then
                sed -i '/starship init fish/d' ~/.config/fish/config.fish 2>/dev/null || true
            fi
            
            cleanup_files "$state_file"
            echo "Starship desinstalado."
        fi
    else
        if confirm "Instalar Starship?"; then
            echo "Instalando Starship..."
            
            sudo pacman -S --noconfirm $pkg_starship
            
            if [ -f ~/.bashrc ]; then
                grep -q "starship init" ~/.bashrc || echo -e "\neval \"\$(starship init bash)\"" >> ~/.bashrc
            fi
            
            if [ -f ~/.zshrc ]; then
                grep -q "starship init" ~/.zshrc || echo -e "\neval \"\$(starship init zsh)\"" >> ~/.zshrc
            fi
            
            if command -v fish &>/dev/null; then
                mkdir -p ~/.config/fish
                if [ -f ~/.config/fish/config.fish ]; then
                    grep -q "starship init fish" ~/.config/fish/config.fish || echo -e "\nstarship init fish | source" >> ~/.config/fish/config.fish
                else
                    echo -e "starship init fish | source" >> ~/.config/fish/config.fish
                fi
            fi
            
            touch "$state_file"
            echo "Starship instalado."
        fi
    fi
}

nix_packages() {
    local state_file="$STATE_DIR/nix_packages"
    local pkg_nix="nix"
    
    if [ -f "$state_file" ] || (pacman -Q nix &>/dev/null) || [ -d "$HOME/.nix-profile" ]; then
        if confirm "Nix Packages detectado. Desinstalar?"; then
            echo "Desinstalando Nix Packages..."
            
            if pacman -Qq nix &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_nix || true
            fi
            
            rm -rf "$HOME/.nix-profile" "$HOME/.nix-defexpr" "$HOME/.nix-channels" 2>/dev/null || true
            sudo rm -rf /nix /etc/nix /etc/profile.d/nix-daemon.sh 2>/dev/null || true
            
            sed -i '/nix-profile/d' ~/.bashrc ~/.profile ~/.bash_profile 2>/dev/null || true
            sed -i '/XDG_DATA_DIRS.*nix-profile/d' ~/.profile ~/.bash_profile 2>/dev/null || true
            sed -i '/source.*nix.sh/d' ~/.bashrc 2>/dev/null || true
            
            cleanup_files "$state_file"
            echo "Nix Packages desinstalado."
        fi
    else
        if confirm "Instalar Nix Packages?"; then
            echo "Instalando Nix Packages..."
            
            sudo pacman -S --noconfirm $pkg_nix
            
            if [ -f ~/.bashrc ]; then
                echo -e 'export PATH="$HOME/.nix-profile/bin:$PATH"' >> ~/.bashrc
            fi
            
            if [ -f ~/.profile ]; then
                echo -e 'export XDG_DATA_DIRS="$HOME/.nix-profile/share:$XDG_DATA_DIRS"' >> ~/.profile
            fi
            
            if [ -f ~/.bash_profile ]; then
                echo -e 'export XDG_DATA_DIRS="$HOME/.nix-profile/share:$XDG_DATA_DIRS"' >> ~/.bash_profile
            fi
            
            touch "$state_file"
            echo "Nix Packages instalado."
        fi
    fi
}

flathub() {
    local state_file="$STATE_DIR/flathub"
    local pkg_flatpak="flatpak"
    
    if [ -f "$state_file" ] || (pacman -Q flatpak &>/dev/null); then
        if confirm "Flathub detectado. Desinstalar?"; then
            echo "Desinstalando Flathub..."
            
            if pacman -Qq flatpak &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_flatpak || true
            fi
            
            rm -rf "$HOME/.local/share/flatpak" 2>/dev/null || true
            sudo rm -rf /var/lib/flatpak 2>/dev/null || true
            
            cleanup_files "$state_file"
            echo "Flathub desinstalado."
        fi
    else
        if confirm "Instalar Flathub?"; then
            echo "Instalando Flathub..."
            
            sudo pacman -S --noconfirm $pkg_flatpak
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
            
            touch "$state_file"
            echo "Flathub instalado."
        fi
    fi
}

ananicy_cpp() {
    local state_file="$STATE_DIR/ananicy_cpp"
    local pkg_ananicy="ananicy-cpp cachyos-ananicy-rules-git"
    
    if [ -f "$state_file" ] || (pacman -Q ananicy-cpp &>/dev/null); then
        if confirm "Ananicy-cpp detectado. Desinstalar?"; then
            echo "Desinstalando Ananicy-cpp..."
            
            sudo systemctl stop ananicy-cpp.service 2>/dev/null || true
            sudo systemctl disable ananicy-cpp.service 2>/dev/null || true
            
            if pacman -Qq ananicy-cpp cachyos-ananicy-rules-git &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_ananicy || true
            fi
            
            cleanup_files "$state_file"
            echo "Ananicy-cpp desinstalado."
        fi
    else
        if confirm "Instalar Ananicy-cpp?"; then
            echo "Instalando Ananicy-cpp..."
            
            sudo pacman -S --noconfirm $pkg_ananicy
            sudo systemctl enable --now ananicy-cpp.service
            touch "$state_file"
            echo "Ananicy-cpp instalado."
        fi
    fi
}

hwaccel_flatpak() {
    local state_file="$STATE_DIR/hwaccel_flatpak"
    
    if [ -f "$state_file" ] || (flatpak list | grep -q freedesktop.Platform.VAAPI 2>/dev/null); then
        if confirm "HW Acceleration Flatpak detectado. Desinstalar?"; then
            echo "Desinstalando HW Acceleration Flatpak..."
            
            flatpak uninstall --user -y freedesktop.Platform.VAAPI 2>/dev/null || true
            flatpak uninstall --user -y freedesktop.Platform.VAAPI.Intel 2>/dev/null || true
            
            cleanup_files "$state_file"
            echo "HW Acceleration Flatpak desinstalado."
        fi
    else
        if confirm "Instalar HW Acceleration Flatpak?"; then
            echo "Instalando HW Acceleration Flatpak..."
            
            if ensure_flatpak; then
                flatpak install --user -y flathub org.freedesktop.Platform.VAAPI.Intel 2>/dev/null || true
                flatpak override --user --device=all --env=GDK_SCALE=1 --env=GDK_DPI_SCALE=1 2>/dev/null || true
                touch "$state_file"
                echo "HW Acceleration Flatpak instalado."
            fi
        fi
    fi
}

appimage_fuse() {
    local state_file="$STATE_DIR/appimage_fuse"
    local pkg_fuse="fuse2 fuse3"
    
    if [ -f "$state_file" ] || (pacman -Q fuse2 &>/dev/null); then
        if confirm "FUSE para AppImage detectado. Desinstalar?"; then
            echo "Desinstalando FUSE para AppImage..."
            
            if pacman -Qq fuse2 &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_fuse || true
            fi
            
            cleanup_files "$state_file"
            echo "FUSE para AppImage desinstalado."
        fi
    else
        if confirm "Instalar FUSE para AppImage?"; then
            echo "Instalando FUSE para AppImage..."
            
            sudo pacman -S --noconfirm $pkg_fuse
            touch "$state_file"
            echo "FUSE para AppImage instalado."
        fi
    fi
}

earlyoom() {
    local state_file="$STATE_DIR/earlyoom"
    local pkg_earlyoom="earlyoom"
    
    if [ -f "$state_file" ] || (pacman -Q earlyoom &>/dev/null); then
        if confirm "EarlyOOM detectado. Desinstalar?"; then
            echo "Desinstalando EarlyOOM..."
            
            sudo systemctl stop earlyoom 2>/dev/null || true
            sudo systemctl disable earlyoom 2>/dev/null || true
            
            if pacman -Qq earlyoom &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_earlyoom || true
            fi
            
            cleanup_files "$state_file"
            echo "EarlyOOM desinstalado."
        fi
    else
        if confirm "Instalar EarlyOOM?"; then
            echo "Instalando EarlyOOM..."
            
            sudo pacman -S --noconfirm $pkg_earlyoom
            sudo systemctl enable earlyoom
            sudo systemctl start earlyoom
            
            touch "$state_file"
            echo "EarlyOOM instalado."
        fi
    fi
}

gamemode() {
    local state_file="$STATE_DIR/gamemode"
    local pkg_gamemode="gamemode lib32-gamemode"
    
    if [ -f "$state_file" ] || (pacman -Q gamemode &>/dev/null); then
        if confirm "Gamemode detectado. Desinstalar?"; then
            echo "Desinstalando Gamemode..."
            
            if pacman -Qq gamemode &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_gamemode || true
            fi
            
            cleanup_files "$state_file"
            echo "Gamemode desinstalado."
        fi
    else
        if confirm "Instalar Gamemode?"; then
            echo "Instalando Gamemode..."
            
            sudo pacman -S --noconfirm $pkg_gamemode
            touch "$state_file"
            echo "Gamemode instalado."
        fi
    fi
}

oh_my_bash() {
    local state_file="$STATE_DIR/oh_my_bash"
    local osh_dir="$HOME/.oh-my-bash"
    
    if [ -f "$state_file" ] || [ -d "$osh_dir" ]; then
        if confirm "Oh My Bash detectado. Desinstalar?"; then
            echo "Desinstalando Oh My Bash..."
            
            if [ -d "$osh_dir" ]; then
                yes | "$osh_dir"/tools/uninstall.sh 2>/dev/null || true
            fi
            
            cleanup_files "$state_file"
            echo "Oh My Bash desinstalado."
        fi
    else
        if confirm "Instalar Oh My Bash?"; then
            echo "Instalando Oh My Bash..."
            
            bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended
            touch "$state_file"
            echo "Oh My Bash instalado."
        fi
    fi
}

nvim_basic() {
    local state_file="$STATE_DIR/nvim_basic"
    local pkg_neovim="neovim"
    
    if [ -f "$state_file" ] || (pacman -Q neovim &>/dev/null); then
        if confirm "NeoVim básico detectado. Desinstalar?"; then
            echo "Desinstalando NeoVim básico..."
            
            sudo pacman -Rsnu --noconfirm $pkg_neovim || true
            cleanup_files "$state_file"
            echo "NeoVim básico desinstalado."
        fi
    else
        if confirm "Instalar NeoVim básico?"; then
            echo "Instalando NeoVim básico..."
            
            sudo pacman -S --noconfirm $pkg_neovim
            touch "$state_file"
            echo "NeoVim básico instalado."
        fi
    fi
}

nvim_lazyman() {
    local state_file="$STATE_DIR/nvim_lazyman"
    local pkg_neovim="neovim git"
    local lazyman_dir="$HOME/.config/nvim-Lazyman"
    
    if [ -f "$state_file" ] || [ -d "$lazyman_dir" ]; then
        if confirm "Lazyman detectado. Desinstalar?"; then
            echo "Desinstalando Lazyman..."
            
            cleanup_files "$state_file" "$lazyman_dir"
            echo "Lazyman desinstalado."
        fi
    else
        if confirm "Instalar Lazyman?"; then
            echo "Instalando Lazyman..."
            
            sudo pacman -S --noconfirm $pkg_neovim
            
            cleanup_files "$lazyman_dir"
            git clone https://github.com/doctorfree/nvim-lazyman "$lazyman_dir"
            "$lazyman_dir"/lazyman.sh
            
            touch "$state_file"
            echo "Lazyman instalado."
        fi
    fi
}

nvim_lazyvim() {
    local state_file="$STATE_DIR/nvim_lazyvim"
    local nvim_dir="$HOME/.config/nvim"
    
    if [ -f "$state_file" ] || [ -d "$nvim_dir" ]; then
        if confirm "LazyVim detectado. Desinstalar?"; then
            echo "Desinstalando LazyVim..."
            
            cleanup_files "$state_file" "$nvim_dir"
            echo "LazyVim desinstalado."
        fi
    else
        if confirm "Instalar LazyVim?"; then
            echo "Instalando LazyVim..."
            
            cleanup_files "$nvim_dir"
            git clone https://github.com/LazyVim/starter "$nvim_dir"
            rm -rf "$nvim_dir/.git"
            
            touch "$state_file"
            echo "LazyVim instalado."
        fi
    fi
}

nvim() {
    while true; do
        clear
        echo "=== NeoVim ==="
        echo "1) NeoVim Básico"
        echo "2) Lazyman"
        echo "3) LazyVim Direto"
        echo "4) Voltar"
        echo
        read -p "Selecione uma opção: " opcao
        
        case $opcao in
            1) clear; nvim_basic ;;
            2) clear; nvim_lazyman ;;
            3) clear; nvim_lazyvim ;;
            4) return ;;
            *) ;;
        esac
        
        [ "$opcao" -ge 1 ] && [ "$opcao" -le 3 ] && read -p "Pressione Enter para continuar..."
    done
}

de_cosmic() {
    local state_file="$STATE_DIR/de_cosmic"
    local pkg_base="noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-noto-nerd noto-fonts-extra ttf-jetbrains-mono"
    local pkg_media="ffmpeg gst-plugins-ugly gst-plugins-good gst-plugins-base gst-plugins-bad gst-libav gstreamer"
    local pkg_cosmic="cosmic-session cosmic-terminal cosmic-files cosmic-store cosmic-wallpapers xdg-user-dirs croc gdu"
    
    if [ -f "$state_file" ] || (pacman -Q cosmic-session &>/dev/null); then
        if confirm "Cosmic detectado. Desinstalar?"; then
            echo "Desinstalando Cosmic..."
            
            sudo systemctl disable cosmic-greeter 2>/dev/null || true
            sudo pacman -Rsnu --noconfirm $pkg_cosmic || true
            sudo pacman -Rsnu --noconfirm $pkg_media || true
            sudo pacman -Rsnu --noconfirm $pkg_base || true
            
            cleanup_files "$state_file"
            echo "Cosmic desinstalado."
        fi
    else
        if confirm "Instalar Cosmic?"; then
            echo "Instalando Cosmic..."
            
            sudo pacman -S --noconfirm $pkg_base
            sudo pacman -S --noconfirm $pkg_media
            sudo pacman -S --noconfirm $pkg_cosmic
            sudo systemctl enable cosmic-greeter
            
            touch "$state_file"
            echo "Cosmic instalado. Reinicie para aplicar."
        fi
    fi
}

de_gnome() {
    local state_file="$STATE_DIR/de_gnome"
    local pkg_base="noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-noto-nerd noto-fonts-extra ttf-jetbrains-mono"
    local pkg_media="ffmpeg gst-plugins-ugly gst-plugins-good gst-plugins-base gst-plugins-bad gst-libav gstreamer"
    local pkg_gnome="gnome-shell gnome-console gnome-software gnome-tweaks gnome-control-center gnome-disk-utility gdm"
    
    if [ -f "$state_file" ] || (pacman -Q gnome-shell &>/dev/null); then
        if confirm "Gnome detectado. Desinstalar?"; then
            echo "Desinstalando Gnome..."
            
            sudo systemctl disable gdm 2>/dev/null || true
            sudo pacman -Rsnu --noconfirm $pkg_gnome || true
            sudo pacman -Rsnu --noconfirm $pkg_media || true
            sudo pacman -Rsnu --noconfirm $pkg_base || true
            
            cleanup_files "$state_file"
            echo "Gnome desinstalado."
        fi
    else
        if confirm "Instalar Gnome?"; then
            echo "Instalando Gnome..."
            
            sudo pacman -S --noconfirm $pkg_base
            sudo pacman -S --noconfirm $pkg_media
            sudo pacman -S --noconfirm $pkg_gnome
            sudo systemctl enable gdm
            
            touch "$state_file"
            echo "Gnome instalado. Reinicie para aplicar."
        fi
    fi
}

de_plasma() {
    local state_file="$STATE_DIR/de_plasma"
    local pkg_base="noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-noto-nerd noto-fonts-extra ttf-jetbrains-mono"
    local pkg_media="ffmpeg gst-plugins-ugly gst-plugins-good gst-plugins-base gst-plugins-bad gst-libav gstreamer"
    local pkg_plasma="plasma-meta konsole dolphin discover kdeconnect partitionmanager ffmpegthumbs dolphin-plugins ark"
    
    if [ -f "$state_file" ] || (pacman -Q plasma-meta &>/dev/null); then
        if confirm "Plasma detectado. Desinstalar?"; then
            echo "Desinstalando Plasma..."
            
            sudo systemctl disable sddm 2>/dev/null || true
            sudo pacman -Rsnu --noconfirm $pkg_plasma || true
            sudo pacman -Rsnu --noconfirm $pkg_media || true
            sudo pacman -Rsnu --noconfirm $pkg_base || true
            
            cleanup_files "$state_file"
            echo "Plasma desinstalado."
        fi
    else
        if confirm "Instalar Plasma?"; then
            echo "Instalando Plasma..."
            
            sudo pacman -S --noconfirm $pkg_base
            sudo pacman -S --noconfirm $pkg_media
            sudo pacman -S --noconfirm $pkg_plasma
            sudo systemctl enable sddm
            
            touch "$state_file"
            echo "Plasma instalado. Reinicie para aplicar."
        fi
    fi
}

de() {
    while true; do
        clear
        echo "=== Ambientes Desktop ==="
        echo "1) Cosmic"
        echo "2) Gnome"
        echo "3) Plasma"
        echo "4) Voltar"
        echo
        read -p "Selecione uma opção: " opcao
        
        case $opcao in
            1) clear; de_cosmic ;;
            2) clear; de_gnome ;;
            3) clear; de_plasma ;;
            4) return ;;
            *) ;;
        esac
        
        [ "$opcao" -ge 1 ] && [ "$opcao" -le 3 ] && read -p "Pressione Enter para continuar..."
    done
}

apparmor() {
    local state_file="$STATE_DIR/apparmor"
    local pkg_apparmor="apparmor"
    
    if [ -f "$state_file" ] || (pacman -Q apparmor &>/dev/null); then
        if confirm "AppArmor detectado. Desinstalar?"; then
            echo "Desinstalando AppArmor..."
            
            sudo systemctl stop apparmor 2>/dev/null || true
            sudo systemctl disable apparmor 2>/dev/null || true
            
            sudo rm -f /etc/default/grub.d/99-apparmor.cfg 2>/dev/null || true
            sudo rm -f /etc/kernel/cmdline.d/99-apparmor.conf 2>/dev/null || true
            
            sudo mkdir -p /boot/grub 2>/dev/null || true
            sudo grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || true
            sudo bootctl update 2>/dev/null || true
            
            if pacman -Qq apparmor &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_apparmor || true
            fi
            
            cleanup_files "$state_file"
            echo "AppArmor desinstalado."
        fi
    else
        if confirm "Instalar AppArmor?"; then
            echo "Instalando AppArmor..."
            
            sudo pacman -S --noconfirm $pkg_apparmor
            
            if pacman -Qq grub &>/dev/null; then
                sudo mkdir -p /etc/default/grub.d
                echo 'GRUB_CMDLINE_LINUX_DEFAULT="${GRUB_CMDLINE_LINUX_DEFAULT} apparmor=1 security=apparmor"' | sudo tee /etc/default/grub.d/99-apparmor.cfg
                sudo mkdir -p /boot/grub 2>/dev/null || true
                sudo grub-mkconfig -o /boot/grub/grub.cfg
            else
                sudo mkdir -p /etc/kernel/cmdline.d
                echo "apparmor=1 security=apparmor" | sudo tee /etc/kernel/cmdline.d/99-apparmor.conf
                sudo bootctl update 2>/dev/null || true
            fi
            
            sudo systemctl enable apparmor
            touch "$state_file"
            echo "AppArmor instalado. Reinicie para aplicar."
        fi
    fi
}

chaotic_aur() {
    local state_file="$STATE_DIR/chaotic_aur"
    local pkg_chaotic="chaotic-keyring chaotic-mirrorlist"
    
    if [ -f "$state_file" ] || (pacman -Q chaotic-keyring &>/dev/null && pacman -Q chaotic-mirrorlist &>/dev/null); then
        if confirm "Chaotic AUR detectado. Desinstalar?"; then
            echo "Desinstalando Chaotic AUR..."
            
            sudo sed -i '/\[chaotic-aur\]/,/^$/d' /etc/pacman.conf 2>/dev/null || true
            
            if pacman -Qq chaotic-keyring chaotic-mirrorlist &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_chaotic || true
            fi
            
            sudo pacman-key --delete 3056513887B78AEB 2>/dev/null || true
            sudo sed -i '/^ILoveCandy/d' /etc/pacman.conf 2>/dev/null || true
            sudo sed -i '/^ParallelDownloads/d' /etc/pacman.conf 2>/dev/null || true
            
            cleanup_files "$state_file"
            echo "Chaotic AUR desinstalado."
        fi
    else
        if confirm "Instalar Chaotic AUR?"; then
            echo "Instalando Chaotic AUR..."
            
            sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
            sudo pacman-key --lsign-key 3056513887B78AEB
            
            sudo pacman -U --noconfirm \
                "https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst" \
                "https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst"
            
            sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
            sudo sed -i '/Color/a ILoveCandy' /etc/pacman.conf
            sudo sed -i '/^ParallelDownloads/d' /etc/pacman.conf
            sudo sed -i '/ILoveCandy/a ParallelDownloads = 15' /etc/pacman.conf
            
            echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
            
            sudo pacman -Syu
            touch "$state_file"
            echo "Chaotic AUR instalado."
        fi
    fi
}

dnsmasq() {
    local state_file="$STATE_DIR/dnsmasq"
    local pkg_dnsmasq="dnsmasq"
    
    if [ -f "$state_file" ] || (pacman -Q dnsmasq &>/dev/null); then
        if confirm "DNSMasq detectado. Desinstalar?"; then
            echo "Desinstalando DNSMasq..."
            
            sudo systemctl stop dnsmasq 2>/dev/null || true
            sudo systemctl disable dnsmasq 2>/dev/null || true
            
            if pacman -Qq dnsmasq &>/dev/null; then
                sudo pacman -Rsnu --noconfirm $pkg_dnsmasq || true
            fi
            
            sudo rm -rf /etc/dnsmasq.d /etc/dnsmasq.conf 2>/dev/null || true
            cleanup_files "$state_file"
            echo "DNSMasq desinstalado."
        fi
    else
        if confirm "Instalar DNSMasq?"; then
            echo "Instalando DNSMasq..."
            
            sudo pacman -S --noconfirm $pkg_dnsmasq
            sudo systemctl enable dnsmasq
            touch "$state_file"
            echo "DNSMasq instalado."
        fi
    fi
}

lucidglyph() {
    local state_file="$STATE_DIR/lucidglyph"
    
    if [ -f "$state_file" ] || \
       [ -f "/usr/share/lucidglyph/info" ] || \
       [ -f "/usr/share/freetype-envision/info" ] || \
       [ -f "$HOME/.local/share/lucidglyph/info" ] || \
       { [ -d "/etc/fonts/conf.d" ] && find "/etc/fonts/conf.d" -name "*lucidglyph*" -o -name "*freetype-envision*" 2>/dev/null | grep -q .; }; then
        
        if confirm "LucidGlyph detectado. Desinstalar?"; then
            echo "Desinstalando LucidGlyph..."
            
            for uninstaller in "/usr/share/lucidglyph/uninstaller.sh" \
                              "/usr/share/freetype-envision/uninstaller.sh" \
                              "$HOME/.local/share/lucidglyph/uninstaller.sh"; do
                if [ -f "$uninstaller" ] && [ -x "$uninstaller" ]; then
                    sudo "$uninstaller" || true
                    break
                fi
            done
            
            cleanup_files "$state_file"
            sudo rm -f /etc/fonts/conf.d/*lucidglyph* /etc/fonts/conf.d/*freetype-envision* 2>/dev/null || true
            rm -f "$HOME/.config/fontconfig/conf.d/"*lucidglyph* "$HOME/.config/fontconfig/conf.d/"*freetype-envision* 2>/dev/null || true
            sudo sed -i '/LUCIDGLYPH\|FREETYPE_ENVISION/d' /etc/environment 2>/dev/null || true
            sudo fc-cache -f || true
            echo "LucidGlyph desinstalado."
        fi
    else
        if confirm "Instalar LucidGlyph?"; then
            echo "Instalando LucidGlyph..."
            
            local tag=$(curl -s "https://api.github.com/repos/maximilionus/lucidglyph/releases/latest" | grep -oP '"tag_name": "\K(.*)(?=")')
            local ver="${tag#v}"
            
            cd "$HOME" || exit 1
            cleanup_files "${tag}.tar.gz" "lucidglyph-${ver}"
            
            curl -L -o "${tag}.tar.gz" "https://github.com/maximilionus/lucidglyph/archive/refs/tags/${tag}.tar.gz"
            tar -xvzf "${tag}.tar.gz"
            cd "lucidglyph-${ver}" || exit 1
            
            chmod +x lucidglyph.sh
            sudo ./lucidglyph.sh install
            
            cd .. || exit 1
            cleanup_files "${tag}.tar.gz" "lucidglyph-${ver}"
            
            touch "$state_file"
            echo "LucidGlyph instalado."
        fi
    fi
}

shader_booster() {
    local state_file="$STATE_DIR/shader_booster"
    local boost_file="$HOME/.booster"
    
    if [ -f "$state_file" ] || [ -f "$boost_file" ]; then
        if confirm "Shader Booster detectado. Desinstalar?"; then
            echo "Desinstalando Shader Booster..."
            
            for shell_file in "$HOME/.bash_profile" "$HOME/.profile" "$HOME/.zshrc"; do
                if [ -f "$shell_file" ]; then
                    sed -i '/# Shader Booster patches/,/# End Shader Booster/d' "$shell_file" 2>/dev/null || true
                fi
            done
            
            cleanup_files "$state_file" "$boost_file" "$HOME/patch-nvidia" "$HOME/patch-mesa"
            echo "Shader Booster desinstalado."
        fi
    else
        if confirm "Instalar Shader Booster?"; then
            echo "Instalando Shader Booster..."
            
            local has_nvidia=$(lspci | grep -i 'nvidia')
            local has_mesa=$(lspci | grep -Ei '(vga|3d)' | grep -vi nvidia)
            local patch_applied=0
            
            local dest_file=""
            for file in "$HOME/.bash_profile" "$HOME/.profile" "$HOME/.zshrc"; do
                if [ -f "$file" ]; then
                    dest_file="$file"
                    break
                fi
            done
            
            if [ -z "$dest_file" ]; then
                dest_file="$HOME/.bash_profile"
                touch "$dest_file"
            fi
            
            echo -e "\n# Shader Booster patches" >> "$dest_file"
            
            if [ -n "$has_nvidia" ]; then
                curl -s https://raw.githubusercontent.com/psygreg/shader-booster/main/patch-nvidia >> "$dest_file"
                patch_applied=1
            fi
            
            if [ -n "$has_mesa" ]; then
                curl -s https://raw.githubusercontent.com/psygreg/shader-booster/main/patch-mesa >> "$dest_file"
                patch_applied=1
            fi
            
            echo "# End Shader Booster" >> "$dest_file"
            
            if [ $patch_applied -eq 1 ]; then
                echo "1" > "$boost_file"
                touch "$state_file"
                echo "Shader Booster instalado. Reinicie para aplicar."
            else
                echo "Nenhuma GPU compatível detectada."
            fi
        fi
    fi
}

main() {
    while true; do
        clear
        echo "=== Scripts para Arch Linux ==="
        echo "1) Ambientes Desktop"
        echo "2) Android Studio"
        echo "3) Ananicy-cpp"
        echo "4) AppArmor"
        echo "5) AppImage FUSE"
        echo "6) Arch Secure Boot"
        echo "7) Btrfs Assistant"
        echo "8) CachyOS Configs"
        echo "9) Chaotic AUR"
        echo "10) CPU Ondemand"
        echo "11) Distrobox Command Handler"
        echo "12) DNSMasq"
        echo "13) Docker"
        echo "14) DsplitM"
        echo "15) EarlyOOM"
        echo "16) Fish Shell"
        echo "17) Flathub"
        echo "18) Gamemode"
        echo "19) Gamescope"
        echo "20) Godot Engine"
        echo "21) GRUB Btrfs"
        echo "22) HTTPie"
        echo "23) HW Acceleration Flatpak"
        echo "24) Insomnia"
        echo "25) IWD"
        echo "26) Java OpenJDK"
        echo "27) JetBrains Toolbox"
        echo "28) LucidGlyph"
        echo "29) Maven"
        echo "30) Microsoft Core Fonts"
        echo "31) MinFreeFix"
        echo "32) Mise"
        echo "33) NeoVim"
        echo "34) Nix Packages"
        echo "35) NVM"
        echo "36) Oh My Bash"
        echo "37) Oh My Zsh"
        echo "38) PNPM"
        echo "39) Portainer"
        echo "40) Postman"
        echo "41) Powersave"
        echo "42) Preload"
        echo "43) PyEnv"
        echo "44) SDKMAN"
        echo "45) Shader Booster"
        echo "46) Starship"
        echo "47) Sublime Text"
        echo "48) Swapfile"
        echo "49) Tailscale"
        echo "50) Thumbnailer"
        echo "51) UFW"
        echo "52) Visual Studio Code"
        echo "53) VSCodium"
        echo "54) WinBoat"
        echo "55) Yay"
        echo "56) Zed"
        echo "57) ZeroTier"
        echo "58) Sair"
        echo
        read -p "Selecione uma opção: " opcao
        
        case $opcao in
            1) clear; de ;;
            2) clear; android_studio ;;
            3) clear; ananicy_cpp ;;
            4) clear; apparmor ;;
            5) clear; appimage_fuse ;;
            6) clear; archsb ;;
            7) clear; btrfs_assistant ;;
            8) clear; cachyconfs ;;
            9) clear; chaotic_aur ;;
            10) clear; cpu_ondemand ;;
            11) clear; distrobox_handler ;;
            12) clear; dnsmasq ;;
            13) clear; docker ;;
            14) clear; dsplitm ;;
            15) clear; earlyoom ;;
            16) clear; fish_menu ;;
            17) clear; flathub ;;
            18) clear; gamemode ;;
            19) clear; gamescope ;;
            20) clear; godot ;;
            21) clear; grub_btrfs ;;
            22) clear; httpie ;;
            23) clear; hwaccel_flatpak ;;
            24) clear; insomnia ;;
            25) clear; iwd ;;
            26) clear; java_openjdk ;;
            27) clear; jetbrains_toolbox ;;
            28) clear; lucidglyph ;;
            29) clear; maven ;;
            30) clear; mscorefonts ;;
            31) clear; minfreefix ;;
            32) clear; mise ;;
            33) clear; nvim ;;
            34) clear; nix_packages ;;
            35) clear; nvm ;;
            36) clear; oh_my_bash ;;
            37) clear; oh_my_zsh ;;
            38) clear; pnpm ;;
            39) clear; portainer ;;
            40) clear; postman ;;
            41) clear; psaver ;;
            42) clear; preload ;;
            43) clear; pyenv ;;
            44) clear; sdkman ;;
            45) clear; shader_booster ;;
            46) clear; starship ;;
            47) clear; sublime_text ;;
            48) clear; swapfile ;;
            49) clear; tailscale ;;
            50) clear; thumbnailer ;;
            51) clear; ufw ;;
            52) clear; visual_studio_code ;;
            53) clear; vscodium ;;
            54) clear; winboat ;;
            55) clear; yay ;;
            56) clear; zed ;;
            57) clear; zerotier ;;
            58) exit 0 ;;
            *) ;;
        esac
        
        [ "$opcao" -ge 1 ] && [ "$opcao" -le 57 ] && read -p "Pressione Enter para continuar..."
    done
}

main
