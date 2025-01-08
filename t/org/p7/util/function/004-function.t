
use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use org::p7::util::function qw[ Function ];

my @expected = (5, 10, 100, 'THEN(100)', 100, 110);

my @got;

my $f1 = Function->new( f => sub ($t) { push @got => $t; return $t });
isa_ok($f1, 'Function');

$f1->apply(5);

my $f2 = $f1->curry(10);
isa_ok($f2, 'Supplier');

$f2->get;

my $f3 = $f1->and_then(sub ($x) { push @got => "THEN($x)" });
isa_ok($f3, 'Function');

$f3->apply(100);

my $f4 = $f1->compose(sub ($x) { push @got => $x; $x + 10 });
isa_ok($f4, 'Function');

$f4->apply(100);

eq_or_diff(\@got, \@expected, '... got the expected output');

done_testing;
