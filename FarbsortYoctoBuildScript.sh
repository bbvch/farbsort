#!/bin/bash

welcome="Welcome to the farbsort yocto auto builder script"
title="Select which yocto branch do you like to build"

PROJECT_DIR="$HOME/yocto"
DOWNLOAD_DIR= "${PROJECT_DIR}/downloads"
IMAGE=farbsort-image

while getopts ":b:d:u:r" optname
  do
	case "$optname" in
	  "b")    
	        PROJECT_DIR="$OPTARG"
		echo "Setting Yocto base directory to $PROJECT_DIR ..." 
	  	;;
	  "d")   
		_DOWNLOAD_DIR="$OPTARG"
		echo "Setting Yocto download directory to $PROJECT_DIR ..." 
	  	;;
	   *) 
	    echo "Bad or missing argument!" 
	    echo "Usage: $0 -b dir -d dir "
            echo "	-b dir : Yocto base directory."
	    echo "	-d dir : Yocto download directory."
	   exit 0
	    ;;
	esac
done


options=("morty" "pyro" "rocko" )
echo "********************************************************"
echo "*" "$welcome" "*"
echo "*" "$title" "      *"
echo "********************************************************"

select opt in "${options[@]}" "Quit"; do 

    case "$REPLY" in

    1 ) echo "You choosed to build the $opt branch"; break ;;
    2 ) echo "You choosed to build the $opt branch"; break ;;
    3 ) echo "You choosed to build the $opt branch"; break ;;
    $(( ${#options[@]}+1 )) ) echo "Goodbye!"; exit 0;;
    *) echo "Invalid option. Try another one.";continue;;

    esac

done

POKY_BRANCH=$opt

# make sure we have all the necessary packages installed and the default shell is bash and not dash
# TODO: how to do this without user confirmation?
#       simply make a symlink /bin/sh -> /bin/bash ?
#sudo dpkg-reconfigure dash
echo "-------------------------------------------------------------------------"
echo 	"Step 1: Install missing host packages"
echo "-------------------------------------------------------------------------"
sudo apt-get -y install gawk wget git-core diffstat unzip texinfo gcc-multilib \
     build-essential chrpath socat libsdl1.2-dev xterm curl texinfo lzop


echo "-------------------------------------------------------------------------"
echo 	"Step 2: creating yocto directories"
echo "-------------------------------------------------------------------------"

# download the discovered version of yocto
echo "mkdir -p ${PROJECT_DIR}"
$RUN mkdir -p ${PROJECT_DIR}

# We need absolute paths not relative

PROJECT_DIR="$(readlink -e $PROJECT_DIR)"
BUILD_DIR="${PROJECT_DIR}/mybuilds/${IMAGE}-${POKY_BRANCH}"

if ( [ "${_DOWNLOAD_DIR}" == "" ] ); then
	DOWNLOAD_DIR="${PROJECT_DIR}/downloads"
else
	if [ "$_DOWNLOAD_DIR" != "" ]; then
		DOWNLOAD_DIR=readlink -e "$_DOWNLOAD_DIR"
	fi
fi

# create directory where yocto should store all the downloaded sources
if [ ! -d "$DOWNLOAD_DIR" ]; then
   echo "mkdir -p ${DOWNLOAD_DIR}"
   $RUN mkdir -p $DOWNLOAD_DIR
fi

if [ ! -d "${BUILD_DIR}" ]; then
   echo "mkdir -p ${BUILD_DIR}"
   $RUN mkdir -p ${BUILD_DIR}
fi

cd ${PROJECT_DIR}

echo "-------------------------------------------------------------------------"
echo 	"Step 3: Cloning yocto branch ${POKY_BRANCH} to poky_${POKY_BRANCH}    "
echo "-------------------------------------------------------------------------"

git clone -b ${POKY_BRANCH} git://git.yoctoproject.org/poky poky_${POKY_BRANCH}
cd poky_${POKY_BRANCH}

#echo "-----------------------------------------------------------------------------"
#echo 	"Step 4: Cloning meta-openembedded branch ${POKY_BRANCH} to poky_${POKY_BRANCH}   "
#echo "-----------------------------------------------------------------------------"
#$RUN git clone -b ${POKY_BRANCH} git://github.com/openembedded/oe-core

echo "-----------------------------------------------------------------------------"
echo 	"Step 5: Cloning meta-openembedded branch ${POKY_BRANCH} to poky_${POKY_BRANCH}   "
echo "-----------------------------------------------------------------------------"
$RUN git clone -b ${POKY_BRANCH} git://git.openembedded.org/meta-openembedded

#echo "-----------------------------------------------------------------------------"
#echo 	"Step 6: Cloning meta-oe branch ${POKY_BRANCH} to poky_${POKY_BRANCH}   "
#echo "-----------------------------------------------------------------------------"
#$RUN git clone -b ${POKY_BRANCH} git://github.com/openembedded/meta-oe/

echo "-----------------------------------------------------------------------------"
echo 	"Step 7: Cloning meta-qt5 branch ${POKY_BRANCH} to poky_${POKY_BRANCH}   "
echo "-----------------------------------------------------------------------------"
$RUN git clone -b ${POKY_BRANCH} https://github.com/meta-qt5/meta-qt5

echo "-----------------------------------------------------------------------------"
echo 	"Step 8: Cloning meta-ti branch ${POKY_BRANCH} to poky_${POKY_BRANCH}   "
echo "-----------------------------------------------------------------------------"
$RUN  git clone -b ${POKY_BRANCH} git://git.yoctoproject.org/meta-ti
# This is for the 4.9 kernel. There where some compile problems with the 14.4 kernel.

if [ "${POKY_BRANCH}" == "rocko" ]; then
    cd meta-ti
    git checkout b8c6a1426e6301df1ab17de635e26cbb9e0f9949
    cd ..
fi


echo "-----------------------------------------------------------------------------"
echo 	"Step 9: Cloning meta-farbsort branch ${POKY_BRANCH} to poky_${POKY_BRANCH}   "
echo "-----------------------------------------------------------------------------"
$RUN git clone -b ${POKY_BRANCH} https://github.com/bbvch/meta-farbsort.git

echo "-------------------------------------------------------------------------"
echo 	"Step 10: setup Yocto environment"
echo "-------------------------------------------------------------------------"
echo "source ${PROJECT_DIR}/poky_${POKY_BRANCH}/oe-init-build-env ${BUILD_DIR}/"
source ${PROJECT_DIR}/poky_${POKY_BRANCH}/oe-init-build-env ${BUILD_DIR}/


echo "-------------------------------------------------------------------------"
echo 	"Step 11: Copy the local.conf and bblayers.conf files to dir: ${BUILD_DIR}/conf"
echo "-------------------------------------------------------------------------"
$RUN mkdir -p ${BUILD_DIR}/conf/
echo "Create ${BUILD_DIR}/conf/local.conf and ${BUILD_DIR}/conf/bblayers.conf"
$RUN cat > ${BUILD_DIR}/conf/local.conf << EOL
CONF_VERSION      = "2"
BB_NUMBER_THREADS = "5"
PARALLEL_MAKE     = "-j 4"
PACKAGE_CLASSES   = "package_ipk"
SDKMACHINE        = "x86_64"
USER_CLASSES      = "buildstats image-mklibs image-prelink"
PATCHRESOLVE      = "noop"

BB_DISKMON_DIRS = "\\
    STOPTASKS,\${TMPDIR},1G,100K \\
    STOPTASKS,\${DL_DIR},1G,100K \\
    STOPTASKS,\${SSTATE_DIR},1G,100K \\
    ABORT,\${TMPDIR},100M,1K \\
    ABORT,\${DL_DIR},100M,1K \\
    ABORT,\${SSTATE_DIR},100M,1K \\
    ABORT,/tmp,10M,1K"

PACKAGECONFIG_append_pn-qemu-native = " sdl"
PACKAGECONFIG_append_pn-nativesdk-qemu = " sdl"

SOURCE_MIRROR_URL ?= "file://${DOWNLOAD_DIR}/"
INHERIT += "own-mirrors"

MACHINE = "farbsort-bbb-board"
DISTRO  = "farbsort-bbv-distro"

EOL
########################################################################################

$RUN cat > ${BUILD_DIR}/conf/bblayers.conf << EOL
# POKY_BBLAYERS_CONF_VERSION is increased each time build/conf/bblayers.conf
# changes incompatibly
POKY_BBLAYERS_CONF_VERSION = "2"

BBPATH = "\${TOPDIR}"
BBFILES ?= ""

PATH_TO_LAYERS = "${PROJECT_DIR}/poky_${POKY_BRANCH}"

BBLAYERS ?= " \\
  \${PATH_TO_LAYERS}/meta \\
  \${PATH_TO_LAYERS}/meta-poky \\
  \${PATH_TO_LAYERS}/meta-openembedded/meta-oe \\
  \${PATH_TO_LAYERS}/meta-openembedded/meta-python \\
  \${PATH_TO_LAYERS}/meta-openembedded/meta-networking \\
  \${PATH_TO_LAYERS}/meta-ti \\
  \${PATH_TO_LAYERS}/meta-qt5 \\
  \${PATH_TO_LAYERS}/meta-farbsort \\
  "

EOL


echo "-------------------------------------------------------------------------"
echo 	"Step 12: Start Yocto image build"
echo "-------------------------------------------------------------------------"
$RUN bitbake ${IMAGE}


