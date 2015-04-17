#!/usr/bin/env bash

[ $# == 3 ] || { echo "${0} <family_list> <fasta> <out_dir>"; exit 1; }
[ -f ${1} ] || { echo ${1} not exist; exit 1; }
[ -f ${2} ] || { echo ${2} not exist; exit 1; }
[ -d ${3} ] || { echo ${3} not exist; exit 1; }

function file_abs_path() {
  [ -f ${1} ] \
    && { echo $(cd $(dirname ${1}); pwd)/$(basename ${1}); }
}

family_list=$(file_abs_path ${1})
fasta=$(file_abs_path ${2})
out_dir=$(cd ${3}; pwd)

muscle_command="muscle3.8.31_i86linux64"

mkdir ${out_dir}/fasta
while read family
do
  in_fasta=${out_dir}/fasta/${family}.fa
  awk -v family=${family} \
  'BEGIN{ex=">[^_]+_"family"_chr"}
   /^>/ {f=0}
   $0 ~ ex{print;f=1}
   $0 ~ "^[^>]" && f==1{print}' ${fasta} > ${in_fasta}
  out_file=${out_dir}/${family}.aln
  ${muscle_command} -maxiters 2 -in ${in_fasta} -out ${out_file}
done < ${family_list}
