#!/usr/bin/perl

use strict;
use URI;
use lib 'lib';
use lib 't/lib';
use OpenFrame;
use OpenFrame::Constants;
use OpenFrame::MyApplication;
use OpenFrame::Server::Direct;
use Test::Simple tests => 27;

my $config = OpenFrame::Config->new();
ok($config, "should get config");
$config->setKey('SLOTS' => []);
$config->setKey(DEBUG => 0);

my $direct = OpenFrame::Server::Direct->new();
ok($direct, "should get OpenFrame::Server::Direct object");

my $cookietin = OpenFrame::Cookietin->new();
my $response;
($response, $cookietin) = $direct->handle("http://localhost/", $cookietin);
ok($response, "should get response back for / with no slots");
ok($response->code == ofERROR, "message code should be error");
ok($response->mimetype() eq 'text/plain',
   "mimetype should be text/plain");
ok($response->message() eq "None of the OpenFrame slots returned a response object", "should get correct error message");
my %cookies = $cookietin->get_all;
ok(scalar keys %cookies == 0, "should get no cookie");

$config->setKey(
                SLOTS =>
                [
                 {
                  dispatch => 'Local',
                  name     => 'OpenFrame::Slot::Which::Does::Not::Exist',
                 },
                ]
	       );

($response, $cookietin) = $direct->handle("http://localhost/", $cookietin);
ok($response, "should get response back for / with a wrong slot");
ok($response->code == ofERROR, "message code should be error");
ok($response->mimetype() eq 'text/plain',
   "mimetype should be text/plain");
ok($response->message() eq "None of the OpenFrame slots returned a response object", "should get correct error message");
%cookies = $cookietin->get_all;
ok(scalar keys %cookies == 0, "should get no cookie");

$config->setKey(
                SLOTS =>
                [
                 {
                  dispatch => 'Local',
                  name     => 'OpenFrame::Slot::ErrorText',
                 },
                ]
	       );

($response, $cookietin) = $direct->handle("http://localhost/", $cookietin);
ok($response, "should get response back for / with ErrorText slot");
ok($response->code == ofOK, "message code should be OK");
ok($response->mimetype() eq 'text/html',
   "mimetype should be text/html");
ok($response->message() eq 
			q{
			  <html>
			  <head>
			    <title>Error</title>
			  </head>
			  <body>
			    <h1>Error</h1>
                            <p>There was an error processing your request</p>
			  </body>
			  </html>
			 }
, "should get correct error message");
%cookies = $cookietin->get_all;
ok(scalar keys %cookies == 0, "should get no cookie");

$config->setKey(
                SLOTS =>
                [
                {
                  dispatch => 'Local',
                  name     => 'OpenFrame::Slot::Dispatch',
                  config   => {
                               installed_applications => [
                                                          {
                                                           name      => 'nothere',
                                                           uri       => '/',
                                                           dispatch  => 'Local',
                                                           namespace => 'OpenFrame::Application::Which::Does::Not::Exist',
                                                          },
                                                         ],
                              },
                 },
                ]
	       );

($response, $cookietin) = $direct->handle("http://localhost/", $cookietin);
ok($response, "should get response back for / with non-existant app (without session)");
ok($response->code == ofERROR, "message code should be error");
ok($response->mimetype() eq 'text/plain',
   "mimetype should be text/plain");
ok($response->message() eq "None of the OpenFrame slots returned a response object",
  "should get correct error message");
%cookies = $cookietin->get_all;
ok(scalar keys %cookies == 0, "should get no cookie");

$config->setKey(
                SLOTS =>
                [
                 {
                  dispatch => 'Local',
                  name     => 'OpenFrame::Slot::Session',
                 },
                {
                  dispatch => 'Local',
                  name     => 'OpenFrame::Slot::Dispatch',
                  config   => {
                               installed_applications => [
                                                          {
                                                           name      => 'nothere',
                                                           uri       => '/',
                                                           dispatch  => 'Local',
                                                           namespace => 'OpenFrame::Application::Which::Does::Not::Exist',
                                                          },
                                                         ],
                              },
                 },
                ]
	       );

($response, $cookietin) = $direct->handle("http://localhost/", $cookietin);
ok($response, "should get response back for / with non-existant app");
ok($response->code == ofERROR, "message code should be error");
ok($response->mimetype() eq 'text/plain',
   "mimetype should be text/plain");
ok($response->message() eq "None of the OpenFrame slots returned a response object",
  "should get correct error message");
%cookies = $cookietin->get_all;
ok(scalar keys %cookies == 0, "should get no cookie");

#print $response->mimetype() . "<--\n";
#print $response->message() . "\n";

