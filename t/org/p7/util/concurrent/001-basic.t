
use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use org::p7::util::concurrent qw[ Flow Flow::Publisher ];
use org::p7::core::util       qw[ Logger ];

my @grepped;
my @mapped;
my @seen;

DIV('build') if DEBUG;
my $publisher  = Flow
    ->from(Flow::Publisher->new)
    ->grep(sub ($e) {
        INFO "grep", { e => $e } if DEBUG;
        push @grepped => $e;
        ($e % 2) == 0
    })
    ->map(sub ($e) {
        INFO "map", { e => $e } if DEBUG;
        push @mapped => $e;
        $e * 2
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

eq_or_diff(\@grepped, [1 .. 10], '... got the expected grepped');
eq_or_diff(\@mapped,  [2,4,6,8,10], '... got the expected mapped');
eq_or_diff(\@seen,    [4,8,12,16,20], '... got the expected seen');

done_testing;




