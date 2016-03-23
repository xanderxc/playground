#!/bin/bash

PEM=$1
ENV=$2

error () {
	echo $1
	exit 1
}

# run from script folder; uses ../../(db and lib)
set_ec2_host() {
	if [ "$ENV" == staging ]
	then
		FOLDER='pulse-stage'
	elif [ "$ENV" == production ]
	then
		FOLDER='pulse'
	elif [ "$ENV" == test ]
	then
		FOLDER='test'	
	else
		return 1
	fi
	PULSE_EC2='ec2-user@pulse.twtmob.com:'
	PULSE_EC2_SERVER='ec2-user@pulse.twtmob.com'
	return 0
}

set_ec2_host || error "error setting host variable"

echo $PEM
echo $FOLDER
echo $PULSE_EC2

upload_java_classes() {
    rsync -e "ssh -i $PEM" -avL --delete --progress ./*.jar $PULSE_EC2/opt/$FOLDER/apps/netinterface/
    retval="$?"
    if [ $retval -ne 0 ] && [ $retval -ne 23 ]; then
	    error "rsync with classes failed"
    #else
    #	ssh -i $PEM -t $PULSE_EC2_SERVER  /opt/${FOLDER}/settest.sh
        #ssh -i $PEM -t $PULSE_EC2_SERVER 'sudo chown -R pulse:pulse-prod ${PULSE_EC2}/opt/${FOLDER}'
        #ssh -i $PEM -t $PULSE_EC2_SERVER 'sudo chmod -R u+w,g+w ${PULSE_EC2}/opt/${FOLDER}' 
    fi
}

upload_java_classes

exit 0
