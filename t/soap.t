#!/usr/bin/perl -w
#
# This test runs the example/soap/soapserver.pl script to check if
# the whole of OpenFrame is working (including OpenFrame::Server::SOAP

use strict;
use lib 'lib';
use lib 't/lib';
use Config;
use OpenFrame::Constants;
use SOAP::Lite +autodispatch =>
  uri => 'http://localhost:8010/',
  proxy => 'http://localhost:8010/';
use Test::Simple tests => 6;
no warnings qw(once);

# We start up the hangman2 SOAP connection on port 8010
my $perl = $Config{'perlpath'};
$perl = $^X if $^O eq 'VMS';
chdir("examples/soap/") || die $!;
my $pid = open(DAEMON, "$perl ./soapserver.pl |");
die "Can't exec: $!" unless defined $pid;
sleep 3; # wait for the server to come up
ok(1, "should get server up ok");

my $url = "http://localhost/";
my $cookietin = OpenFrame::AbstractCookie->new();
my $direct = OpenFrame::Server::Direct->new();

my $response;
($response, $cookietin) = $direct->handle($url, $cookietin);

ok($response, "should get response back for /");
ok($response->code == ofOK, "message code should be ok");
ok($response->mimetype() eq 'text/html',
   "mimetype should be text/html");
ok($response->message =~ m|<h1>Hangman</h1>|,
   "should get hangman message back");

# Kill the OpenFrame::Server::SOAP server
kill 9, $pid;
ok(1, "Should be able to kill the server");
