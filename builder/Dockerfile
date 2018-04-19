FROM debian:9

# This image exposes port 9999 where roundup is being served from
EXPOSE 9999

# Set labels needed for S2I to work as well as general information about the image
LABEL io.openshift.s2i.scripts-url=image:///opt/tracker/s2i \
      summary="bugs.python.org builder image" \
      maintainer="Maciej Szulik <soltysh@gmail.com>"

# Update image and install necessary packages
RUN apt-get update && \
    apt-get install -y python python-psycopg2 python-pip python-dev libffi-dev libssl-dev curl mercurial && \
    apt-get clean

# Copy the necessary S2I scripts and files needed to run roundup
RUN mkdir -p /opt/tracker/bin && mkdir -p /opt/tracker/s2i
COPY s2i /opt/tracker/s2i
COPY requirements.txt /opt/tracker
COPY bin /opt/tracker/bin

# Install python side of requirements for roundup
RUN pip install -r /opt/tracker/requirements.txt && \
    # we delete the http packages introduced by pyoic. it will fail roundup
    rm -rf /usr/local/lib/python2.7/dist-packages/http

# In order to drop the root user, we have to make some directories world
# writable as OpenShift default security model is to run the container under
# random UID.
RUN chown -R 1001:0 /opt/tracker && chmod -R og+rwx /opt/tracker

USER 1001

CMD ["/opt/tracker/s2i/usage"]
