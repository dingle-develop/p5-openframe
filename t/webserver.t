#!/usr/bin/perl

use strict;
use warnings;
use URI;
use lib 'lib';
use lib 't/lib';
use OpenFrame::Config;
use OpenFrame::Server::Direct;
use OpenFrame::Constants;
use Test::Simple tests => 15;

my $config = OpenFrame::Config->new();
ok($config, "should get config");
$config->setKey(
                SLOTS =>
                [
                 {
                  dispatch => 'Local',
                  name     => 'OpenFrame::Slot::Images',
		  config   => { directory => 'examples/webserver/htdocs/' },
                 },
                 {
                  dispatch => 'Local',
                  name     => 'OpenFrame::Slot::HTML',
		  config   => { directory => 'examples/webserver/htdocs/' },
                 },
                ]
	       );
$config->setKey(DEBUG => 0);
$config->setKey(server_http_port => 8000);

my $direct = OpenFrame::Server::Direct->new($config);
ok($direct, "should get OpenFrame::Server::Direct object");

my $cookietin = OpenFrame::AbstractCookie->new();
my $response;
($response, $cookietin) = $direct->handle("http://localhost/", $cookietin);
ok($response, "should get response back for /");
ok($response->code == ofOK, "message code should be ok");
ok($response->mimetype() eq 'text/html', "mimetype should be text/html");
ok($response->message() eq q|<html>
<head>
<title>Look, a webserver</title>
</head>
<body>
This website is powered by Perl:<br>
<img src="perl.gif">
<p>
It is an example of an OpenFrame application that does not do
anything, except serve images and HTML pages.
</body>
</html>|, "should get correct message");
ok(scalar($cookietin->getCookies()) == 0, "should get no cookies");

($response, $cookietin) = $direct->handle("http://localhost/error/", $cookietin);
ok($response, "should get response back for /error/");
ok($response->code == ofERROR, "message code should be an error");
ok(scalar($cookietin->getCookies()) == 0, "should get 0 cookies");

($response, $cookietin) = $direct->handle("http://localhost/perl.gif", $cookietin);
ok($response, "should get response back for /perl.gif");
ok($response->code == ofOK, "message code should be ok");
ok($response->mimetype() eq 'image/gif', "mimetype should be image/gif");
ok($response->message(), "should have message");
ok(scalar($cookietin->getCookies()) == 0, "should get no cookies");

#print $response->message() . "\n";





