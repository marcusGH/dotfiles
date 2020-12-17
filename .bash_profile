FIGNORE=".aux:.fls:.log:.toc:.pyg:.fdb_latexmk:.synctex.gz:.zip:.class:.out"
complete -f -X '*.pdf' vim
complete -f -X '*.pdf' kile
complete -f -X '!*.pdf' zathura

# OPAM configuration
. /home/marcus/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true

# Custom aliases
alias ts='resize -s 24 80'
alias tm='resize -s 36 120'
alias tl='resize -s 48 160' 
alias jn='jupyter-notebook'
alias please='sudo'
alias copy='xclip -sel clip'
alias dupe='gnome-terminal .'
alias backlight="sudo ~/.config/custom-scripts/set-backlight-brightness.sh"
alias xclip="xclip -selection clipboard"
# do `ls | grep -P "some-pattern" | xargsmv /path/
alias xargsmv="xargs -I '{}' mv '{}'"
# do 'findReg 'regex-goes-here'
alias findReg='find / -regextype egrep -regex'

# tex texmplate copy command
texplate() {
    if [ -z "$2" ]
    then
        cp -i ~/maks2/.latex/template.tex $1.tex;
    else
        cp -i ~/maks2/.latex/template.tex $2/$1.tex;
    fi
}

# show image of clipboard
showclip() {
    tmpfile=$(mktemp /tmp/temp-clip.XXXXXX)
    xclip -o > "$tmpfile"
    feh --auto-zoom "$tmpfile"
    rm "$tmpfile"
}

# take a screenshot of selection and put latex code to display it in clipboard
#   the picture is saved in a Figure folder in the current working directory
latexScreen() {
    if [ -z "$2" ] ; then
        echo "A path name and image name must be specified!"
    else
        # get the location to store the image in
        LOC="$1/Figures"
        # verify that the folder exists, othw. make one
        if [ -d $LOC ] ; then
            echo "Found a Figures folder, so it will be used."
        else
            echo "Creating a Figures folder: $(realpath $LOC)"
            mkdir "$LOC"
        fi
        # take a screenshot an move it to the figures folder
        gnome-screenshot -f "$LOC/$2.png" -a
        # put the relevant text into the clipboard
        echo """
        \begin{figure}[H]
        \begin{center}
        \includegraphics[scale=0.6]{Figures/$2.png}
        \end{center}
        \caption{jk}
        \label{fig:$2}
        \end{figure}
        """ | xclip -selection clipboard -i
    fi
}

# add choosenim stuff to path
export PATH=/home/marcus/.nimble/bin:$PATH
