#!/usr/bin/perl

# This tests $epoints which are subrefs

use strict;
use URI;
use lib 'lib';
use lib 't/lib';
use OpenFrame::MyApplication;
use OpenFrame::Config;
use OpenFrame::Server::Direct;
use OpenFrame::Constants;
use Test::Simple tests => 47;

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
			       default_session => { },
			       },
                 },
                 {
                  dispatch => 'Local',
                  name     => 'OpenFrame::Slot::Dispatch',
		  config   => {
			       installed_applications => [
							  {
							   name      => 'default',
							   uri       => '/',
							   dispatch  => 'Local',
							   namespace => 'OpenFrame::EpointsApplication',
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


my $cookietin = OpenFrame::AbstractCookie->new();
my $response;
($response, $cookietin) = $direct->handle("http://localhost/myapp/", $cookietin);
ok($response, "should get response back for /myapp/");
ok($response->code == ofOK, "message code should be ok");
ok($response->mimetype() eq 'openframe/session',
   "mimetype should be openframe/session");
ok(ref($response->message()) eq "OpenFrame::Session", "should get session as message");
ok($response->message->{application}->{current}->{name} eq 'default',
   "myapp application should have been called");
ok($response->message->{application}->{current}->{entrypoint} eq 'default',
   "default entrypoint should have been called");
my %cookies = $cookietin->get_all;
ok(scalar keys %cookies == 1, "should get 1 cookie");
ok(exists $cookies{session}, "should get session cookie");
my $id = $cookies{session};
ok($id, "should get a session id");

($response, $cookietin) = $direct->handle("http://localhost/myapp/?foo=1", $cookietin);
ok($response, "should get response back for /error/");
ok($response->code == ofOK, "message code should be ok");
ok($response->mimetype() eq 'openframe/session',
   "mimetype should be openframe/session");
ok(ref($response->message()) eq "OpenFrame::Session", "should get session as message");
ok($response->message->{application}->{current}->{name} eq 'default',
   "default application should have been called");
ok($response->message->{application}->{current}->{entrypoint} eq 'bar',
   "bar entrypoint should have been called");
%cookies = $cookietin->get_all;
ok(scalar keys %cookies == 1, "should get 1 cookie");
ok(exists $cookies{session}, "should get session cookie");
ok($cookies{session} = $id, "should get same session id");

($response, $cookietin) = $direct->handle("http://localhost/myapp/?bar=1", $cookietin);
ok($response, "should get response back for /error/");
ok($response->code == ofOK, "message code should be ok");
ok($response->mimetype() eq 'openframe/session',
   "mimetype should be openframe/session");
ok(ref($response->message()) eq "OpenFrame::Session", "should get session as message");
ok($response->message->{application}->{current}->{name} eq 'default',
   "default application should have been called");
ok($response->message->{application}->{current}->{entrypoint} eq 'quux',
   "quux entrypoint should have been called");
%cookies = $cookietin->get_all;
ok(scalar keys %cookies == 1, "should get 1 cookie");
ok(exists $cookies{session}, "should get session cookie");
ok($cookies{session} = $id, "should get same session id");

($response, $cookietin) = $direct->handle("http://localhost/myapp/?quux=1", $cookietin);
ok($response, "should get response back for /error/");
ok($response->code == ofOK, "message code should be ok");
ok($response->mimetype() eq 'openframe/session',
   "mimetype should be openframe/session");
ok(ref($response->message()) eq "OpenFrame::Session", "should get session as message");
ok($response->message->{application}->{current}->{name} eq 'default',
   "default application should have been called");
ok($response->message->{application}->{current}->{entrypoint} eq 'foo',
   "foo entrypoint should have been called");
%cookies = $cookietin->get_all;
ok(scalar keys %cookies == 1, "should get 1 cookie");
ok(exists $cookies{session}, "should get session cookie");
ok($cookies{session} = $id, "should get same session id");

($response, $cookietin) = $direct->handle("http://localhost/myapp/?xyzzy=1", $cookietin);
ok($response, "should get response back for /error/");
ok($response->code == ofOK, "message code should be ok");
ok($response->mimetype() eq 'openframe/session',
   "mimetype should be openframe/session");
ok(ref($response->message()) eq "OpenFrame::Session", "should get session as message");
ok($response->message->{application}->{current}->{name} eq 'default',
   "default application should have been called");
ok($response->message->{application}->{current}->{entrypoint} eq 'default',
   "default entrypoint should have been called");
%cookies = $cookietin->get_all;
ok(scalar keys %cookies == 1, "should get 1 cookie");
ok(exists $cookies{session}, "should get session cookie");
ok($cookies{session} = $id, "should get same session id");


#print $response->message() . "\n";





