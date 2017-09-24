#!/usr/bin/env bash
GROUPNAME=$1

if [[ -z $GROUPNAME ]]; then
    echo "Please, pass inventory filename (without .hosts extension) as a first parameter"
    FILES=`ls inventory`
    echo "Filenames available:"
    for file in $FILES; do
        echo "${file//.hosts/}"
    done
    echo
    exit 1
fi

ansible-playbook -i inventory/${GROUPNAME}.hosts -b -k --ask-vault-pass --extra-vars "groupname=${GROUPNAME}" -v monitoring.yml
