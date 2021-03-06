#!/bin/bash

# Copyright 2013 Kyle Harper
# Licensed per the details in the LICENSE file in this package.

# Source shared, core, and namespace.
. "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../__shared.inc.sh"
. "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../../sbt/core.sh"
. "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../../sbt/array.sh"


# Performance check
if [ "${1}" == 'performance' ] ; then iteration=1 ; START="$(date '+%s%N')" ; else echo '' ; fi


# Testing loop
while [ ${iteration} -le ${MAX_ITERATIONS} ] ; do
  # -- 1 -- Remove keys specified in positionals, simple.
  unset -v 'myArray'
  unset -v 'myAssoc'
  declare -a myArray=('zero' 'one' 'two has spaces' 'three' 'four' 'five space' 'six' 'seven')
  declare -A myAssoc=(['one']='orange' ['two']='apple seeds' ['three']='grapes' ['fourth element']='ok now' ['five']='hooray')
  new_test "Trying to remove keys from a normal array by specifying them manually: "
  array__remove -a 'myArray' 0 1 4 5                      || fail 1
  [ "${!myArray[*]}" = '2 3 6 7' ]                        || fail 2
  [ ${#myArray[@]} -eq 4 ]                                || fail 3
  [ "${myArray[*]}" = 'two has spaces three six seven' ]  || fail 4
  pass

  # -- 2 -- Remove keys specified in positionals with a hash, simple.
  unset -v 'myArray'
  unset -v 'myAssoc'
  declare -a myArray=('zero' 'one' 'two has spaces' 'three' 'four' 'five space' 'six' 'seven')
  declare -A myAssoc=(['one']='orange' ['two']='apple seeds' ['three']='grapes' ['fourth element']='ok now' ['five']='hooray')
  new_test "Trying to remove keys from an associative array by specifying them manually: "
  array__remove -a 'myAssoc' 'one' 'two' 'fourth element'   || fail 1
  for token in "${!myAssoc[@]}" ; do
    [ "${token}" == 'three' ] && continue
    [ "${token}" = 'five' ] && continue
    fail 2
  done
  [ ${#myAssoc[@]} -eq 2 ]                                  || fail 3
  for token in "${myAssoc[@]}" ; do
    [ "${token}" = 'grapes' ] && continue
    [ "${token}" = 'hooray' ] && continue
    fail 4
  done
  pass

  # -- 3 -- Leaving keys with spaces should still work since they're allowed by bash.
  unset -v 'myArray'
  unset -v 'myAssoc'
  declare -a myArray=('zero' 'one' 'two has spaces' 'three' 'four' 'five space' 'six' 'seven')
  declare -A myAssoc=(['one']='orange' ['two']='apple seeds' ['three']='grapes' ['fourth element']='ok now' ['five']='hooray')
  new_test "The function should allow key names with spaces because bash allows them: "
  array__remove -a 'myAssoc' 'one' 'two' || fail 1
  for token in "${!myAssoc[@]}" ; do
    [ "${token}" == 'three' ] && continue
    [ "${token}" == 'fourth element' ] && continue
    [ "${token}" == 'five' ] && continue
    fail 2
  done
  pass

  # -- 4 -- Not sending an array name should fail.
  unset -v 'myArray'
  unset -v 'myAssoc'
  declare -a myArray=('zero' 'one' 'two has spaces' 'three' 'four' 'five space' 'six' 'seven')
  declare -A myAssoc=(['one']='orange' ['two']='apple seeds' ['three']='grapes' ['fourth element']='ok now' ['five']='hooray')
  new_test "Not sending an array with -a or --array should fail: "
  array__remove 'one' 'two' 2>/dev/null   && fail 1
  pass

  # -- 5 -- Not sending any keys, patterns, or N-th should fail.
  unset -v 'myArray'
  unset -v 'myAssoc'
  declare -a myArray=('zero' 'one' 'two has spaces' 'three' 'four' 'five space' 'six' 'seven')
  declare -A myAssoc=(['one']='orange' ['two']='apple seeds' ['three']='grapes' ['fourth element']='ok now' ['five']='hooray')
  new_test "Failure to specify any keys, pattern, or N-th should fail: "
  array__remove -a 'myArray' 2>/dev/null   && fail 1
  pass

  # -- 6 -- Pattern removals
  unset -v 'myArray'
  unset -v 'myAssoc'
  declare -a myArray=('zero' 'one' 'two has spaces' 'three' 'four' 'five space' 'six' 'seven')
  declare -A myAssoc=(['one']='orange' ['two']='apple seeds' ['three']='grapes' ['fourth element']='ok now' ['five']='hooray')
  new_test "Removing keys in a normal array with a pattern: "
  array__remove -a 'myArray' -p '[1-6]'                  || fail 1
  for token in "${!myArray[@]}" ; do
    [ "${token}" = '0' ] || [ "${token}" = '7' ]         || fail 2
  done
  [ ${#myArray[@]} -eq 2 ]                               || fail 3
  for token in "${myArray[@]}" ; do
    [ "${token}" = 'zero' ] || [ "${token}" = 'seven' ]  || fail 4
  done
  pass

  # -- 7 -- Pattern removal with an associative array
  unset -v 'myArray'
  unset -v 'myAssoc'
  declare -a myArray=('zero' 'one' 'two has spaces' 'three' 'four' 'five space' 'six' 'seven')
  declare -A myAssoc=(['one']='orange' ['two']='apple seeds' ['three']='grapes' ['fourth element']='ok now' ['five']='hooray')
  new_test "Removing keys in an associative array with a pattern: "
  array__remove -a 'myAssoc' -p '\b[a-z]{3}\b'                                                 || fail 1
  for token in "${!myAssoc[@]}" ; do
    [ "${token}" = 'three' ] || [ "${token}" = 'fourth element' ] || [ "${token}" = 'five' ]   || fail 2
  done
  [ ${#myAssoc[@]} -eq 3 ]                                                                     || fail 3
  for token in "${myAssoc[@]}" ; do
    [ "${token}" = 'grapes' ] || [ "${token}" = 'ok now' ] || [ "${token}" = 'hooray' ]        || fail 4
  done
  pass

  # -- 8 -- N-th Removals
  unset -v 'myArray'
  unset -v 'myAssoc'
  declare -a myArray=('zero' 'one' 'two has spaces' 'three' 'four' 'five space' 'six' 'seven')
  declare -A myAssoc=(['one']='orange' ['two']='apple seeds' ['three']='grapes' ['fourth element']='ok now' ['five']='hooray')
  new_test "Removing every N-th element (in this case, 2nd): "
  array__remove -a 'myArray' -n '2'                                                                                     || fail 1
  for token in "${!myArray[@]}" ; do
    [ "${token}" = '0' ] || [ "${token}" = '2' ] || [ "${token}" = '4' ] || [ "${token}" = '6' ]                        || fail 2
  done
  [ ${#myArray[@]} -eq 4 ]                                                                                              || fail 3
  for token in "${myArray[@]}" ; do
    [ "${token}" = 'zero' ] || [ "${token}" = 'two has spaces' ] || [ "${token}" = 'four' ] || [ "${token}" = 'six' ]   || fail 4
  done
  pass

  # -- 9 -- N-th Removals for an associative array
  unset -v 'myArray'
  unset -v 'myAssoc'
  declare -a myArray=('zero' 'one' 'two has spaces' 'three' 'four' 'five space' 'six' 'seven')
  declare -A myAssoc=(['one']='orange' ['two']='apple seeds' ['three']='grapes' ['fourth element']='ok now' ['five']='hooray')
  new_test "Removing every N-th element of an associative array, which is dumb cuz they're un-ordered (in this case, 2nd): "
  array__remove -a 'myAssoc' -n '2'  || fail 1
  [ ${#myAssoc[@]} -eq 3 ]           || fail 2
  pass

  # -- 10 -- Order of or removal should work
  unset -v 'myArray'
  unset -v 'myAssoc'
  declare -a myArray=('zero' 'one' 'two has spaces' 'three' 'four' 'five space' 'six' 'seven')
  declare -A myAssoc=(['one']='orange' ['two']='apple seeds' ['three']='grapes' ['fourth element']='ok now' ['five']='hooray')
  new_test "Sending N-th, a pattern, and keys.  They should remove in order: "
  array__remove -a 'myArray' -n '2' -p '[02]' '6'   || fail 1
  [ "${myArray[*]}" = 'four' ]                      || fail 2
  [ ${#myArray[@]} -eq 1 ]                          || fail 3
  [ "${!myArray[@]}" = '4' ]                        || fail 4
  pass

  # -- 11 -- Long options should work
  unset -v 'myArray'
  unset -v 'myAssoc'
  declare -a myArray=('zero' 'one' 'two has spaces' 'three' 'four' 'five space' 'six' 'seven')
  declare -A myAssoc=(['one']='orange' ['two']='apple seeds' ['three']='grapes' ['fourth element']='ok now' ['five']='hooray')
  new_test "Long options should work: "
  array__remove --array 'myArray' --nth '2' --pattern '[02]' '6'   || fail 1
  [ "${myArray[*]}" = 'four' ]                                     || fail 2
  [ ${#myArray[@]} -eq 1 ]                                         || fail 3
  [ "${!myArray[@]}" = '4' ]                                       || fail 4
  pass


  let iteration++
done


# Send final data
if [ "${1}" == 'performance' ] ; then
  END="$(date '+%s%N')"
  let "TOTAL = (${END} - ${START}) / 1000000"
  printf "  %'.0f tests in %'.0f ms (%s tests/sec)\n" "${test_number}" "${TOTAL}" "$(bc <<< "scale = 3; ${test_number} / (${TOTAL} / 1000)")" >&2
fi

