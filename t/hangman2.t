#!/usr/bin/perl

use strict;
use URI;
use lib 'lib';
use lib 't/lib';
use lib 'examples/hangman2';
use OpenFrame::Config;
use OpenFrame::Server::Direct;
use OpenFrame::Constants;
use Test::Simple tests => 24;

my $config = OpenFrame::Config->new();
ok($config, "should get config");
$config->setKey(
                'SLOTS',
                [
                 {
                  dispatch => 'Local',
                  name => 'OpenFrame::Slot::Images',
		  config   => { directory => 'examples/webserver/htdocs/' },
                 },
                 {
                  dispatch => 'Local',
                  name     => 'OpenFrame::Slot::Session',
		  config   => {
			       directory => "t/sessiondir",
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
							   name      => 'hangman',
							   uri       => '/',
							   dispatch  => 'Local',
							   namespace => 'Hangman::Application',
							   config    => { words => "examples/hangman/words.txt" },
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
($response, $cookietin) = $direct->handle("http://localhost/", $cookietin);
ok($response, "should get response back for /");
ok($response->code == ofOK, "message code should be ok");
ok($response->mimetype() eq 'openframe/session',
   "mimetype should be openframe/session");
ok(ref($response->message()) eq "OpenFrame::Session", "should get session as message");
ok($response->message->{application}->{current}->{name} eq 'hangman',
   "hangman application should have been called");

my $game = $response->message->{application}->{hangman}->{game};
ok(ref($game) eq 'Games::WordGuess', "game object should be present");
ok($game->get_chances == 6, "game should have 6 chances");
ok($game->get_score == 0, "game should have 0 score");

ok(scalar($cookietin->getCookies()) == 1, "should get 1 cookie");
my $biscuit = ($cookietin->getCookies())[0];
ok($biscuit->getName() eq 'session', "should get session cookie");
my $id = $biscuit->getValue();
ok($id, "should get a session id");



($response, $cookietin) = $direct->handle("http://localhost/?guess=E", $cookietin);
ok($response, "should get response back for /?guess=E");
ok($response->code == ofOK, "message code should be ok");
ok($response->mimetype() eq 'openframe/session',
   "mimetype should be openframe/session");
ok(ref($response->message()) eq "OpenFrame::Session", "should get session as message");
ok($response->message->{application}->{current}->{name} eq 'hangman',
   "hangman application should have been called");

$game = $response->message->{application}->{hangman}->{game};
ok(ref($game) eq 'Games::WordGuess', "game object should be present");
ok($game->get_chances == 5 || $game->get_chances == 6,
   "game should have 5 or 6 chances");
ok($game->get_score == 0, "game should have 0 score");

ok(scalar($cookietin->getCookies()) == 1, "should get 1 cookie");
$biscuit = ($cookietin->getCookies())[0];
ok($biscuit->getName() eq 'session', "should get session cookie");
ok($biscuit->getValue() eq $id, "should get current id");

#print $response->message() . "\n";





