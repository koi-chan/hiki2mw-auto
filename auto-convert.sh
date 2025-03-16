#!/bin/sh

dir=$1
site_name=$2
if [ "${dir}" != "" ]; then
    if [ ! -d "${dir}" ]; then
        echo "$0: ${dir}: No such directory"
    else
        echo "[Auto convert]"
        ruby lib/auto-convert.rb "${dir}" "${site_name}"

        echo
        echo "[Rewrite links for sub page / Add category]"
        pwd=$(pwd)
        cd ${dir}/hiki2mw/text-mw
        for f in $(ls -1)
        do
                echo $f
                sed -i -r "s/\[\[([^]]+)\]\]/[[${sitename}\/\1|\1]]/g" $f
                echo >> $f
                echo "[[Category:${site_name}]]" >> $f
        done
        cd $pwd

        echo
        echo "[Extract page title from info.db]"
        ruby lib/info2csv.rb "${dir}" "${site_name}"

        echo
        echo "[Copy auto post config]"
        ap_conf_sample="config/auto-post.conf.sample"
        config_dir="${dir}/hiki2mw/config/"
        cp "${ap_conf_sample}" "${config_dir}" && \
            echo "Copied ${ap_conf_sample} to ${config_dir}"
    fi
else
    echo "Usage: $0 HIKI_DATA_DIR SITE_NAME"
fi
