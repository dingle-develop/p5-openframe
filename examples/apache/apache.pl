#!/usr/bin/perl -w
#
# The hangman images are by Andy Wardley
#
# This version of hangman uses templates and Apache

use strict;
use lib '../hangman2';
use lib '../../lib';
use Cwd;
use OpenFrame;

$SIG{INT} = \&quit;

my $HTTPD = "/usr/local/apache/bin/httpd";
my $OPENFRAME = cwd;
$OPENFRAME =~ s|/examples/apache$||;

if (not -f $HTTPD) {
  warn "This example expects Apache to be located at $HTTPD\n";
  warn "Change \$HTTPD in apache.pl to point to a working Apache binary.\n";
  exit;
}

# Set up a config with absolute paths
my $config = OpenFrame::Config->new();
$config->setKey(
                'SLOTS',
                [
                 {
                  dispatch => 'Local',
                  name     => 'OpenFrame::Slot::Images',
		  config   => { directory => "$OPENFRAME/examples/hangman/" },
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
							   config    => { words => "$OPENFRAME/examples/hangman/words.txt" },
							  },
							 ],
			      },
                 },
                 {
                  dispatch => 'Local',
                  name     => 'Hangman::Generator',
		  config   => { presentation => "$OPENFRAME/examples/hangman2/templates/" },
                 },
                ]
               );
$config->setKey(DEBUG => 0);
$config->writeConfig();

my $DEFAULTCONF = "$OPENFRAME/examples/apache/conf/httpd.conf.default";
my $NEWCONF = "$OPENFRAME/examples/apache/conf/httpd.conf";

open(IN, $DEFAULTCONF) || die $!;
open(OUT, "> $NEWCONF") || die $!;
while (<IN>) {
  s/\@\@OPENFRAME\@\@/$OPENFRAME/g;
  print OUT;
}
close IN;
close OUT;

system "$HTTPD -f $NEWCONF";

print "Point your browser to http://localhost:8000/ to play hangman!\n";
sleep 100_000; # sleep for a long time

# When the user hits control-C we shut down the httpds we started up
sub quit {
  open(IN, "$OPENFRAME/examples/apache/logs/httpd.pid") || die $!;
  my $pid = <IN>;
  kill -2, $pid;
  close IN;
};




__END__

=head1 NAME

apache.pl - A simple web hangman templated example using OpenFrame and Apache

=head1 DESCRIPTION

This Perl script contains a small and understandable web application
for OpenFrame that allows you to play Hangman with your web browser.

While all the other examples use the C<OpenFrame::Server::HTTP>
stand-alone HTTP server, this example uses
C<OpenFrame::Server::Apache>. For this to work, it requires you to
have already installed Apache and mod_perl.

Run the script and point your favourite web browser at
http://localhost:8000/

=head1 AUTHOR

Leon Brocard <leon@fotango.com>

=head1 COPYRIGHT

Copyright (C) 2001-2, Fotango Ltd.

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

