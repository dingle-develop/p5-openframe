#!/usr/bin/perl

use strict;
use warnings;
use URI;
use lib 'lib';
use lib 't/lib';
use OpenFrame::MyApplication;
use OpenFrame::Config;
use OpenFrame::Server::Direct;
use OpenFrame::Constants;
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
			       sessiondir => "t/sessiondir",
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


my $direct = OpenFrame::Server::Direct->new($config);
ok($direct, "should get OpenFrame::Server::Direct object");


my $cookietin = OpenFrame::AbstractCookie->new();
my $response;
($response, $cookietin) = $direct->handle("http://localhost/myapp/", $cookietin);
ok($response, "should get response back for /myapp/");
ok($response->code == ofOK, "message code should be ok");
ok($response->mimetype() eq 'openframe/session',
   "mimetype should be openframe/session");
ok(ref($response->message()) eq "OpenFrame::Session", "should get session as message");
ok($response->message->{application}->{current}->{name} eq 'myapp',
   "myapp application should have been called");
ok($response->message->{application}->{current}->{entrypoint} eq 'default',
   "default entrypoint should have been called");
ok(scalar($cookietin->getCookies()) == 1, "should get 1 cookie");
my $biscuit = ($cookietin->getCookies())[0];
ok($biscuit->getName() eq 'session', "should get session cookie");
my $id = $biscuit->getValue();
ok($id, "should get a session id");

($response, $cookietin) = $direct->handle("http://localhost/error/", $cookietin);
ok($response, "should get response back for /error/");
ok($response->code == ofOK, "message code should be ok");
ok($response->mimetype() eq 'openframe/session',
   "mimetype should be openframe/session");
ok(ref($response->message()) eq "OpenFrame::Session", "should get session as message");
ok($response->message->{application}->{current}->{name} eq 'default',
   "default application should have been called");
ok($response->message->{application}->{current}->{entrypoint} eq 'default',
   "default entrypoint should have been called");
ok(scalar($cookietin->getCookies()) == 1, "should get 1 cookie");
$biscuit = ($cookietin->getCookies())[0];
ok($biscuit->getName() eq 'session', "should get session cookie");
ok($biscuit->getValue() eq $id, "should get same session id");

$response = $direct->handle("http://localhost/myapp/?param=5", $cookietin);
ok($response, "should get response back for /myapp/?param=5");
ok($response->code == ofOK, "message code should be ok");
ok($response->mimetype() eq 'openframe/session',
   "mimetype should be openframe/session");
ok($response->message->{application}->{current}->{name} eq 'myapp',
   "myapp application should have been called");
ok($response->message->{application}->{current}->{entrypoint} eq 'example',
   "example entrypoint should have been called");
ok(scalar($cookietin->getCookies()) == 1, "should get 1 cookie");
$biscuit = ($cookietin->getCookies())[0];
ok($biscuit->getName() eq 'session', "should get session cookie");
ok($biscuit->getValue() eq $id, "should get same session id");

$response = $direct->handle("http://localhost/error/", $cookietin);
ok($response, "should get response back for /error/ again");
ok($response->code == ofOK, "message code should be ok");
ok($response->mimetype() eq 'openframe/session',
   "mimetype should be openframe/session");
ok(ref($response->message()) eq "OpenFrame::Session", "should get session as message");
ok($response->message->{application}->{current}->{name} eq 'default',
   "default application should have been called");
ok($response->message->{application}->{current}->{entrypoint} eq 'default',
   "default entrypoint should have been called");
ok(scalar($cookietin->getCookies()) == 1, "should get 1 cookie");
$biscuit = ($cookietin->getCookies())[0];
ok($biscuit->getName() eq 'session', "should get session cookie");
ok($biscuit->getValue() eq $id, "should get same session id");

#print $response->message() . "\n";





