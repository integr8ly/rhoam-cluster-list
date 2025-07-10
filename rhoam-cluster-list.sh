#!/bin/bash


echo ''
echo '       _                                        _           _                     _ _     _   '
echo '      | |                                      | |         | |                   | (_)   | |  '
echo '  _ __| |__   ___   __ _ _ __ ___   ____    ___| |_   _ ___| |_ ___ _ __   ____  | |_ ___| |_ '
echo ' |  __|  _ \ / _ \ |__  |  _   _ \ |____|  / __| | | | / __| __/ _ \  __| |____| | | / __| __|'
echo ' | |  | | | | (_) | (_| | | | | | |       | (__| | |_| \__ \ ||  __/ |           | | \__ \ |_ '
echo ' |_|  |_| |_|\___/ \__,_|_| |_| |_|        \___|_|\__,_|___/\__\___|_|           |_|_|___/\__|'
echo ''


printf "%-35s %-25s %-15s %-20s\n" "CLUSTER ID" "NAME" "OPENSHIFT" "ADDON VERSION"
printf "%-35s %-25s %-15s %-20s\n" "-----------------------------------" "-------------------------" "---------------" "--------------------"


ocm list clusters --columns 'id,state' --managed --no-headers | while read -r id state; do
  if [ "$state" != "ready" ]; then
    continue
  fi
  
  if ocm list addons --cluster "$id" | grep 'managed-api-service' | grep -q 'ready'; then
    
    cluster_details=$(ocm describe cluster "$id")
    cluster_name=$(echo "$cluster_details" | grep '^Name:' | awk '{$1=""; print $0}' | xargs)
    ocp_version=$(echo "$cluster_details" | grep 'Version:' | awk '{$1=""; print $0}' | xargs)
    addon_version=$(ocm get "/api/clusters_mgmt/v1/clusters/$id/addons" | jq -r '.items[] | select(.id == "managed-api-service") | .addon_version.id')

    printf "%-35s %-25s %-15s %-20s\n" "$id" "$cluster_name" "$ocp_version" "$addon_version"
  fi
done

echo -e "\nSearch complete."

