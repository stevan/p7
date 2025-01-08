
use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use org::p7::util::function qw[ Consumer ];

my @expected = (10, 10);

my @got;
my sub capture ($x) { push @got => $x }

my $c1 = Consumer->new( f => \&capture );
my $c2 = $c1->and_then( \&capture );

$c2->accept(10);

eq_or_diff(\@got, \@expected, '... got the expected output');

done_testing;
