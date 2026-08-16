#!/bin/bash
# Invariante 4 da seção 22 do spec: nenhuma classe @Model pode declarar
# propriedade de tipo Array ou Set.
#
# Motivo (spec 4.3, risco R-1): a regressão introduzida no iOS 26.1 converte
# esses atributos de Binary Data para Transformable e causa falha de migração
# (NSCocoaErrorDomain 134140) na abertura do store. Não há correção confirmada.
# A regra vale mesmo sem CloudKit (decisão D-1) porque a falha de migração é
# local — o iCloud só piorava a consequência.
#
# O spec pede um teste "que falha o build". Este script é esse teste: roda como
# pre-build phase do target Bilhete e derruba a compilação antes de o binário
# existir. Há também um teste de reflexão em tempo de execução
# (ModelInvariantsTests) que confere a mesma coisa pelo lado do runtime.

set -euo pipefail

MODELS_DIR="${SRCROOT}/Packages/BilheteCore/Sources/BilheteCore/Models"

if [ ! -d "$MODELS_DIR" ]; then
  echo "error: pasta de modelos não encontrada em $MODELS_DIR (invariante 22.4)"
  exit 1
fi

violations=0

# Só interessam as linhas de declaração de propriedade armazenada dentro de
# arquivos que declaram @Model. Comentários e literais de tipo em assinatura de
# função ficam de fora — a invariante é sobre o schema persistido.
for file in "$MODELS_DIR"/*.swift; do
  [ -e "$file" ] || continue
  grep -q "@Model" "$file" || continue

  # Remove comentários de linha antes de analisar, para que a própria explicação
  # da regra (que cita Array e Set) não dispare o alarme.
  matches=$(sed 's|//.*||' "$file" \
    | grep -nE '^[[:space:]]*(public |internal |private |fileprivate )?var[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]*:[[:space:]]*(\[|Array<|Set<)' \
    || true)

  if [ -n "$matches" ]; then
    echo "error: $file declara propriedade Array/Set em classe @Model — proibido pela invariante 22.4 / regra 4.3 do spec (risco R-1)."
    echo "$matches" | while IFS= read -r line; do
      echo "error: $file:${line%%:*}: ${line#*:}"
    done
    violations=1
  fi
done

if [ "$violations" -ne 0 ]; then
  echo "error: coleção futura deve ser modelada como relacionamento entre entidades ou serializada como Data com JSON manual (spec 4.3)."
  exit 1
fi

echo "Invariante 22.4 conferida: nenhuma propriedade Array/Set em @Model."
