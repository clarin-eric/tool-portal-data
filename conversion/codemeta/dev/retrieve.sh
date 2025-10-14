#!/usr/bin/env bash
set -e

DATA_URL="https://tools.clariah.nl/data.json"
TOOLS_DIR="$(pwd)/tools"
mkdir -p "${TOOLS_DIR}"

echo "Retrieving data from ${DATA_URL}..."
curl -sL "${DATA_URL}" \
	| jq -c '."@graph"[]' \
	| while IFS= read -r line; do
		TOOL_ID="$(jq -r '."@id"' <<<"$line")"
		JSON_FILE="${TOOLS_DIR}/$(sed -E "s/.*tools.clariah.nl.([^\/]+)\/(.*)/\1_\2/"<<<$"TOOL_ID").json"
		echo "${TOOL_ID} -> ${JSON_FILE}"
		echo "$line" | jq . > "${JSON_FILE}"
	done

echo "Tool yamls extracted into ${TOOLS_DIR}"

