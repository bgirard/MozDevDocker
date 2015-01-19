set -e

for i in $(ls images); do
  NAME=${i#*-} # Remove *-
  echo "Preparing image: ${NAME}"
  Docker build -t "bgirard/$NAME" images/"$i"
done;
