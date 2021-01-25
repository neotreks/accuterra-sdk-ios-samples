if [[ "$CI" ]]; then
  echo "CI environment, access token not required"
  exit 0
else
  echo "Inserting Accuterra access tokens..."

  TOKEN_FILE=~/.accuterra
  if [ -f "$TOKEN_FILE" ]
  then
	  echo "$TOKEN_FILE found."
  else
	  echo "$TOKEN_FILE not found."
    exit 0
  fi

  SUBSTRING="Develop"

  case $TARGET_NAME in
  (*"$SUBSTRING"*) TARGET_ENVIRONMENT="DEVELOPMENT";;
  (*)        TARGET_ENVIRONMENT="TEST";;
  esac

  echo "ENVIRONMENT: $TARGET_ENVIRONMENT"

  output=$(awk '/^\[/ { app=substr($0,2,length-2) } /=/ { print app "." $0 "|"}' $TOKEN_FILE)
  output="${output//[[:space:]]/}"
  lines=($(echo $output | tr '|' '\n'))
  for line in "${lines[@]}"; do
    IFS='=' read -a settings <<< "$line"
    key=${settings[0]}
    value=${settings[1]}
        # Develop environment
    if [[ $TARGET_ENVIRONMENT == "DEVELOPMENT" ]] ; then

      if [[ $key == "DEVELOP.AccuTerraClientToken" ]] ; then
        client=$value
      # no target specified in the config file
      else
        if [[ $key == ".AccuTerraClientToken" ]] ; then
          client=$value
        fi
      fi

      if [[ $key == "DEVELOP.AccuTerraMapToken" ]] ; then
        map=$value
      # no target specified in the config file
      else 
        if [[ $key == ".AccuTerraMapToken" ]] ; then
          map=$value
        fi
      fi

      if [[ $key == "DEVELOP.AccuTerraServiceUrl" ]] ; then
        service_url=$value
      # no target specified in the config file
      else
        if [[ $key == ".AccuTerraServiceUrl" ]] ; then
          service_url=$value
        fi
      fi
    # Test environment
    else
      if [[ $key == "TEST.AccuTerraClientToken" ]] ; then
        client=$value
      # no target specified in the config file
      else
        if [[ $key == ".AccuTerraClientToken" ]] ; then
          client=$value
        fi
      fi

      if [[ $key == "TEST.AccuTerraMapToken" ]] ; then
        map=$value
      # no target specified in the config file
      else 
        if [[ $key == ".AccuTerraMapToken" ]] ; then
          map=$value
        fi
      fi

      if [[ $key == "TEST.AccuTerraServiceUrl" ]] ; then
        service_url=$value
      # no target specified in the config file
      else
        if [[ $key == ".AccuTerraServiceUrl" ]] ; then
          service_url=$value
        fi
      fi
    fi
  done

  if [ "$client" ]; then
    plutil -replace AccuTerraClientToken -string $client "$TARGET_BUILD_DIR/$INFOPLIST_PATH"
    echo "Client Token insertion successful: $client"
  else
    echo \'error: Missing AccuTerra Client token\'
    echo "error: Get an API Keys from https://sdk.accuterra.com/latest/api-keys/, then create a new file at $TOKEN_FILE that contains the API Key values."
    exit 1
  fi
  if [ "$map" ]; then
    plutil -replace AccuTerraMapToken -string $map "$TARGET_BUILD_DIR/$INFOPLIST_PATH"
    echo "Map Token insertion successful: $map"
  else
    echo \'error: Missing AccuTerra Map token\'
    echo "error: Get an API Keys from https://sdk.accuterra.com/latest/api-keys/, then create a new file at $TOKEN_FILE that contains the API Key values."
    exit 1
  fi
  if [ "$service_url" ]; then
    plutil -replace AccuTerraServiceUrl -string $service_url "$TARGET_BUILD_DIR/$INFOPLIST_PATH"
    echo "Service URL insertion successful: $service_url"
  else
    echo \'error: Missing AccuTerra Service URL\'
    echo "error: Get an API Keys from https://sdk.accuterra.com/latest/api-keys/, then create a new file at $TOKEN_FILE that contains the API Key values."
    exit 1
  fi
fi
