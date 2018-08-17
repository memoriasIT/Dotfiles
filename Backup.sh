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

i=1
cond=true
sp="/-\|"
echo -n ' '
while $cond
do
	# Copy i3 config to folder
	sudo cp ~/.config/i3/ $PWD/i3 	

	
	printf "\b${sp:i++%${#sp}:1}"
	cond=false
done

printf "\nBackup Done\n"
read -p "want to upload to github? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

cd ~/desktop/Dotfiles-WIP/
git init
git add .
git commit -m "New files papito"
git push

echo "Done";
