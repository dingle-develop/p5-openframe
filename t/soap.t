#!/usr/bin/perl -w
#
# This test runs the example/soap/soapserver.pl script to check if
# the whole of OpenFrame is working (including OpenFrame::Server::SOAP

use strict;
use lib 'lib';
use lib 't/lib';
use Config;
use OpenFrame;
use OpenFrame::Constants;
use SOAP::Lite;
#use SOAP::Lite +trace => 'all';
use Test::Simple tests => 13;
no warnings qw(once);

ok(1, "loaded");

# We start up the hangman2 SOAP connection on port 8010
my $perl = $Config{'perlpath'};
$perl = $^X if $^O eq 'VMS';
chdir("examples/soap/") || die $!;
my $pid = open(DAEMON, "$perl ./soapserver.pl |");
die "Can't exec: $!" unless defined $pid;
sleep 3; # wait for the server to come up
ok(1, "should get server up ok");

my $soap = new SOAP::Lite
  ->uri("http://localhost:8010/OpenFrame/Server/Direct/")
  ->proxy("http://localhost:8010/");
ok($soap, "should get soap object");

my $result = $soap->call('new');
ok(not($result->fault), "should not get fault on new");

my $direct = $result->result;

my $url = "http://localhost/";
my $cookietin = OpenFrame::Cookietin->new();
my $response;

my $result = $soap->call('handle', $direct, $url, $cookietin);
ok(not($result->fault), "should not get fault on handle");

($response, $cookietin) = $result->paramsall;

ok($response, "should get response back for /");
ok($response->code == ofOK, "message code should be ok");
ok($response->mimetype() eq 'text/html',
   "mimetype should be text/html");
ok($response->message =~ /Hangman/,
   "should get hangman message back");

my %cookies = $cookietin->get_all;
ok(scalar keys %cookies == 1, "should get 1 cookie");
ok(exists $cookies{session}, "should get session cookie");
my $id = $cookies{session};
ok($id, "should get a session id");

# Kill the OpenFrame::Server::SOAP server
kill 9, $pid;
ok(1, "Should be able to kill the server");
