
use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use org::p7::util::concurrent qw[ Flow Flow::Publisher ];
use org::p7::core::util       qw[ Logger ];

my @grepped1;
my @grepped2;
my @mapped1;
my @mapped2;
my @seen;

DIV('build') if DEBUG;
my $publisher  = Flow
    ->from(Flow::Publisher->new)
    ->grep(sub ($e) {
        INFO "grep(1)", { e => $e } if DEBUG;
        push @grepped1 => $e;
        ($e % 2) == 0
    })
    ->map(sub ($e) {
        INFO "map(1)", { e => $e } if DEBUG;
        push @mapped1 => $e;
        $e * 2
    })
    ->map(sub ($e) {
        INFO "map(2)", { e => $e } if DEBUG;
        push @mapped2 => $e;
        $e * 100
    })
    ->grep(sub ($e) {
        INFO "grep(2)", { e => $e } if DEBUG;
        push @grepped2 => $e;
        $e > 1000
    })
    ->to(sub ($e) {
        INFO "sink", { e => $e } if DEBUG;
        push @seen => $e;
    })
    ->build
;

DIV('submit') if DEBUG;
foreach ( 1 .. 10 ) {
    $publisher->submit( $_ );
}

DIV('start') if DEBUG;
$publisher->start;
DIV('close') if DEBUG;
$publisher->close;
DIV('done') if DEBUG;

eq_or_diff(\@grepped1, [1 .. 10], '... got the expected grepped(1)');
eq_or_diff(\@mapped1,  [2,4,6,8,10], '... got the expected mapped(1)');
eq_or_diff(\@mapped2,  [4,8,12,16,20], '... got the expected mapped(2)');
eq_or_diff(\@grepped2, [400,800,1200,1600,2000], '... got the expected grepped(2)');
eq_or_diff(\@seen,     [1200,1600,2000], '... got the expected seen');

done_testing;




