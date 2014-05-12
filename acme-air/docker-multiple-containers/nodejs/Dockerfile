# In production this should probably be busybox, but let's use ubuntu for a
# fair comparison 
FROM tutum/ubuntu-saucy

MAINTAINER Wes Felter, wmf@us.ibm.com

# make sure the package repository is up to date
#RUN echo "deb http://archive.ubuntu.com/ubuntu saucy main universe" > /etc/apt/sources.list
#RUN apt-get update

RUN apt-get install -y openssh-server nodejs nodejs-legacy git screen npm supervisor

#create directory to get acme air
RUN useradd -m acme-air -s /bin/bash
#RUN echo 'root:screencast' |chpasswd
#RUN echo 'acme-air:screencast' |chpasswd
RUN su acme-air -c "mkdir /home/acme-air/code;
                    cd /home/acme-air/code;
                    git clone https://github.com/acmeair/acmeair.git;
                    cd acmeair;
                    git checkout 76a9f35d9976c6aef84f1bfb05b59bafed8e410e;
                    echo 'export ACMEAIR_SRCDIR=/home/acme-air/code/acmeair' >> /home/acme-air/.bash_profile;
                    cat /home/acme-air/.bash_profile"
RUN su -l acme-air -c "cd \$ACMEAIR_SRCDIR/acmeair-webapp-nodejs;
                    sed -e 's/3.0.0beta7/3.3.7/' package.json  > package.json.new;
                    mv package.json.new package.json;
                    npm update" 

EXPOSE 22
EXPOSE 3000

ADD supervisor.conf /etc/supervisor.conf
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisor.conf" ]
