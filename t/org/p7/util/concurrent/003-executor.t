
use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use org::p7::util::concurrent qw[ Flow::Executor ];
use org::p7::core::util       qw[ Logging ];

my $exe2 = Flow::Executor->new;
my $exe1 = Flow::Executor->new( next => $exe2 );

my @got;

sub ping ($n) {
    sub {
        INFO("ping($n)") if DEBUG;
        push @got => "ping($n)";
        $exe2->next_tick(pong($n - 1)) if $n;
    }
}

sub pong ($n) {
    sub {
        INFO("pong($n)") if DEBUG;
        push @got => "pong($n)";
        $exe1->next_tick(ping($n - 1)) if $n;
    }
}

$exe1->next_tick(ping(10));
$exe1->run;

eq_or_diff(
    \@got,
    [qw[
        ping(10)
        pong(9)
        ping(8)
        pong(7)
        ping(6)
        pong(5)
        ping(4)
        pong(3)
        ping(2)
        pong(1)
        ping(0)
    ]],
    '... got the expected data'
);

done_testing;
