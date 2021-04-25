FIGNORE=".aux:.fls:.log:.toc:.pyg:.fdb_latexmk:.synctex.gz:.class:.out"
complete -f -X '*.pdf' vim
complete -f -X '*.pdf' kile
# complete -f -X '!*.pdf' zathura
complete -o bashdefault -o default -F _fzf_path_completion zathura

# OPAM configuration
. /home/marcus/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true

# Custom aliases
alias v='vim'
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
# do 'findReg 'regex-goes-here'
alias findReg='find / -regextype egrep -regex'
alias packettracer='LD_LIBRARY_PATH=/opt/packetTracer7/lib /opt/packetTracer7/bin/PacketTracer7'

# Basic calculator `bcc 4+3*4`
bcc() {
    if [ -z "$1" ] ; then
        echo "Usage:
        bcc <expression>"
    else
        echo "scale=4;$1" | bc
    fi
}

# Usage: ls | grep -P <pattern> | xcmd <some-command>
xcmd() {
    if [ -z "$2" ] ; then
        echo "Usage:
        ls | grep -P <pattern> | xcmd <command> <path>"
    else
        xargs -I '{}' $1 '{}' $2
    fi
}

# tex texmplate copy command
texplate() {
    if [ -z "$2" ]
    then
        cp -i ~/maks2/.latex/template.tex $1.tex;
    else
        cp -i ~/maks2/.latex/template.tex $2/$1.tex;
    fi
}

examplate() {
    if [ -z "$1" ] ; then
        echo "Usage:
        examplate yYYYYpPPqQQ";
    elif [[ -f "$1.tex" ]] ; then
        echo "File already exists...";
    else
        # extract the information
        year=$(echo "$1" | grep -oP "y\K\d+")
        paper=$(echo "$1" | grep -oP "p\K\d+")
        question=$(echo "$1" | grep -oP "q\K\d+")
        # add in info to template
        cat ~/maks2/.latex/templateExam.tex | perl -pe "s/YYYY/$year/g" | perl -pe "s/NNNN/$((question - 1))/g" | perl -pe "s/PPPP/$paper/g" >> "$1.tex"
    fi
}

# show image of clipboard
showclip() {
    tmpfile=$(mktemp /tmp/temp-clip.XXXXXX)
    xclip -o > "$tmpfile"
    feh --auto-zoom "$tmpfile"
    rm "$tmpfile"
}

# take an exam question on the format yXXXXpXqX (e.g. y2020p7q3)
#   and opens it in zathura temporarily
triposExam() {
    year=$(echo "$1" | grep -oP "y\K\d+")
    # add trailing zeros because that's used in the solution URL
    paper=$(printf "%02d" $(echo "$1" | grep -oP "p\K\d+"))
    question=$(printf "%02d" $(echo "$1" | grep -oP "q\K\d+"))
    if [[ -z $year || -z $paper || -z $question ]] ; then
        echo "Usage:
        triposExam yDDDDpDqD [-s]";
        return 1;
    fi

    if [[ -z $2 ]] ; then
        url="https://www.cl.cam.ac.uk/teaching/exams/pastpapers/$1.pdf"
        # check if the file exists
        if [[ `wget -S --spider $url  2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
            # make a temporary pdf file and view it
            tmpfile=$(mktemp /tmp/temp-triposexam.XXXXXX)
            wget "$url" -O $tmpfile
            zathura "$tmpfile"
            rm $tmpfile
        else
            echo "Exam question could not be found: $1"
        fi
    # if we look at the solution, just give a link since we need authentication
    elif [[ "$2" == "-s" ]] ; then
        url="https://www.cl.cam.ac.uk/teaching/exams/solutions/$year/$year-p$paper-q$question-solutions.pdf"
        echo "Please visit this site and authenticate with raven:
        $url"
        return 1;
    else
        echo "Usage:
        triposExam yDDDDpDqD [-s]";
        return 1;
    fi

}

# open up the audio controls
goBlue() {
    blueman-manager &
    pavucontrol &
    exit 1
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
        echo """\begin{figure}[H]
        \begin{center}
        \includegraphics[scale=0.4]{Figures/$2.png}
        \end{center}
        \caption{jk}
        \label{fig:$2}
        \end{figure}
        """ | xclip -selection clipboard -i
    fi
}

# add choosenim stuff to path
export PATH=/home/marcus/.nimble/bin:$PATH
