#!/usr/bin/perl -w

use strict;
use lib '../../lib';
use OpenFrame::Constants;
use OpenFrame::Cookietin;

use SOAP::Lite +autodispatch =>
  uri => 'http://localhost:8010/',
  proxy => 'http://localhost:8010/';

my $url = "http://localhost/";
my $cookietin = OpenFrame::Cookietin->new();
my $direct = OpenFrame::Server::Direct->new();

my $response;
($response, $cookietin) = $direct->handle($url, $cookietin);

if ($response->code() == ofOK) {
  print $response->message() . "\n";
} else {
  print "Some sort of error. Drat.\n";
}
