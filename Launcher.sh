#!/bin/bash

install_location=/home/$(whoami)/.local/share/OG_Launcher/jak-project
temp1=0
distro=unkown

opengoal_Upate() {
	cd $install_folder
	git pull https://github.com/open-goal/jak-project
	distrocheck
	if [ $distro = redhat ]
		then
			cmake -DCMAKE_SHARED_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -B build
			cmake --build build -j$(nproc)
		else
			cmake -B build && cmake --build build -j 8
	fi
}


jak1_update() {
	cd $install_location
	file=iso_data/jak1/SYSTEM.CNF
	if [ ! -f $file ] ; then
        kdialog --error "Game not found, Lets find the iso and then proceed"
        jak1iso=$(zenity --file-selection)
        ./build/decompiler/extractor -e $(echo $jak1iso)
    fi
        cd $install_location
        ./build/decompiler/extractor --decompile -f iso_data/jak1
        ./build/decompiler/extractor --compile decompiler_out/jak1
        kdialog --msgbox "jak 1 successfuly updated"
		}


jak2_update() {
	cd $install_location
    file=iso_data/jak2/SYSTEM.CNF
		if ( ! -f $file ) ; then
            kdialog --error "Game not found, Lets find the iso and then proceed"
            iso=$(zenity --file-selection)
            cd build/decompiler
            ./extractor -e $(echo $iso)
        fi
    cd $install_location
	./build/decompiler/extractor --game jak2 --decompile -f iso_data/jak2
	./build/decompiler/extractor --game jak2 --compile decompiler_out/jak2
	kdialog --msgbox "jak 2 successfuly updated"
		}

jak3_update() {
	cd $install_location
    file=iso_data/jak3/SYSTEM.CNF
        if ( ! -f $file ) ; then
            kdialog --error "Game not found, Lets find the iso and then proceed"
            iso=$(zenity --file-selection)
            cd build/decompiler
            ./extractor -e $(echo $iso)
        fi
    cd $install_location
	./build/decompiler/extractor --game jak3 --decompile -f iso_data/jak3
	./build/decompiler/extractor --game jak3 --compile decompiler_out/jak3
	kdialog --msgbox "jak3 successfuly updated"
		}

dependency_check() {
    if [ ! which dialog ] && [ ! which kdialog ] && [ ! which zenity ]
    then
    temp1=1
    else
        echo "\n\n\ndependencies are not met. Please refer to blank to get obtain them. In the future this script will do it for you, exiting script"
        exit 1
    fi
}

distrocheck() {
if [ "command -v dnf" != "" ]; then
    distro=fedora

    elif [ "command -v apt" != "" ]; then
        distro=debian

elif [ "command -v pacman" != "" ];then
        distro=arch
else
    echo "\n\nWe couldn't determine your package manager.\n\nPlease install your own depencies"
fi
}


git_run() {
	cd $install_location
	##distrocheck
	git clone https://github.com/open-goal/jak-project
	cd jak-project/
	##if [ $distro = redhat ]
		##then
			cmake -DCMAKE_SHARED_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -B build
			cmake --build build -j$(nproc)
    ##else
			##cmake -B build && cmake --build build -j 8
		##fi
}

jak3_noextractor(){
                        cd $install_location
						task set-game-jak3
						task extract
						cd build/goalc
                        ./goalc --game jak3 --cmd "(mi)"
			kdialog --msgbox "Jak3 installed"
			cd $install_location

}
update_menu() {
update_menutemp=1
update_menu_answer=1
while [ 1 ]
    do
        kdialog --menu "Update Menu" "1" "Install or Update Jak 1" "2" "Install or Update Jak 2" "3" "Install or Update Jak 3" "4" "Update Open Goal and all games" "0" "Back to main menu" > $update_menu_answer
        selection=$(cat $update_menu_answer)
        case $selection in
            1)
            jak1_update
            ;;
            2)
            jak2_update
            ;;
            3)
           # jak3_update
           kdialog --msgbox "please manually move an extracted iso, (needs to a folder) of jak3 to /home/$(whoami)/.local/share/OG_Launcher/iso_data\nAfter that has been done, please clock ok. IF its been done beofre, just click ok"
           jak3_noextractor
            ;;
            4)
           # opengoal_Update
            cd $install_location
            kdialog --msgbox "this will take some time, click ok to continue"
            git pull https://github.com/open-goal/jak-project
            cmake -DCMAKE_SHARED_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -B build
			cmake --build build -j$(nproc)
			kdialog --msgbox "time for jak 1 Click ok to continue"
			jak1_update
			kdialog --msgbox "time for jak2, Click ok to continue"
			jak2_update
            ;;
            0)
                temp1=1
                break
            ;;
            *)
            kdialog --error "Invalid Selection"
        esac
    done
}

Depency_install() {
distrocheck
case $distro in
	arch)
		pacman -S --noconfirm cmake libpulse base-devel nasm python libx11 libxrandr libxinerama libxcursor libxi zenity kdialog dialog;;
	debian)
		apt install -y gcc make cmake build-essential g++ nasm clang-format libxrandr-dev libxinerama-dev libxcursor-dev libpulse-dev libxi-dev python lld clang zenity dialog kdialog;;
	redhat)
	sudo dnf -y install cmake python lld clang nasm libX11-devel libXrandr-devel libXinerama-devel libXcursor-devel libXi-devel pulseaudio-libs-devel mesa-libGL-devel zenity dialog kdialog -y;;
	*) :
esac
}

############################### Main Program, What the users sees ########################
game=/home/$(whoami)/.local/OG_Launcher/jak-project/crowdin.yml
## start up program commands
if [ ! -f $game ] ; then
    # dependency_check
mkdir /home/$(whoami)/.local/share/OG_Launcher/
    cd /home/$(whoami)/.local/share/OG_Launcher
    cd $install_location
    #echo "This may take some time, the script will seek to install all dependies"
    #Depency_install
    git_run

    else
    normalrun=1
fi
#else
temp1=1
temp2=1
temp_menu=1
main_loop=1
temp_main=1

while [ $main_loop -eq 1 ]
do
    if [ $temp_menu -eq 1 ]
    then
    while [ $temp1 -eq 1 ] ; do             ####### main menu
        kdialog --menu "Open Goal Launcher" "1" "Play Jak 1" "2" "Play Jak 2" "3" "Play Jak 3" "4" "Update" "5" "About this program" "0" "Exit" > $temp_main
        selection=$(cat $temp_main)

        case $selection in
        1)
            cd $install_location
            ./build/game/gk --game jak1 -boot -fakeiso
            ;;
        2)
            cd $install_location
            ./build/game/gk --game jak2 -boot -fakeiso
        ;;
        3)
            cd $install_location
            ./build/game/gk --game jak3 -boot -fakeiso
            #task set-game-jak3
        ;;
        4)
            update_menu
        ;;
        5)
            kdialog --title "About Launcher" --msgbox "This program was written by Richterman using bash and written for Linux based computers. \nFor more informaion, please check my github page https://github.com/Richterman/OG_Launcher. \nSoftware was written under <insert license>"
        ;;
        0)
            main_loop=2
            exit 0
        ;;
        *)
            kdialog --error "Invalid selection"
        esac
    done
    elif [ $main_loop -eq 2 ] ; then
    break
    fi
done
#### end of program

#fi


