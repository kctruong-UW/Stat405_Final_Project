#!/bin/bash
export PATH=$PWD/bin:$PATH
i=$SLURM_ARRAY_TASK_ID
year=$((2019 + (i - 1) / 12))
month=$(printf %02d $(( (i - 1) % 12 + 1 )))
day=$year-$month-15
re='copilot|chatgpt|gpt-?4|openai|\bclaude\b|codeium|cursor\.sh'

# for each hour: download, keep human events, emit type/action/#commits/#AI commits, delete
for h in {0..23}; do
  wget -q https://data.gharchive.org/$day-$h.json.gz
  zcat $day-$h.json.gz | jq -r --arg re "$re" '
    select(.actor.login | endswith("[bot]") | not)
    | [.type,
       (.payload.action // .payload.ref_type // "-"),
       (.payload.commits // [] | length),
       ([.payload.commits[]?.message // "" | select(test($re; "i"))] | length)]
    | @tsv'
  rm -f $day-$h.json.gz
done | awk -F'\t' -v d=$day '
  { n[$1 ":" $2]++; c += $3; a += $4 }
  END { for (k in n) print d "," k "," n[k]; print d ",commits," c; print d ",ai_commits," a }' > day_$day.csv
