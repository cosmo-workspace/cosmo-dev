FILES_DIR=files
KUSTMIZATION_FILE=$FILES_DIR/kustomization.yaml
OUTPUT_FILE=charts/charts/dev-code-server/templates/configmap.yaml

rm -f $KUSTMIZATION_FILE

cat <<EOF > $KUSTMIZATION_FILE
configMapGenerator:
  - name: files
    files:
$(for i in $(find -type f | grep $FILES_DIR); do echo "      - $(basename $i)"; done)

generatorOptions:
  disableNameSuffixHash: true
EOF

kustomize build $FILES_DIR/ > $OUTPUT_FILE
rm -f $KUSTMIZATION_FILE
