# see http://ubuntu-smoser.blogspot.co.uk/2013/02/using-ubuntu-cloud-images-without-cloud.html

all: ubuntu-13.10-server-cloudimg-amd64-disk1.img seed.img play.img

# download a clean VM image
ubuntu-13.10-server-cloudimg-amd64-disk1.img: 
	wget http://cloud-images.ubuntu.com/releases/13.10/release-20140409.1/ubuntu-13.10-server-cloudimg-amd64-disk1.img

ubuntu-14.04-server-cloudimg-amd64-disk1.img:
	wget http://cloud-images.ubuntu.com/releases/14.04/release-20140416.1/ubuntu-14.04-server-cloudimg-amd64-disk1.img

# convert user data into an ISO image
seed.img: user-data
	cloud-localds seed.img user-data

# build a qcow layer for playing around
play.img: ubuntu-13.10-server-cloudimg-amd64-disk1.img
	qemu-img create -f qcow2 -b ubuntu-13.10-server-cloudimg-amd64-disk1.img play.img

play-trusty.img: ubuntu-14.04-server-cloudimg-amd64-disk1.img
	qemu-img create -f qcow2 -b ubuntu-14.04-server-cloudimg-amd64-disk1.img play.img

clean:
	rm *.img
