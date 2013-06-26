
assertStat() {
  if [ $1 -ne 0 ]; then 
    echo "assertStat: $2 failed, exiting.." >&2
    bell
    exit 1
  else
    echo "assertStat: $2 passed"
  fi
}

assertStatFailed() {
  if [ ! $1 -ne 0 ]; then 
    echo "assertStatFailed: $2 did not fail, exiting.." >&2
    bell
    exit 1
  else
    echo "assertStatFailed: $2 passed"
  fi
}

assertFileExists() {
  if [ ! -f $1 ]; then 
    echo "$2, file $1 does not exist, exiting.."
    bell
    exit 1
  fi
}

assertDirExists() {
  if [ ! -d $1 ]; then 
    echo "$2, dir $1 does not exist, exiting.."
    bell
    exit 1
  fi
}

assertNotExists() {
  if [ -e $1 ]; then 
    echo "$2, dir/file $1 exists, exiting.."
    bell
    exit 1
  fi
}

assertExists() {
  if [ ! -e $1 ]; then 
    echo "$2, dir/file $1 exists, exiting.."
    bell
    exit 1
  fi
}

bell() {
  echo "bell  "
}
