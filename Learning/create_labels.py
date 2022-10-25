import os, json

with open("labels.json", "r") as f:
  open("./tmp/labels.txt", "w").write("\n".join(json.load(f)))
