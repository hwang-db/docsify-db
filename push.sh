message=$1

# 复制 README.md
# cp README.md docs/README.md

# 更新 main
git add .
git commit -m "$message"
git push -f git@github.com/hwang-db/docsify-db.git main
