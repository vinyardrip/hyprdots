# Path to your oh-my-zsh installation.
ZSH=/usr/share/oh-my-zsh/

# Path to powerlevel10k theme
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# List of plugins used
plugins=(
	git
	gulp
	sudo
	zsh-256color
	zsh-autosuggestions
	zsh-syntax-highlighting
	zoxide
)
source $ZSH/oh-my-zsh.sh
source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(zoxide init zsh)"

# asdf
#. /opt/asdf-vm/asdf.sh
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# gulp not working
PATH=$HOME/.node/bin:$PATH

# Use powerline
USE_POWERLINE="true"

# In case a command is not found, try to find the package that has it
function command_not_found_handler {
    local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
    printf 'zsh: command not found: %s\n' "$1"
    local entries=( ${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"} )
    if (( ${#entries[@]} )) ; then
        printf "${bright}$1${reset} may be found in the following packages:\n"
        local pkg
        for entry in "${entries[@]}" ; do
            local fields=( ${(0)entry} )
            if [[ "$pkg" != "${fields[2]}" ]] ; then
                printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
            fi
            printf '    /%s\n' "${fields[4]}"
            pkg="${fields[2]}"
        done
    fi
    return 127
}

# Detect the AUR wrapper
if pacman -Qi yay &>/dev/null ; then
   aurhelper="yay"
elif pacman -Qi paru &>/dev/null ; then
   aurhelper="paru"
fi

function in {
    local -a inPkg=("$@")
    local -a arch=()
    local -a aur=()

    for pkg in "${inPkg[@]}"; do
        if pacman -Si "${pkg}" &>/dev/null ; then
            arch+=("${pkg}")
        else
            aur+=("${pkg}")
        fi
    done

    if [[ ${#arch[@]} -gt 0 ]]; then
        sudo pacman -S "${arch[@]}"
    fi

    if [[ ${#aur[@]} -gt 0 ]]; then
        ${aurhelper} -S "${aur[@]}"
    fi
}

# Helpful aliases
alias  c='clear' # clear terminal
alias l='eza -1   --icons=auto' # long list
alias ls='eza -lh  --icons=auto' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs

alias lt='eza --icons=auto --tree -L 1' # list folder as tree
alias lt2='eza --icons=auto --tree -L 2'
alias lt3='eza --icons=auto --tree -L 3'
alias lt4='eza --icons=auto --tree -L 4'
alias lt5='eza --icons=auto --tree -L 5'

alias in='$aurhelper -S' # install package
alias un='$aurhelper -Rns' # uninstall package
alias up='$aurhelper -Syu' # update system/package/aur
alias pl='$aurhelper -Qs' # list installed package
alias pa='$aurhelper -Ss' # list availabe package
alias pc='$aurhelper -Sc' # remove unused cache
alias po='$aurhelper -Qtdq | $aurhelper -Rns -' # remove unused packages, also try > $aurhelper -Qqd | $aurhelper -Rsu --print -
alias vc='code' # gui code editor

alias du='gdu'
alias cat='bat'
alias top='btop'

# weather in terminal
alias weather='wttrbar'

# Handy change dir shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'


# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
alias mkdir='mkdir -pv'

# reflector with options
alias refup='sudo reflector -c BY -c RU -c UA -a 5 --verbose --sort rate --save /etc/pacman.d/mirrorlist && echo "--- mirrors update! ---"'

# alias update grub
alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'

# aliases warp
alias w_stop='sudo systemctl stop warp-svc | echo "--- warp stopped! ---"' # stop warp
alias w_start='sudo systemctl start warp-svc | echo "--- warp started! ---"' # start warp

# Devilbox
# Path to work directory
project_path=~/projects/work
# Path to devilbox directory
devilbox_path=$project_path/devilbox
# Service alias docker php container start
alias php_container='docker-compose up -d httpd php mysql mailhog'

start_devilbox() {
    cd $devilbox_path;
    if [[ -f "env" ]] ; then
        echo " Сервер php запущен \n Остановить сервер командой \n finish_devilbox";
    elif [[ -z "$1" ]] ; then
        echo " Задайте версию php сервера: \n $0 6 \n $0 7 \n $0 8";
    elif ! [[ -f .env-$1 ]] ; then
        echo " Неверная версия php сервера";
    elif ! [[ -f "env" ]] ; then
        mv .env env && mv .env-$1 .env && php_container && echo " server php-$1 start";
    else
        echo " Неизвестная ошибка";
    fi
}

finish_devilbox() {
    if ! [[ -f "env" ]] ; then
        echo " Нет запущенных php серверов";
    elif [[ -z "$1" ]] ; then
        echo " Выберите версию php сервера для останова: \n $0 6 \n $0 7 \n $0 8";
    elif [[ -f .env-$1 ]] ; then
        echo " Неверная версия php сервера";
    elif [[ -f "env" && -f ".env" && ! -f .env-$1 && $1 -gt 5 && $1 -lt 9 ]] ; then
        docker-compose stop && mv .env .env-$1 && mv env .env && echo " server php-$1 finish";
    else
        echo " Версия php сервера может быть: \n 6, \n 7, \n 8";
    fi
}

# path devilbox projects
devilbox_domain_path=$devilbox_path/data
add_domain() {
	cd $devilbox_domain_path
	if ! [[ -d $1 ]] ; then
		mkdir $1;
		sudo sh -c  "echo '127.0.0.1  $1.loc' >> /etc/hosts";
		cd $1;
	else
		echo "Папка уже существует";
		cd ~;
	fi
}

# Browser-sync
sync_site() {
    cd $devilbox_path/data;
    browser-sync start -p https://'wp-'$1.loc -f "**/*.php";
}

# Wp start 7
#wp_7() {
#   cd $devilbox_path/data;
#   curl -O https://wordpress.org/latest.zip;
#   unzip latest.zip;
#   mv wordpress 'wp-'$1;
#   rm -f latest.zip ;
#   cp -r $project_path/_s-template $devilbox_path/data/'wp-'$1;
#   sudo nano /etc/hosts;
#   start_devilbox 7;
#   sleep 5;
#   google-chrome-stable http://localhost:80/vhosts.php;
#   code $devilbox_path/data/'wp-'$1;
#}

# Wp start
wp_start() {
    cd $devilbox_path/data
    curl -O https://wordpress.org/latest.zip;
    unzip latest.zip;
    mv wordpress 'wp-'$1;
    rm -f latest.zip;
    cp -r $project_path/_s-template $devilbox_path/data/'wp-'$1;
    sudo nano /etc/hosts;
    start_devilbox 8;
    sleep 5;
    google-chrome-stable http://localhost:80/vhosts.php;
    code $devilbox_path/data/'wp-'$1;
}

# yt-dlp (audio)
yt_mp3() {
	cd ~/Downloads;
	mkdir $1;
	cd $1;
	yt-dlp -f ba -x --audio-quality 0 --audio-format mp3 --split-chapters $2;
	echo '--- Done! ---';
}
# yt-dlp (video)
alias yt_mp4='yt-dlp --format-sort codec:h264:mp4a'
alias yt_mkv='yt-dlp -f "bestvideo[ext=mkv]+bestaudio[ext=mka]/best[ext=mkv]/best"'
alias yt_best_video='yt-dlp -f "bv*+ba"'

# -a == &&
# -o == ||
# -eq is equal to - равняется ( = or == )
# -ne is not equal to - не равняется ( != )
# -gt is greater than - больше чем ( > )
# -ge is greater than or equal to - больше или равно ( >= )
# -lt is less than - меньше чем ( < )
# -le  is less than or equal to - меньше или равно ( <= )

# -z Пустая переменная, строка пустая, то есть имеет длинну равную нулю (string is null, that is, has zero length)
# -n Строка не пустая (string is not null)

# -e    Проверить существует ли файл или директория (-f, -d)
# -f    Файл существует (!-f - не существует)
# -d    Каталог существует (!-f - не существует)
# -s    Файл существует и он не пустой
# -r    Файл существует и доступен для чтения
# -w    ... для записи
# -x    ... для выполнения
# -h    cимвольная ссылка



# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#Display Pokemon
#pokemon-colorscripts --no-title -r 1,3,6

PATH=~/.console-ninja/.bin:$PATH
source /home/hyrip/.gulp.plugin.zsh/gulp.plugin.zsh
