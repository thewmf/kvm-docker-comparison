# see http://ubuntu-smoser.blogspot.co.uk/2013/02/using-ubuntu-cloud-images-without-cloud.html

all: ubuntu-13.10-server-cloudimg-amd64-disk1.img seed.img

# download a clean VM image
ubuntu-13.10-server-cloudimg-amd64-disk1.img: 
	wget http://cloud-images.ubuntu.com/releases/13.10/release-20140409.1/ubuntu-13.10-server-cloudimg-amd64-disk1.img

# convert user data into an ISO image
seed.img: user-data
	cloud-localds seed.img user-data
