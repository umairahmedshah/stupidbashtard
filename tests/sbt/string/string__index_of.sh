#!/bin/bash

# Copyright 2013 Kyle Harper
# Licensed per the details in the LICENSE file in this package.

# Source shared, core, and namespace.
. "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../__shared.inc.sh"
. "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../../sbt/core.sh"
. "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../../sbt/string.sh"


# Performance check
if [ "${1}" == 'performance' ] ; then iteration=1 ; START="$(date '+%s%N')" ; else echo '' ; fi


# Testing loop
while [ ${iteration} -le ${MAX_ITERATIONS} ] ; do
  # -- 1 -- Pass all arguments as expected
  new_test "Sending all arguments as required, to simulate a good test: "
  [ $(string__index_of -n 'apple' 'I ate an apple yesterday.') -eq 9 ] || fail 1
  pass

  # -- 2 -- A -1 index doesn't mean a failed function.
  new_test "Making sure not-found items will result in -1, but NOT return code non-zero: "
  [ $(string__index_of -n 'orange' 'I ate an apple yesterday.') -eq -1 ] || fail 1
  string__index_of -n 'orange' 'I ate an apple yesterday.' 1>/dev/null 2>/dev/null
  [ $? -eq 0 ] || fail 2
  pass

  # -- 3 -- Should be able to find the Nth occurrence
  new_test "Finding the Nth occurrence should work: "
  [ $(string__index_of -n 'apple' -o 2 'I ate an apple yesterday, yes an apple homie.') -eq 33 ] || fail 1
  pass

  # -- 4 -- Not sending a needle should result in an error
  new_test "Failing to send a needle on purpose, should result in error status code: "
  string__index_of 'I ate an apple yesterday.' 1>/dev/null 2>/dev/null
  [ $? -eq 0 ] && fail 1
  pass

  # -- 5 -- Sending multiple needles should result in finding match
  new_test "Sending two needles, knowing the first will fail to find.  Should still work: "
  [ $(string__index_of -n 'orange' -n 'apple' 'I ate an apple yesterday.') -eq 9 ] || fail 1
  pass

  # -- 6 -- Sending multiple haystacks will result in them being mashed together
  new_test "Sending two haystacks, expecting them to mash together: "
  [ $(string__index_of -n 'apple' 'I ate an apple yesterday.' 'I ate an orange too.') -eq 9 ]   || fail 1
  [ $(string__index_of -n 'orange' 'I ate an apple yesterday.' 'I ate an orange too.') -eq 34 ] || fail 2
  pass

  # -- 7 -- A string with a newline should work... hmm.
  new_test "Sending a newline as an element, this should work: "
  [ $(string__index_of -n 'apple' $'I ate an\n apple yesterday.') -eq 10 ] || fail 1
  pass

  # -- 8 -- Needle with spaces should be ok
  new_test "Sending a needle with spaces and/or newlines to ensure escaped correctly: "
  [ $(string__index_of -n 'apple yesterday' $'I ate an\n apple yesterday.') -eq 10 ] || fail 1
  [ $(string__index_of -n $'an\n apple' $'I ate an\n apple yesterday.') -eq 6 ]      || fail 2
  pass

  # -- 9 -- Ordering of needles and haystacks is important.
  new_test "Demonstrating that needle and haystack ordering is important: "
  [ $(string__index_of -n $'an\n apple' -n $'an\n orange' $'I ate an\n apple ' $'and an\n orange yesterday.') -eq 6 ]  || fail 1
  [ $(string__index_of -n $'an\n orange' -n $'an\n apple' $'I ate an\n apple ' $'and an\n orange yesterday.') -eq 20 ] || fail 2
  [ $(string__index_of -n $'an\n apple' -n $'an\n orange' $'and an\n orange yesterday.' $'I ate an\n apple ') -eq 31 ] || fail 3
  [ $(string__index_of -n $'an\n orange' -n $'an\n apple' $'and an\n orange yesterday.' $'I ate an\n apple ') -eq 4 ]  || fail 4
  pass

  # -- 10 -- Storing by ref should work
  new_test "Storing output in reference variable: "
  distance=''
  string__index_of -n $'an\n apple' -n $'an\n orange' $'I ate an\n apple ' $'and an\n orange yesterday.' -R 'distance'  || fail 1
  [ ${distance} -eq 6 ] || fail 2
  pass

  # -- 11 -- Long options should work too
  new_test "Using long options should work too: "
  distance=''
  string__index_of --needle $'an\n apple' --needle $'an\n orange' $'I ate an\n apple ' $'and an\n orange yesterday.' -R 'distance'  || fail 1
  [ ${distance} -eq 6 ] || fail 2
  distance=''
  string__index_of --needle $'an\n apple' $'I ate an\n apple, oh yea, an\n apple sd' --occurrence=2 -R 'distance'  || fail 3
  [ ${distance} -eq 25 ] || fail 4
  pass

  # -- 12 -- Try to find the last occurrence of a string
  new_test "Finding the last occurrence of a needle by sending -o 'last': "
  [ $(string__index_of --occurrence 'last' --needle 'Yum' $'Yum, I ate an\n apple ' $'and an\n orange yesterday. Yum Yum Yum!') -eq 55 ] || fail 1
  pass

  let iteration++
done


# Send final data
if [ "${1}" == 'performance' ] ; then
  END="$(date '+%s%N')"
  let "TOTAL = (${END} - ${START}) / 1000000"
  let "TPS   = ${test_number} / (${TOTAL} / 1000)"
  printf "  %'.0f tests in %'.0f ms (%s tests/sec)\n" "${test_number}" "${TOTAL}" "$(bc <<< "scale = 3; ${test_number} / (${TOTAL} / 1000)")" >&2
fi

