#!/usr/bin/perl -w
#
# The hangman images are by Andy Wardley
#
# This version of hangman uses templates

use strict;
use lib '../../../lib';
use lib '../../hangman2/';
use OpenFrame::Config;
use OpenFrame::Constants;
use OpenFrame::Server::Zeus;

my $config = OpenFrame::Config->new();
$config->setKey(
                'SLOTS',
                [
                 {
                  dispatch => 'Local',
                  name     => 'OpenFrame::Slot::Images',
		  config   => { directory => "../../hangman/" },
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
							   namespace => 'hangman',
							   uri       => '/',
							   dispatch  => 'Local',
							   name      => 'Hangman::Application',
							   config    => { words => "../../hangman/words.txt" },
							  },
							 ],
			      },
                 },
                 {
                  dispatch => 'Local',
                  name     => 'Hangman::Generator',
		  config   => { presentation => './' },
                 },
                ]
               );
$config->setKey(DEBUG => 0);

my $cookietin = OpenFrame::Cookietin->new();
$cookietin->set("session", $q->cookie("session"));

my $zeus = OpenFrame::Server::Zeus->new();
$zeus->handle();




