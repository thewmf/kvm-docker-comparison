#!/bin/bash

export JAVA_HOME=/opt/local/jdk1.7.0_55/
export PATH=$JAVA_HOME/bin:$PATH
export USERDIRECTORY=$HOME/acmeair
export TEMPFILESDIR=/tmp
export WLP_SERVERDIR=$USERDIRECTORY/wlp
export WXS_SERVERDIR=$USERDIRECTORY/ObjectGrid
export ACMEAIR_SRCDIR=$USERDIRECTORY/eclipse/acmeair

export DATESTARTED=`date "+%Y%m%d%H%M%S"` 

function check_directory() {
	if [ ! -e "$USERDIRECTORY/eclipse/acmeair/installed" ]
	then
		echo "acme-air not installed ... bailing out" 
		exit -1
	fi
}


function create_directory() {
	if [ -d "$USERDIRECTORY" ]
	then
		echo "$USERDIRECTORY already exists... bailing out" 
		exit -1
	fi
	mkdir "$USERDIRECTORY" 
}

function unjar_websphere_liberty() {
	cd "$USERDIRECTORY"
	if [ ! -e "$TEMPFILESDIR/wlp-developers-runtime-8.5.5.2.jar"  -o ! -e "$TEMPFILESDIR/wxs-wlp_8.6.0.4.jar" ]
	then
		echo "Websphere files do not exist $TEMPFILESDIR/wlp-developers-runtime-8.5.5.2.jar or $TEMPFILESDIR/wxs-wlp_8.6.0.4.jar bailing out" 
		exit -1	
	fi

	cat <<- EOF1 | java -jar "$TEMPFILESDIR/wlp-developers-runtime-8.5.5.2.jar"
	x
	x
	1
	
	EOF1

	
	cat <<- EOF1 | java -jar "$TEMPFILESDIR/wxs-wlp_8.6.0.4.jar"
	x
	x
	1
	
	EOF1
}

function unzip_websphere_xcale() {
	cd "$USERDIRECTORY"

	if [! -e "$TEMPFILESDIR/extremescaletrial860.zip" ]
	then
		echo "Websphere files do not exist $TEMPFILESDIR/extremescaletrial860.zip ... bailing out" 
		exit -1	
	fi

	unzip /tmp/extremescaletrial860.zip 

	cd ObjectGrid/lib
	mvn install:install-file -Dfile=objectgrid.jar -DgroupId=com.ibm.websphere.objectgrid -DartifactId=objectgrid -Dversion=8.6.0.2 -Dpackaging=jar
}

function get_acmeair() {
	cd "$USERDIRECTORY"

	mkdir eclipse
	cd eclipse
	git clone https://github.com/acmeair/acmeair.git

	
	cd $ACMEAIR_SRCDIR

	# Adjust the files sprint-tx 3.1.2 now it is 3.1.3
	find . -name .classpath -exec rm {} \;
	grep -rl "3\.1\.2" . | while read a; do sed -e "s/3\.1\.2/3.1.3/g" "$a" > "$a.new" ; mv "$a.new" "$a" ; done

	mvn clean compile package install
	mvn clean compile package install
}

function configure_websphere_acmeair() {
	cd $WXS_SERVERDIR
	cp -r gettingstarted acmeair 

	cd acmeair
	if [ ! 	-e "env.sh.old" ]
	then
		cp env.sh env.sh.old
	else
		cp env.sh.old env.sh
	fi

	sed -e "s/SAMPLE_SERVER_CLASSPATH=.*/SAMPLE_SERVER_CLASSPATH=\$SAMPLE_SERVER_CLASSPATH:\$SAMPLE_HOME\/server\/bin:\$SAMPLE_COMMON_CLASSPATH:\$ACMEAIR_SRCDIR\/acmeair-common\/target\/classes:\$ACMEAIR_SRCDIR\/acmeair-services-wxs\/target\/classes:\$HOME\/.m2\/repository\/commons-logging\/commons-logging\/1.1.1\/commons-logging-1.1.1.jar/" env.sh > env.sh.new
	
	mv env.sh.new env.sh

	cp $ACMEAIR_SRCDIR/acmeair-services-wxs/src/main/resources/deployment.xml server/config/
	cp $ACMEAIR_SRCDIR/acmeair-services-wxs/src/main/resources/objectgrid.xml server/config/
}

