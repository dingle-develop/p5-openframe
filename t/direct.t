#!/usr/bin/perl

use strict;
use URI;
use lib 'lib';
use lib 't/lib';
use OpenFrame;
use OpenFrame::Constants;
use OpenFrame::MyApplication;
use OpenFrame::Server::Direct;
use Test::Simple tests => 37;

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
		  config   => {
			       default_session => {
						   language => 'en',
						   country  => 'UK',
						   application => {},
						  },
			       },
                 },
                 {
                  dispatch => 'Local',
                  name     => 'OpenFrame::Slot::Dispatch',
		  config   => {
			       installed_applications => [
							  {
							   namespace => 'myapp',
							   uri       => '/myapp',
							   dispatch  => 'Local',
							   name      => 'OpenFrame::MyApplication',
							  },
							  {
							   namespace => 'default',
							   uri       => '/',
							   dispatch  => 'Local',
							   name      => 'OpenFrame::Application',
							  },
							 ],
			      },
		 },
		 {
		  dispatch => 'Local',
		  name     => 'OpenFrame::Slot::SimpleGenerator'
		 },
		 ]
	       );
$config->setKey(DEBUG => 0);


my $direct = OpenFrame::Server::Direct->new();
ok($direct, "should get OpenFrame::Server::Direct object");


my $cookietin = OpenFrame::Cookietin->new();
my $response;
($response, $cookietin) = $direct->handle("http://localhost/myapp/", $cookietin);
ok($response, "should get response back for /myapp/");
ok($response->code == ofOK, "message code should be ok");
ok($response->mimetype() eq 'openframe/session',
   "mimetype should be openframe/session");
ok(ref($response->message()) eq "OpenFrame::Session", "should get session as message");
ok($response->message->{application}->{current}->{namespace} eq 'myapp',
   "myapp application should have been called");
ok($response->message->{application}->{current}->{entrypoint} eq 'default',
   "default entrypoint should have been called");
my %cookies = $cookietin->get_all;
ok(scalar keys %cookies == 1, "should get 1 cookie");
ok(exists $cookies{session}, "should get session cookie");
my $id = $cookies{session};
ok($id, "should get a session id");

($response, $cookietin) = $direct->handle("http://localhost/error/", $cookietin);
ok($response, "should get response back for /error/");
ok($response->code == ofOK, "message code should be ok");
ok($response->mimetype() eq 'openframe/session',
   "mimetype should be openframe/session");
ok(ref($response->message()) eq "OpenFrame::Session", "should get session as message");
ok($response->message->{application}->{current}->{namespace} eq 'default',
   "default application should have been called");
ok($response->message->{application}->{current}->{entrypoint} eq 'default',
   "default entrypoint should have been called");
%cookies = $cookietin->get_all;
ok(scalar keys %cookies == 1, "should get 1 cookie");
ok(exists $cookies{session}, "should get session cookie");
ok($cookies{session} = $id, "should get same session id");

$response = $direct->handle("http://localhost/myapp/?param=5", $cookietin);
ok($response, "should get response back for /myapp/?param=5");
ok($response->code == ofOK, "message code should be ok");
ok($response->mimetype() eq 'openframe/session',
   "mimetype should be openframe/session");
ok($response->message->{application}->{current}->{namespace} eq 'myapp',
   "myapp application should have been called");
ok($response->message->{application}->{current}->{entrypoint} eq 'example',
   "example entrypoint should have been called");
%cookies = $cookietin->get_all;
ok(scalar keys %cookies == 1, "should get 1 cookie");
ok(exists $cookies{session}, "should get session cookie");
ok($cookies{session} eq $id, "should get same session id");

$response = $direct->handle("http://localhost/error/", $cookietin);
ok($response, "should get response back for /error/ again");
ok($response->code == ofOK, "message code should be ok");
ok($response->mimetype() eq 'openframe/session',
   "mimetype should be openframe/session");
ok(ref($response->message()) eq "OpenFrame::Session", "should get session as message");
ok($response->message->{application}->{current}->{namespace} eq 'default',
   "default application should have been called");
ok($response->message->{application}->{current}->{entrypoint} eq 'default',
   "default entrypoint should have been called");
%cookies = $cookietin->get_all;
ok(scalar keys %cookies == 1, "should get 1 cookie");
ok(exists $cookies{session}, "should get session cookie");
ok($cookies{session} eq $id, "should get same session id");

#print $response->message() . "\n";





