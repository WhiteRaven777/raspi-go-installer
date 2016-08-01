#!/bin/bash -e

: "check commands" && {
  if ! type awk >/dev/null 2>&1 ; then
    echo "\"awk\" command is required."
    exit 1
  fi
  if ! type curl >/dev/null 2>&1 ; then
    echo "\"curl\" command is required."
    exit 1
  fi
  if ! type grep >/dev/null 2>&1 ; then
    echo "\"grep\" command is required."
    exit 1
  fi
  if ! type gzip >/dev/null 2>&1 ; then
    echo "\"gzip\" command is required."
    exit 1
  fi
  if ! type head >/dev/null 2>&1 ; then
    echo "\"head\" command is required."
    exit 1
  fi
  if ! type mkdir >/dev/null 2>&1 ; then
    echo "\"mkdir\" command is required."
    exit 1
  fi
  if ! type rm >/dev/null 2>&1 ; then
    echo "\"mkdir\" command is required."
    exit 1
  fi
  if ! type rm >/dev/null 2>&1 ; then
    echo "\"sed\" command is required."
    exit 1
  fi
  if ! type sort >/dev/null 2>&1 ; then
    echo "\"sort\" command is required."
    exit 1
  fi
  if ! type shasum >/dev/null 2>&1 ; then
    echo "\"shasum\" command is required."
    exit 1
  fi
  if ! type tar >/dev/null 2>&1 ; then
    echo "\"tar\" command is required."
    exit 1
  fi
  if ! type tr >/dev/null 2>&1 ; then
    echo "\"tr\" command is required."
    exit 1
  fi
  if ! type wget >/dev/null 2>&1 ; then
    echo "\"wget\" command is required."
    exit 1
  fi
  if ! type xmllint >/dev/null 2>&1 ; then
    echo "\"xmllint\" command is required."
    exit 1
  fi
}

cd ${HOME}

: "file download" && {
  _xml=`curl -sL "https://storage.googleapis.com/golang/" | xmllint --format - | tr -d " " | grep -E 'Key|LastModified'`
  _gopkg=$(echo ${_xml} | tr -d "/" | sed -e 's/<LastModified> <Key>/\n/g' | sed -e 's/<Key> <LastModified>/ /g' | sed -e 's/<Key>//g' | sed -e 's/<LastModified>//g' | awk '{print $2, $1}' | grep -e 'go\([0-9\.]\+\)linux-armv6l.tar.gz$' | sort -r | head -n 1 | awk '{print $2}')
  _hash=`curl -sL https://storage.googleapis.com/golang/${_gopkg}.sha256`
  if [ -e "${_gopkg}" ] ; then
    rm ${_gopkg}
  fi
  wget -q "https://storage.googleapis.com/golang/${_gopkg}"
}

: "check sum" && {
  _file_hash=`shasum -a 256 ${_gopkg} | awk '{print $1}'`
  if [ "${_file_hash}" != "${_hash}" ] ; then
    echo "SHA256 value is a mismatch."
    exit 1
  fi
}

: "unzip" && {
  if [ -e go ] ; then
    rm -rf go
  fi
  mkdir go && gzip -dc ${_gopkg} | tar xvf - -C go --strip-components 1
  rm ${_gopkg}
  sudo chmod 777 -R ${HOME}/go/pkg
}

: "setup" && {
  if [ -e "${HOME}/.bashrc" ] ; then
    if [[ -z "${GOROOT}" ]] ; then
      if [[ `cat ${HOME}/.bashrc | grep GOROOT` ]] ; then
        _line=`cat ${HOME}/.bashrc | grep GOROOT`
        sed -i -e "s|${_line}|GOROOT=${HOME}/go|g" ${HOME}/.bashrc
      else
        echo GOROOT=${HOME}/go >> ${HOME}/.bashrc
      fi
    fi
    if [[ -z "${GOPATH}" ]] ; then
      if [[ `cat ${HOME}/.bashrc | grep GOPATH` ]] ; then
        _line=`cat ${HOME}/.bashrc | grep GOPATH`
        sed -i -e "s|${_line}|GOPATH=${HOME}/go/lib|g" ${HOME}/.bashrc
      else
        echo GOPATH=${HOME}/go/lib >> ${HOME}/.bashrc
      fi
    fi
    if [ ! `echo ${PATH} | grep $(pwd)/go/bin` ] ; then
      if [[ `cat ${HOME}/.bashrc | grep -e ^PATH` ]] ; then
        sed -i -e "s|${PATH}|${PATH}:${HOME}/go/bin|g" ${HOME}/.bashrc
      else
        echo PATH=${PATH}:${HOME}/go/bin >> ${HOME}/.bashrc
      fi
    fi
    source "${HOME}/.bashrc"
    exec ${SHELL} --login
  fi
}