function run_acme_server_databases() {
	cd $WXS_SERVERDIR/acmeair
	./runcat.sh > /tmp/acmeair-runcat-sh-$DATESTARTED.out 2> /tmp/acmeair-runcat-sh-$DATESTARTED.err&

	sleep 5

	./runcontainer.sh c0 > /tmp/acmeair-runcontainer-sh-$DATESTARTED.out 2> /tmp/acmeair-runcontainer-sh-$DATESTARTED.err&

	sleep 5
}

function start_acme_server_databases() {
	cd $WXS_SERVERDIR/acmeair
	./startcat.sh > /tmp/acmeair-startcat-sh-$DATESTARTED.out 2> /tmp/acmeair-startcat-sh-$DATESTARTED.err&

	sleep 5

	./startcontainer.sh c0 > /tmp/acmeair-startcontainer-sh-$DATESTARTED.out 2> /tmp/acmeair-startcontainer-sh-$DATESTARTED.err&

	sleep 5
}

function stop_acme_server_databases() {
	cd $WXS_SERVERDIR/acmeair
	./stopcontainer.sh c0

	./stopcat.sh
}

function load_databases() {
	cd $ACMEAIR_SRCDIR/acmeair-loader
	mvn exec:java
}

function configure_liberty() {
	cd $WLP_SERVERDIR

	SERVER1_DIR=$WLP_SERVERDIR/usr/servers/server1

	if [ -e "$SERVER1_DIR" ]
	then
		rm -rf "$SERVER1_DIR"
	fi

	bin/server create server1

	if [ ! -e "$SERVER1_DIR/server.xml.old" ]
	then
		cp "$SERVER1_DIR/server.xml" "$SERVER1_DIR/server.xml.old" 
	else
		cp "$SERVER1_DIR/server.xml.old" "$SERVER1_DIR/server.xml" 
	fi
	sed -e "/<featureManager>/,/<\/featureManager>/c<featureManager>\n<feature>jaxrs-1.1<\/feature>\n<feature>jndi-1.0<\/feature>\n<feature>eXtremeScale.client-1.1<\/feature>\n<\/featureManager>\n
s/\([ \t]*\)\(httpPort=\"9080\"\)/\1host=\"*\"\n\1\2/" "$SERVER1_DIR/server.xml" > "$SERVER1_DIR/server.xml.new"

	mv "$SERVER1_DIR/server.xml.new" "$SERVER1_DIR/server.xml"

	cp $ACMEAIR_SRCDIR/acmeair-webapp/target/acmeair-webapp-1.0-SNAPSHOT.war $WLP_SERVERDIR/usr/servers/server1/dropins
}

function start_acme_server() {
	cd $WLP_SERVERDIR
	bin/server start server1
}

function stop_acme_server() {
	cd $WLP_SERVERDIR
	bin/server stop server1
}

function create_init_file() {
	echo "export JAVA_HOME=$JAVA_HOME" > ~/acme-air-init.sh
	echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/acme-air-init.sh
	echo "export USERDIRECTORY=\$HOME/acmeair" >> ~/acme-air-init.sh
	echo "export TEMPFILESDIR=/tmp" >> ~/acme-air-init.sh
	echo "export WLP_SERVERDIR=\$USERDIRECTORY/wlp" >> ~/acme-air-init.sh
	echo "export WXS_SERVERDIR=\$USERDIRECTORY/ObjectGrid" >> ~/acme-air-init.sh
	echo "export ACMEAIR_SRCDIR=\$USERDIRECTORY/eclipse/acmeair" >> ~/acme-air-init.sh

	touch $USERDIRECTORY/eclipse/acmeair/installed
}

function installServer() {
	create_directory
	unjar_websphere_liberty
	unzip_websphere_xcale
	get_acmeair
	configure_websphere_acmeair
	run_acme_server_databases
	load_databases
	stop_acme_server_databases
	configure_liberty
	create_init_file
}

function installServer2() {
	create_directory
	unjar_websphere_liberty
	unzip_websphere_xcale
	get_acmeair
	configure_websphere_acmeair
	run_acme_server_databases
	load_databases
	configure_liberty
	start_acme_server
	create_init_file
}

function startServer() {
	check_directory
	run_acme_server_databases
	start_acme_server
}

function stopServer() {
	check_directory
	stop_acme_server
	stop_acme_server_databases
}

if [ $# -lt 1 ]
then
	echo "$0 - no command given: install, start or stop"
	exit -1;
fi

for i in $@
do
	case $i in
		install)
			installServer;;
		install2)
			installServer2;;
		start)
			startServer;;
		stop)
			stopServer;;
		*)
			echo "$0: invalid command $i";
			exit -1;;
	esac
done
