use strict;
use Test::Simple tests => 17;
use OpenFrame;

ok(1, "should load ok");
my $cookiejar = OpenFrame::Cookietin->new();
ok($cookiejar, "should get object back");
my %cookies = $cookiejar->get_all;
ok(scalar keys %cookies == 0, "should have no cookies");

ok($cookiejar->set(foo => "bar"), "should add first cookie ok");
%cookies = $cookiejar->get_all;
ok(scalar keys %cookies == 1, "should have one cookie");
ok($cookiejar->set(bar => "quux"), "should add second cookie ok");
%cookies = $cookiejar->get_all;
ok(scalar keys %cookies == 2, "should have two cookies");

ok($cookiejar->get("foo") eq "bar", "should get first cookie ok");
ok($cookies{foo} eq "bar", "should get first cookie ok in get_all");
ok($cookiejar->get("bar") eq "quux", "should get second cookie ok");
ok($cookies{bar} eq "quux", "should get second cookie ok in get_all");

ok($cookiejar->set(bar => "foo"), "should replace second cookie ok");
%cookies = $cookiejar->get_all;
ok(scalar keys %cookies == 2, "should have two cookies");
ok($cookiejar->get("bar") eq "foo", "should get second cookie ok");

ok($cookiejar->delete("bar"), "should delete cookie ok");
%cookies = $cookiejar->get_all;
ok(scalar keys %cookies == 1, "should have one cookie");
ok(!defined($cookiejar->get("bar")), "should not be able to fetch after deletion");

