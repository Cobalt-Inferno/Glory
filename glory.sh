
_info_MSGS=(
  CLONING
  UPDATING
  INSTALLING
)

function _info() {
  case "$1" in 
    (CLONING)
      echo -e "\e[1m\e[34mNotice: Cloning repository: \"\e[0m$2\e[1m\e[34m\"\e[0m" ;;
    (INSTALLING)
      echo -e "\e[1m\e[31mNotice: Installing program: \"\e[0m$2\e[1m\e[31m\"\e[0m" ;;
    (UPDATING)
      echo -e "\e[1m\e[32mNotice: Updating package: \"\e[34m$2\e[1m\e[32m\"\e[0m" ;;
  esac
}

if [ ! -d "/tmp/repo" ]; then
  mkdir "/tmp/repo"
fi


manualinstall() {
    git clone "https://aur.archlinux.org/$1.git" "/tmp/repo/$1"
    if [ -d "/tmp/repo/$1" ]
    then
        cd "/tmp/repo/$1"
        echo "Building package: $1"
        makepkg --noconfirm -si || return 1
    else
        echo "Error cloning $1 to directory /tmp/repo/$1"
    fi
}
installdotfile() {
    mkdir "$3"
    git clone "https://github.com/$1/$2" "/tmp/repo/$1/$2"
    cd "/tmp/repo/$1/$2"
    mv * "$3"
}
makeinstall() {
    git clone "$1" "/tmp/repo/$(snip $1)"
    cd "/tmp/repo/$(snip $1)"
    sudo make clean install
}

ninja() {
  _info CLONING "$1"
  git clone "$1" "/tmp/repo/$(snip $1)"
  cd "/tmp/repo/$(snip $1)"
  git submodule update --init --recursive
  meson --buildtype=release . build
  ninja -C build
  sudo ninja -C build install
}

snip() {
  echo "$1" | rev | cut -d "/" -f1 | rev
}


# Update system and repos
cc=$(sed -e 's/^"//' -e 's/"$//' <<<$(curl -s ipinfo.io/ | jq ".country"))
reflector --country "$cc" > "/tmp/repo/mirrorlist"
sudo cp "/tmp/repo/mirrorlist" "/etc/pacman.d/mirrorlist"

neededpkgs=(
    jq
    reflector
)

sudo pacman -Syu
for i in "${neededpkgs[@]}"
do
    sudo pacman -S "$i" --noconfirm
done


makeinstall https://github.com/kavulox/dwm
makeinstall https://github.com/kavulox/dwmblocks

installdotfile kavulox picom ~/.config/picom

#
ninja "https://github.com/kavulox/picom-fork"



read -r -n 1 -p $'\nThe full installation of software is complete, and we would like to offer the chance to install some extra homebrewed tools :) YES (y) DONE (d) ~> ' _cont
if [ "$_cont" = "y" ]; then
  echo $'\n'
  mkdir ~/.zsh
  read -r -n 1 -p $'\nInstall ArtixLabs deer zsh package manager? YES (y) NO (n) ~> ' _container
  if [ "$_container" = "y" ]; then
    echo $'\n'
    git clone https://github.com/ArtixLabs/deer "/tmp/repo/deer"
    cp "/tmp/repo/deer/deer.zsh" ~/.zsh
    echo "source ~/.zsh/deer.zsh" >> ~/.zshrc
  fi
  read -r -n 1 -p $'\nInstall kavulox kavpass? YES (y) NO (n) ~> ' _container
  if [ "$_container" = "y" ]; then
    echo $'\n'
    git clone https://github.com/kavulox/kavpass "/tmp/repo/kavpass"
    cd "/tmp/repo/kavpass" || return
    make
    sudo make install
  fi
  read -r -n 1 -p $'\nInstall kavulox neovim configuration? YES (y) NO (n) ~> ' _container
  if [ "$_container" = "y" ]; then
    echo $'\n'
    git clone https://github.com/ArtixLabs/deer "$HOME/.config/nvim"
  fi
  read -r -n 1 -p $'\nInstall ArtixLabs deer zsh package manager? YES (y) NO (n) ~> ' _container
  if [ "$_container" = "y" ]; then
    echo $'\n'
    git clone https://github.com/ArtixLabs/deer "/tmp/repo/deer"
    cp "/tmp/repo/deer/deer.zsh" ~/.zsh
    echo "source ~/.zsh/deer.zsh" >> ~/.zshrc
  fi
fi

