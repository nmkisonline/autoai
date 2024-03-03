#!/bin/bash



# Function to display usage

usage() {

    echo "Usage: $0 [--image] [--download-image] 'Your prompt here'"

    exit 1

}



# Check if at least one argument was provided

if [ $# -eq 0 ]; then

    usage

fi



# Initialize variables

API_KEY="ENTER YOUR API KEY HERE"

MODE="text"

DOWNLOAD_IMAGE=false



# Parse flags

while [[ "$#" -gt 0 ]]; do

    case $1 in

        --image) MODE="image"; shift ;;

        --download-image) DOWNLOAD_IMAGE=true; shift ;;

        *) PROMPT="$1"; shift ;;

    esac

done



# Ensure a prompt was provided

if [ -z "$PROMPT" ]; then

    echo "Error: No prompt provided."

    usage

fi



if [ "$MODE" == "text" ]; then

    # Text generation

    RESPONSE=$(curl -s -X POST "https://api.openai.com/v1/chat/completions" \

        -H "Content-Type: application/json" \

        -H "Authorization: Bearer $API_KEY" \

        --data '{

            "model": "gpt-3.5-turbo",

            "messages": [

                {

                    "role": "system",

                    "content": "You are a helpful assistant."

                },

                {

                    "role": "user",

                    "content": "'"$PROMPT"'"

                }

            ]

        }')

    echo $RESPONSE | jq -r '.choices[0].message.content'

elif [ "$MODE" == "image" ]; then

    # Image generation

    RESPONSE=$(curl -s -X POST "https://api.openai.com/v1/images/generations" \

        -H "Authorization: Bearer $API_KEY" \

        -H "Content-Type: application/json" \

        --data '{

            "model": "dall-e-3",

            "prompt": "'"$PROMPT"'",

            "n": 1,

            "size": "1024x1024"

        }')

    

    if [ "$DOWNLOAD_IMAGE" = true ]; then

        # Extract the image URL from the response and download the image

        IMAGE_URL=$(echo $RESPONSE | jq -r '.data[0].url')

        if [ "$IMAGE_URL" != "null" ] && [ -n "$IMAGE_URL" ]; then

            echo "Downloading image..."

            curl -O "$IMAGE_URL"

            echo "Image downloaded."

        else

            echo "Failed to generate or download image."

        fi

    else

        # Just display the image URL

        echo "Image URL:"

        echo $RESPONSE | jq -r '.data[0].url'

    fi

else

    usage

fi

