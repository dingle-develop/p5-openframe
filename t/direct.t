#!/usr/bin/perl

use strict;
use warnings;
use URI;
use lib 'lib';
use lib 't/lib';
use OpenFrame::MyApplication;
use OpenFrame::Config;
use OpenFrame::Server::Direct;
use OpenFrame::AbstractResponse;
use Test::Simple tests => 8;

my $config = OpenFrame::Config->new();
ok($config, "should get config");
$config->setKey(
		'SLOTS',
	        [
		 {
		  dispatch => 'Local',
		  name => 'OpenFrame::Slot::NoImages',
		 },
		 {
		  dispatch => 'Local',
		  name     => 'OpenFrame::Slot::Session',
		 },
		 {
		  dispatch => 'Local',
		  name     => 'OpenFrame::Slot::Dispatch',
		 },
		 {
		  dispatch => 'Local',
		  name     => 'OpenFrame::Slot::SessionSaver',
		 },
		 {
		  dispatch => 'Local',
		  name     => 'OpenFrame::Slot::SimpleGenerator'
		 },
		 {
		  dispatch => 'Local',
		  name     => 'OpenFrame::Slot::ErrorText'
		 },
		]
	       );
$config->setKey(
		'DEBUG',
		0
	       );
$config->setKey(
		'default_session',
		{
		 language => 'en',
		 country  => 'UK',
		 application => {},
		}
	       );
$config->setKey(
		'installed_applications',
		[
		 {
		  name      => 'myapp',
		  uri       => '/myapp',
		  dispatch  => 'Local',
		  namespace => 'OpenFrame::MyApplication',
		 },
		 {
		  name      => 'default',
		  uri       => '/',
		  dispatch  => 'Local',
		  namespace => 'OpenFrame::Application',
		 }
		]
	       );

$config->setKey(
		'sessiondir',
		't/sessiondir'
	       );

my $direct = OpenFrame::Server::Direct->new($config);
ok($direct, "should get OpenFrame::Server::Direct object");

my $response = $direct->handle("http://localhost/myapp/");
ok($response, "should get response back for /myapp/");
ok($response->getMessageCode == ofOK, "message code should be ok");
ok($response->getMessage() eq "Here is the output of SimpleGenerator for /myapp/
No parameters were passed", "got correct message");

$response = $direct->handle("http://localhost/myapp/?param=5");
ok($response, "should get response back for /myapp/?param=5");
ok($response->getMessageCode == ofOK, "message code should be ok");
ok($response->getMessage() eq "Here is the output of SimpleGenerator for /myapp/
A parameter was passed: 5", "got correct message");

#print $response->getMessage() . "\n";


