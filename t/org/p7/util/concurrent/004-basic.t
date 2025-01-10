#!perl

use v5.40;
use experimental qw[ class ];

use Test::More;
use Test::Differences;

use org::p7::util::concurrent qw[ Flow::Publisher Flow::Subscriber ];
use org::p7::util::function   qw[ Consumer ];
use org::p7::core::util       qw[ Logging ];

my @seen;

DIV('build') if DEBUG;
my $publisher  = Flow::Publisher->new;
my $subscriber = Flow::Subscriber->new(
    request_size => 2,
    consumer => Consumer->new( f => sub ($e) {
        INFO "sink", { e => $e } if DEBUG;
        push @seen => $e;
    })
);

$publisher->subscribe($subscriber);

DIV('submit') if DEBUG;
foreach ( 1 .. 10 ) {
    $publisher->submit( $_ );
}

DIV('start') if DEBUG;
$publisher->start;
DIV('close') if DEBUG;
$publisher->close;
DIV('done') if DEBUG;

eq_or_diff(\@seen, [1 .. 10], '... got the expected seen');

done_testing;




