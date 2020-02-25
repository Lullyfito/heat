#!/bin/bash

echo "Do you want to delete the latest created snapshots? [yes/no]: "
read delete_snapshots_option
echo "Enter the total number of spawned instances in your stack: "
read instance_count
echo "Enter the base name of your instances: "
read base_name

if [[ $delete_snapshots_option == "yes" ]]
then
	for i in $(cat ./.latest_instance_snapshots)
	do
		openstack volume snapshot delete $i
	done
fi

if [[ $? -eq 0 ]]
then
	echo -e "\nLatest snapshots deleted succesfully.\n"
else
	echo "Something went wrong."
fi

RESULT=$(( for ((i = 0 ; i < $instance_count ; i++)); \
do \
	openstack volume snapshot create --volume ${base_name}_${i}_os --force ${base_name}_${i}_os; \
done ) | grep ' id ' | awk '{print $4}' | tr '\n' ',' | sed 's/,$//')	

if [[ $? -eq 0 ]]
then
	echo $RESULT | tr ',' ' ' > ./.latest_instance_snapshots
	echo -e "\nThe list of snapshot ID's starting with 0 from left for the first instance:\n\n${RESULT}\n"
	echo "Please copy the output list and add to the parameter 'restore_os_snapshot_id' in your stack parameters file"
else
	echo "Something went wrong."
fi
