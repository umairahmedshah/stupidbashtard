#!/bin/bash

# Copyright 2013 Kyle Harper
# Licensed per the details in the LICENSE file in this package.

# Run each test.  Pass flag to do a performance test.
[ -z "${*}" ] && echo "You must specify a namespace to test." >&2 && exit 1
for ns in "$@" ; do
  if [ ! -d sbt/${ns} ] ; then echo "Namespace specified doesn't exist: '${ns}'" >&2 ; exit 1 ; fi
  echo
  echo "Namespace '${ns}'"
  for file in sbt/${ns}/* ; do
    echo -n "--> $(basename ${file})"
    ./${file} 'performance' >/dev/null
  done
done
