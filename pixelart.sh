#!/bin/bash

file=$1
if [ -z $file ]; then
  echo "The script generates commits to customize GitHub history"
  echo "Usage:   sh pixelart.sh FILE"
  echo "Example: sh pixelart.sh art.txt"
  echo "The first line of the art file should contain the starting date"
  exit
fi

generate_commits () {
  start_days=$1
  cur_date=$2

  cur_days=$((`date -d "$cur_date" +"%Y"` * 365 + `date -d "$cur_date" +"%-j"`))
  days_diff=$(($cur_days - $start_days))

  column=$((days_diff / 7 + 1))
  row=$((2 + `date -d "$cur_date" +"%w"`))

  # Get a symbol from the file
  line=`head -n $row $file | tail -n 1`
  value=`expr substr "$line" $column 1`
  echo "Symbol on the day $((days_diff + 1)) (row: $row  column: $column) is '$value'"
  if [ "$value" \> "/" ]; then
    while [ $value -gt 0 ]
    do
      value=$(($value - 1))
      label=$((1 + `cat v.txt`))
      echo $label > v.txt
      # do the actual git commit. Output only one line per commit.
      git commit --date "$cur_date" -m "$label" v.txt | head -n 1
    done
  fi
}

if [ ! -f v.txt ]; then
  # Create a dummy file for commits
  echo 1 > v.txt
  git add v.txt
fi

start_date=`head -n 1 $file`
start_days=$((`date -d "$start_date" +"%Y"` * 365 + `date -d "$start_date" +"%-j"`))
# Note: the script relies on day differences and does not do leap year adjustments
for i in `seq 0 365`; do
  new_date=`date -d "$start_date+$i days"`
  generate_commits $start_days "$new_date"
done
