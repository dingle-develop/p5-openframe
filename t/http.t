#!/usr/bin/perl -w
#
# This test runs the example/hangman2/hangman.pl script to check if
# the whole of OpenFrame is working (including OpenFrame::Server::HTTP

use strict;
use lib 'lib';
use lib 't/lib';
use Config;
use LWP::UserAgent;
use Test::Simple tests => 8;

# We start up the hangman2 connection on port 8000
my $perl = $Config{'perlpath'};
$perl = $^X if $^O eq 'VMS';
chdir("examples/hangman2/");
my $pid = open(DAEMON, "$perl ./hangman.pl |");
die "Can't exec: $!" unless defined $pid;
sleep 1; # wait for the server to come up

my $greeting = <DAEMON>;
ok($greeting, "Should get greeting back");
ok($greeting eq "Point your browser to http://localhost:8000/ to play hangman!\n",
   "Should get correct greeting back");

my $ua = LWP::UserAgent->new();
my $request = HTTP::Request->new('GET', "http://localhost:8000/index.html");
my $response = $ua->request($request);

ok($response, "Should get response back");
ok($response->is_success, "Should get successful response back");
print $response->error_as_HTML unless $response->is_success;

ok($response->content_type eq 'text/html', "Should get text/html back");

my $html = $response->content;
ok($html, "Should get some HTML back");
ok($html =~ m|<h1>Hangman</h1>|, "Should get Hangman HTML back");

# Kill the OpenFrame::Server::HTTP servers
kill -9, $pid;
ok(1, "Should be able to kill the servers");
