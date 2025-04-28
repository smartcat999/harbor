#!/bin/bash
set -xe

PACKAGE=$1
OUTPUT=$2

PKG_PATH="github.com/goharbor/harbor/src/pkg"
GITCOMMIT=$(git rev-parse --short=8 HEAD)
RELEASEVERSION=$(cat VERSION)
GOFLAGS="-buildvcs=false"


GOTAGS=""
if [ -n "$GOBUILDTAGS" ]; then
    GOTAGS="-tags $GOBUILDTAGS"
fi

GOLDFLAGS=""
if [ -n "$GOBUILDLDFLAGS" ]; then
    GOLDFLAGS="--ldflags -w -s $GOBUILDLDFLAGS"
fi

CORE_LDFLAGS="-X ${PKG_PATH}/version.GitCommit=${GITCOMMIT} -X ${PKG_PATH}/version.ReleaseVersion=${RELEASEVERSION}"
if [ -n "$GOBUILDLDFLAGS" ]; then
    CORE_LDFLAGS="$CORE_LDFLAGS $GOBUILDLDFLAGS"
fi


GOIMAGEBUILDCMD="go build"

cd $PACKAGE

if [ -n "$BUILD_CORE" ]; then
  # core build
  $GOIMAGEBUILDCMD $GOFLAGS $GOTAGS --ldflags "-w -s $CORE_LDFLAGS" -o $OUTPUT $PACKAGE
else
  $GOIMAGEBUILDCMD $GOFLAGS $GOTAGS $GOLDFLAGS -o $OUTPUT $PACKAGE
fi
