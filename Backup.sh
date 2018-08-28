#!/usr/bin/env bash

echo "▀█████████▄     ▄████████  ▄████████    ▄█   ▄█▄ ███    █▄     ▄███████▄ ";
echo "  ███    ███   ███    ███ ███    ███   ███ ▄███▀ ███    ███   ███    ███ ";
echo "  ███    ███   ███    ███ ███    █▀    ███▐██▀   ███    ███   ███    ███ ";
echo " ▄███▄▄▄██▀    ███    ███ ███         ▄█████▀    ███    ███   ███    ███ ";
echo "▀▀███▀▀▀██▄  ▀███████████ ███        ▀▀█████▄    ███    ███ ▀█████████▀  ";
echo "  ███    ██▄   ███    ███ ███    █▄    ███▐██▄   ███    ███   ███        ";
echo "  ███    ███   ███    ███ ███    ███   ███ ▀███▄ ███    ███   ███        ";
echo "▄█████████▀    ███    █▀  ████████▀    ███   ▀█▀ ████████▀   ▄████▀      ";
echo "                                       ▀                                 ";
echo "   ▄▄▄▄███▄▄▄▄      ▄████████    ▄█   ▄█▄    ▄████████    ▄████████      ";
echo " ▄██▀▀▀███▀▀▀██▄   ███    ███   ███ ▄███▀   ███    ███   ███    ███      ";
echo " ███   ███   ███   ███    ███   ███▐██▀     ███    █▀    ███    ███      ";
echo " ███   ███   ███   ███    ███  ▄█████▀     ▄███▄▄▄      ▄███▄▄▄▄██▀      ";
echo " ███   ███   ███ ▀███████████ ▀▀█████▄    ▀▀███▀▀▀     ▀▀███▀▀▀▀▀        ";
echo " ███   ███   ███   ███    ███   ███▐██▄     ███    █▄  ▀███████████      ";
echo " ███   ███   ███   ███    ███   ███ ▀███▄   ███    ███   ███    ███      ";
echo "  ▀█   ███   █▀    ███    █▀    ███   ▀█▀   ██████████   ███    ███      ";
echo "                                ▀                        ███    ███      ";
echo "   	      ~  Memorias de un informatico  ~       ";
echo "       		     MY UNIX WET DREAM            ";



echo "Creating Backup Files..."
# Copy i3 config to folder
sudo cp -r ~/.config/i3/ $PWD 	

# Copy .bashrc to folder
sudo cp ~/.bashrc $PWD/bashrc

# Copy scripts folder
sudo cp -r ~/scripts $PWD

# Copy ascii fonts
sudo cp -r /usr/share/figlet $PWD

# Copy emacs folder
#sudo cp -r ~/.emacs.d $PWD
#sudo rm -rf emacs
#sudo mv -f .emacs.d/ emacs

# Copy firefox
sudo cp -r ~/.mozilla/firefox/pnclkesu.default/chrome/ firefox/

# Copy rofi
sudo cp -r /usr/share/rofi/themes rofi-themes/

# htop
sudo cp ~/.config/htop/htoprc htop/

printf "\nBackup Done\n"
read -p "want to upload to github? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

cd ~/desktop/Dotfiles-WIP/
git init
git add .
git commit -m "$1"
git push

echo "Done";
