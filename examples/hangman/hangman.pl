#!/usr/bin/perl -w
#
# The hangman images are by Andy Wardley
#
# This version of hangman uses templates

use strict;
use lib '../../lib';

use OpenFrame::Config;
use OpenFrame::Server::HTTP;

my $config = OpenFrame::Config->new();
$config->setKey(
                'SLOTS',
                [
                 {
                  dispatch => 'Local',
                  name => 'OpenFrame::Slot::Images',
		  config   => { directory => './' },
                 },
                 {
                  dispatch => 'Local',
                  name     => 'OpenFrame::Slot::Session',
		  config   => {
			       sessiondir => "../../t/sessiondir",
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
							   config   => { words => "./words.txt" },

							  },
							 ],
			      },
                 },
                 {
                  dispatch => 'Local',
                  name     => 'Hangman::Generator',
		  config   => { presentation => 'templates/' },
                 },
                ]
               );
$config->setKey(DEBUG => 0);
$config->setKey(server_http_port => 8000);

my $h = OpenFrame::Server::HTTP->new($config);
print "Point your browser to http://localhost:8000/ to play hangman!\n";
$h->handle();

