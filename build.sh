#!/bin/ash

function createPostData() {
  asciidocFilePath=$1
  postDataFilePath=$2 
  sed -z 's/^[ \t\r\n]*//' ${asciidocFilePath} | csplit -z --suppress-matched - /^---/ {1}
  # cat xx01 | tail -n +2 | asciidoctor -r asciidoctor-diagram --backend docbook --out-file - - | pandoc --from docbook --to html5 | sed -z 's/>\r\?\n/>/g' > ${postDataFilePath}
  # cat xx01 | tail -n +2 | asciidoctor -r asciidoctor-diagram -a outdir=.asciidoctor -a imagesdir=.asciidoctor -a imagesoutdir=.asciidoctor --backend docbook --out-file - - | pandoc --from docbook --to html5 | sed -z 's/>\r\?\n/>/g' > ${postDataFilePath}
  cat xx01 | tail -n +2 | asciidoctor -r asciidoctor-diagram -a outdir=.asciidoctor -a imagesdir=.asciidoctor -a imagesoutdir=.asciidoctor -e --out-file - - | pandoc --from html --to html5 | sed -z 's/>\r\?\n/>/g' > ${postDataFilePath}
}

function createRequestBody () {
  postDataTitle=$1
  postDataFilePath=$2
  requestBodyFilePath=$3
  spaceKey=$4
  ancestorId=$5

  echo "postDataTitle=${postDataTitle}"
  echo "postDataFilePath=${postDataFilePath}"
  echo "requestBodyFilePath=${requestBodyFilePath}"
 
  jq '.body.storage.value |=$value' --rawfile value ${postDataFilePath} template.body.json | \
    jq ".title |=\"${postDataTitle}\"" | \
    jq ".space.key |=\"${spaceKey}\"" | \
    jq ".ancestors[0].id |=\"${ancestorId}\"" > ${requestBodyFilePath}
}

function publish () {
  team=$1
  userName=$2
  apiKey=$3
  requestBodyFilePath=$4
  curl -X POST "https://${team}.atlassian.net/wiki/rest/api/content" -u "${userName}:${apiKey}" \
  -H 'Accept: application/json' \
  -H 'Content-Type: application/json' \
  -d "@${requestBodyFilePath}" > response.json
}


cd `dirname "$0"`

FILE_PATH=$1
FILE_NAME="${FILE_PATH##*/}"
POST_DATA_TITLE="${FILE_NAME%%.adoc}_`TZ=Asia/Tokyo date +%Y%m%d_%H-%M-%S`"
POST_DATA_FILE_PATH=post-data.html
REQUEST_BODY_FILE_PATH=requestBody.json

createPostData "${FILE_PATH}" "${POST_DATA_FILE_PATH}"
createRequestBody "${POST_DATA_TITLE}" "${POST_DATA_FILE_PATH}" "${REQUEST_BODY_FILE_PATH}" "${SPACE_KEY}" "${ANCESTOR_ID}"
publish "${TEAM}" "${USER_ID}" "${API_KEY}" "${REQUEST_BODY_FILE_PATH}"


# createRequestBody ${FILE_NAME}
# createRequestBody ${TEAM} ${USER_ID} ${API_KEY} ${FILE_PATH##*/}