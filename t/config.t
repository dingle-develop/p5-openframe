use strict;
use Test::Simple tests => 26;
use OpenFrame::Config;

my $c = OpenFrame::Config->new();
ok($c, "simple instantiation");
ok($c->sourceFile, "sourceFile");
ok(not($c->isKey('foo')), "false isKey");
ok(not($c->getKey('foo')), "false getKey");

ok($c->setKey('foo', 'bar'), "setKey");
ok($c->isKey('foo'), "real isKey");
ok($c->getKey('foo') eq 'bar', "real getKey");

ok($c->setKey('foo', 'quux'), "revalued setKey");
ok($c->isKey('foo'), "real isKey");
ok($c->getKey('foo') eq 'quux', "real getKey");

ok($c->deleteKey('foo'), "deleteKey");
ok(not($c->isKey('foo')), "false isKey");
ok(not($c->getKey('foo')), "false getKey");

ok($c->setKey('persistent', 'yes'), "persistent setKey");
ok($c->writeConfig(), "writeConfig");

my $c2 = OpenFrame::Config->new();
ok($c2, "simple instantiation");
ok($c2->sourceFile eq './.openframe.conf', "sourceFile");
ok(not($c2->isKey('foo')), "false isKey");
ok(not($c2->getKey('foo')), "false getKey");

ok($c2->isKey('persistent'), "persistent isKey");
ok($c2->getKey('persistent') eq 'yes', "persistent getKey");
ok($c2->deleteKey('persistent'), "deleteKey");

undef $c2;

my $c3 = OpenFrame::Config->new();
ok($c3, "simple instantiation");
ok($c3->sourceFile eq './.openframe.conf', "sourceFile");
ok(not($c3->isKey('persistent')), "persistent isKey disappeared");
ok(not($c3->getKey('persistent')), "persistent getKey disappeared");


unlink("../.openframe.conf");