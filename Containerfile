FROM ghcr.io/ublue-os/arch-distrobox AS bazzite-arch

COPY system_files /

# Install needed packages
RUN pacman -Syyu && \
    pacman -S \
        lib32-vulkan-radeon \
        libva-mesa-driver \
        intel-media-driver \
        vulkan-mesa-layers \
        lib32-vulkan-mesa-layers \
        lib32-libnm \
        openal \
        pipewire \
        pipewire-pulse \
        pipewire-alsa \
        pipewire-jack \
        wireplumber \
        lib32-pipewire \
        lib32-pipewire-jack \
        lib32-libpulse \
        lib32-openal \
        xdg-desktop-portal-kde \
        vim \
        nano \
        hyfetch \
        fish \
        yad \
        xdg-user-dirs \
        xdotool \
        xorg-xwininfo \
        wmctrl \
        wxwidgets-gtk3 \
        rocm-opencl-runtime \
        rocm-hip-runtime \
        libbsd \
        noto-fonts-cjk \
        glibc-locales \
        --noconfirm && \
    pacman -S \
        gamescope \
        steam \
        lutris \
        mangohud \
        lib32-mangohud \
        papirus-icon-theme \
        --noconfirm \
        # Steam/Lutris/Wine installed separately so they use the dependencies above and don't try to install their own.

# Create build user
RUN useradd -m --shell=/bin/bash build && usermod -L build && usermod -aG sudo build \

# Install AUR packages
USER build
WORKDIR /home/build
RUN paru -S \
        aur/protontricks \
        aur/vkbasalt \
        aur/lib32-vkbasalt \
        aur/obs-vkcapture-git \
        aur/lib32-obs-vkcapture-git \
        aur/lib32-gperftools \
        aur/steamcmd \
        aur/latencyflex-bin \
        aur/latencyflex-proton-ge-custom \
        --noconfirm
USER root
WORKDIR /

FROM bazzite-arch as bazzite-arch-gnome

# Replace KDE portal with GNOME portal, swap included icon theme.
RUN sed -i 's/-march=native -mtune=native/-march=x86-64 -mtune=generic/g' /etc/makepkg.conf && \
    pacman -Rnsdd \
        xdg-desktop-portal-kde \
        --noconfirm && \
    pacman -S \
        xdg-desktop-portal-gtk \
        xdg-desktop-portal-gnome \
        --noconfirm

# Cleanup
RUN sed -i 's/-march=x86-64 -mtune=generic/-march=native -mtune=native/g' /etc/makepkg.conf && \
    rm -rf \
        /tmp/* \
        /var/cache/pacman/pkg/*
