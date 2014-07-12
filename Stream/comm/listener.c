/*
** listener.c -- a datagram sockets "server" demo
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

#define MYPORT "4950"	// the port users will be connecting to

#define MAXBUFLEN 100

// get sockaddr, IPv4 or IPv6:
void *get_in_addr(struct sockaddr *sa)
{
	if (sa->sa_family == AF_INET) {
		return &(((struct sockaddr_in*)sa)->sin_addr);
	}

	return &(((struct sockaddr_in6*)sa)->sin6_addr);
}


double
GetTime ()
{
   struct timeval tp;
   (void) gettimeofday( &tp, NULL );
   return (tp.tv_sec + ((double) tp.tv_usec)/1000000.0);
}



int main(int argc, char **argv)
{
	int sockfd;
	struct addrinfo hints, *servinfo, *p;
	int rv;
	int numbytes;
	struct sockaddr_storage their_addr;
	char buf[MAXBUFLEN];
	socklen_t addr_len;
	char s[INET6_ADDRSTRLEN];

	memset(&hints, 0, sizeof hints);
	hints.ai_family = AF_UNSPEC; // set to AF_INET to force IPv4
	hints.ai_socktype = SOCK_DGRAM;
	hints.ai_flags = AI_PASSIVE; // use my IP

	char *myport = (argc > 1) ? argv[1] : MYPORT;

	if ((rv = getaddrinfo(NULL, myport, &hints, &servinfo)) != 0) {
		fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
		return 1;
	}

	// loop through all the results and bind to the first we can
	for(p = servinfo; p != NULL; p = p->ai_next) {
		if ((sockfd = socket(p->ai_family, p->ai_socktype,
				p->ai_protocol)) == -1) {
			perror("listener: socket");
			continue;
		}

		if (bind(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
			close(sockfd);
			perror("listener: bind");
			continue;
		}

		break;
	}

	if (p == NULL) {
		fprintf(stderr, "listener: failed to bind socket\n");
		return 2;
	}

	freeaddrinfo(servinfo);

	printf("listener: waiting to recvfrom on port %s ...\n", myport);

	addr_len = sizeof their_addr;

	double now, prev = 0;
	while (1) {
	    if ((numbytes = recvfrom(sockfd, buf, MAXBUFLEN-1 , 0,
		    (struct sockaddr *)&their_addr, &addr_len)) == -1) {
		    perror("recvfrom");
		    exit(1);
	    }

	    now = GetTime();
	    double deltat = now - prev;
	    prev = now;

	    buf[numbytes] = '\0';
	    printf("listener: got packet at delta %f (abs %f) with data <%s>\n", deltat, now, buf);
	    fflush (stdout);
        }

	close(sockfd);

	return 0;
}
