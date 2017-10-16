# Build:
#    $ docker build -t perl-test-timer .
# Run:
#    $ docker run -it --rm --name perl-test-timer perl-test-timer

# REF: https://hub.docker.com/_/perl/
# You can switch the version of the executable by changing the parameter below
# 5.10, 5.12, 5.14, 5.16, 5.18, 5.20, 5.22, 5.24 and 5.26 aka latest (currently) - all non-threaded
# You can get threaded versions by appending the string threaded, like so:
# 5.10-threaded a.s.o

FROM perl:latest

# REF: https://stackoverflow.com/questions/37461868/whats-the-difference-between-run-and-cmd-in-a-docker-file-and-when-should-i-use

RUN cpanm Dist::Zilla

COPY . /usr/src/perl-test-timer
WORKDIR /usr/src/perl-test-timer

RUN dzil authordeps | cpanm
RUN dzil listdeps | cpanm

#RUN [ "dzil", "authordeps", "--missing", "|", "cpanm" ]

# REF: https://docs.docker.com/engine/reference/builder/

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
