# W.A.S.P - Web App Starter Pack

- Deprecated.

This repo is the home for a set of comfy scripts, tools and whatever that would aid in smooth dev life.

- :dog: `sh.sh` - **Setup Hound** is a small bash script that installs a few utilities on to a freshly installed Ubuntu system to set it up for dev work. [ :bomb: `HIGHLY BETA`]
- :fire: `ni.sh` - **Nativescript Installer** installs nativescript for Android development on Ubuntu.
- :fire: `pinit.sh` - **Project Initializer** sets up a project folder with needed configs.
- :anger: `iiu.sh` - **Is It Up** checks if a list of sites are up or not. Invoke as `$ ./iiu.sh file.list`

# Installation

- Create `$HOME/bin`
- Copy the scripts there or symlink them. example: `ln -s $HOME/Downloads/wasp/ni.sh $HOME/bin/ni.sh`
- Make them executable `chmod +x *.sh`
- Open your shell's rc file. For bash that would be `$HOME/.bashrc` and add these lines to the end

```
export PATH="$PATH:$HOME/bin"
```

