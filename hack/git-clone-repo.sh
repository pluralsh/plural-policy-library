#!/bin/bash

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
reset=`tput sgr 0`

SCRIPT_VERSION="1.0.1"

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# Print usage
print_usage() {
  echo -n "${reset}${SCRIPT_NAME} [-h] [-v] [--branch <branch>] [--tag <tag>] <git-repo>

This script will checkout a git repository to a temporary directory and return the path to the directory

Example:
  ${SCRIPT_NAME} \"Safetrack/trackunit-go-ios\"

  - will checkout the master branch of the \"trackunit-go-ios\" repository

Options:
      --branch         Define the branch to checkout. Default is 'master'. Cannot be combined with \"--tag\".
      --tag            Define the tag to checkout. Cannot be combined with \"--branch\".
  -h, --help           Display this help and exit
      --version        Output version information and exit
"
}

print_error() {
    local msg="$1"
    echo "${red}${msg}${reset}" >&2
}

# parse parameters - from https://medium.com/@Drew_Stokes/bash-argument-parsing-54f3b81a6a8f
PARAMS=""
while (( "$#" )); do
    case "$1" in
        -h|--help)
            print_usage
            exit 0
            ;;
        --version)
            echo ${SCRIPT_VERSION}
            exit 0
            ;;
        --branch)
            BRANCH="$2"
            shift 2
            ;;
        --tag)
            TAG="$2"
            shift 2
            ;;
        --) # end argument parsing
            shift
            break
            ;;
        -*|--*=) # unsupported flags
            print_error "Unsupported flag $1"
            print_usage
            exit 1
            ;;
        *) # preserve positional arguments
            PARAMS="$PARAMS $1"
            shift
            ;;
    esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"

REPO="$1"

if [ -z "${REPO}" ]; then
    print_error "<git-repo> parameter not found!"
    print_usage
    exit 1
fi

if [ -n "${BRANCH}" ] && [ -n "${TAG}" ]; then
    print_error "Cannot use both --branch and --tag"
    print_usage
    exit 1
fi

checkout_branch="${BRANCH:-master}"

if [ -n "${TAG}" ]; then
    checkout_branch="tags/${TAG}"
fi

temp_dir="$(mktemp -d)" && \
    git clone -q git@github.com:${REPO%.git}.git "${temp_dir}" && \
        cd "${temp_dir}/" && \
            git -c advice.detachedHead=false checkout -q ${checkout_branch}

# all is well?
test $? -eq 0 || { print_error "Error cloning repository."; exit 1; }

echo ${temp_dir}