#!/bin/bash
# Here is the Bitbucket API to download all the repositories I can access
# https://api.bitbucket.org/2.0/user/permissions/repositories?pagelen=100

usage()
{
   echo "usage: dlBitbucketRepos
      [[-o|--output] <outputFolder>] Default value is the current folder
      [-h|--help]"
}

# Define the files names that are going to gather the data temporarily.
repositories="/tmp/repositories.json"
repoNamesFilePath="/tmp/repoName.txt"
# The destination folder has to be specified. It is the current folder by default.
outputFolder="."

case $1 in
   -o | --output)
      shift
      outputFolder="$1"
      ;;
   -h | --help)
      usage
      exit
      ;;
   *)
      usage
      exit
esac

# Retrieve the Bitbucket Login to connect to the API
read -p "Bitbucket Login : " bitbucketLogin

# Retrieve the Bitbucket App Password to connect to the Bitbucket API
read -s -p "Bitbucket App Password : " bitbucketAppPassword


# Gather and store all the repositories that are in the project "oslo-project" in the "/tmp/repositories.json" folder.
# You have to create an App Password to access all the repositories through a "curl" command.
curl https://api.bitbucket.org/2.0/user/permissions/repositories\?pagelen\=100 -o $repositories -u $bitbucketLogin:$bitbucketAppPassword

# Through the API, we get a JSON file that is stored in the $repositories folder.
# We gather the repositories values that are in "values/{n}/repository/full_name"

# To get the repositories names, one is using jq (https://stedolan.github.io/jq/download/) that can gather and manipulate JSON datas.
# The datas are stored in a file (on repository file per line). "jq -r"  is used so that the '"' that surrounds the repositories names in the file.
jq -r '.values[].repository.full_name|tostring' $repositories > $repoNamesFilePath

# Reading, line per line, the file that contains all the repositories names.
while IFS= read -r repoName; do
   # Git clone command.
   start="git clone --recursive git@bitbucket.org:"
   end=".git "
   result="$start$repoName$end$outputFolder"
   
   # Actuallty cloning the repo to the current directory.
   # eval $result
done < "$repoNamesFilePath"