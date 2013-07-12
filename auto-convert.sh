#!/bin/sh

dir=$1
if [ "${dir}" != "" ]; then
    if [ ! -d "${dir}" ]; then
        echo "$0: ${dir}: No such directory"
    else
        echo "[Auto convert]"
        ruby lib/auto-convert.rb "${dir}"

        echo "\n[Extract page title from info.db]"
        ruby lib/info2csv.rb "${dir}"

        echo "\n[Copy auto post config]"
        ap_conf_sample="config/auto-post.conf.sample"
        config_dir="${dir}/hiki2mw/config/"
        cp "${ap_conf_sample}" "${config_dir}" && \
            echo "Copied ${ap_conf_sample} to ${config_dir}"
    fi
else
    echo "Usage: $0 HIKI_DATA_DIR"
fi
