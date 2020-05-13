if [[ "$CI" ]]; then
  echo "CI environment, access token not required"
  exit 0
else
  echo "Inserting Accuterra access tokens..."
  token_file=~/.accuterra
  declare value_array

  while IFS=\= read key value; do
    if [[ $key == "AccuTerraClientToken" ]] ; then
      client=$value
    fi
    if [[ $key == "AccuTerraMapToken" ]] ; then
      map=$value
    fi
    if [[ $key == "AccuTerraServiceUrl" ]] ; then
      service_url=$value
    fi
  done < $token_file

  if [ "$client" ]; then
    plutil -replace AccuTerraClientToken -string $client "$TARGET_BUILD_DIR/$INFOPLIST_PATH"
    echo "Client Token insertion successful: $client"
  else
    echo \'error: Missing AccuTerra Client token\'
    echo "error: Get an API Keys from https://sdk.accuterra.com/latest/api-keys/, then create a new file at $token_file that contains the API Key values."
    exit 1
  fi
  if [ "$map" ]; then
    plutil -replace AccuTerraMapToken -string $map "$TARGET_BUILD_DIR/$INFOPLIST_PATH"
    echo "Map Token insertion successful: $map"
  else
    echo \'error: Missing AccuTerra Map token\'
    echo "error: Get an API Keys from https://sdk.accuterra.com/latest/api-keys/, then create a new file at $token_file that contains the API Key values."
    exit 1
  fi
  if [ "$service_url" ]; then
    plutil -replace AccuTerraServiceUrl -string $service_url "$TARGET_BUILD_DIR/$INFOPLIST_PATH"
    echo "Service URL insertion successful: $service_url"
  else
    echo \'error: Missing AccuTerra Service URL\'
    echo "error: Get an API Keys from https://sdk.accuterra.com/latest/api-keys/, then create a new file at $token_file that contains the API Key values."
    exit 1
  fi
fi
